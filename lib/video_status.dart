import 'package:flutter/material.dart';
import 'package:flutter_application_1/list_photos.dart' show RadiantGradientMask;
import 'package:flutter_application_1/shared_values.dart';
import 'package:http/http.dart' as http;

/// Marking videos as visited / important / to be deleted, shared by the video
/// list and the video player. Nothing is marked automatically.
class VideoStatus {
  static const String visited = 'visited';
  static const String important = 'important';
  static const String remove = 'remove';

  /// The current mark of [video], one of the constants above, or null when
  /// it isn't marked yet.
  static String? of(Map video) {
    if (video['tobeDeleted'] == true) return remove;
    if (video['important'] == true) return important;
    if (video['visited'] == true) return visited;
    return null;
  }

  /// Saves the mark on the server and, once that worked, on [video] too.
  static Future<void> mark(Map video, String action) async {
    final url = Uri.parse(AppValues.getMarkVideoUrl(video['id'], action));
    debugPrint("URL $url");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    video['visited'] = action == visited;
    video['important'] = action == important;
    video['tobeDeleted'] = action == remove;
  }

  /// "2024-12-14 15:41" from the createdDate the server sends.
  static String dateText(Map video) {
    final String date = video['createdDate'] ?? '';
    return date.length >= 16 ? date.substring(0, 16) : date;
  }
}

/// The same status icons as the photo list.
class VideoStatusIcon extends StatelessWidget {
  const VideoStatusIcon({super.key, required this.video, this.size = 56});
  final Map video;
  final double size;

  @override
  Widget build(BuildContext context) {
    final status = VideoStatus.of(video);
    final IconData icon;
    final Color color;
    if (status == VideoStatus.important) {
      icon = Icons.favorite;
      color = Colors.lightGreenAccent;
    } else if (status == VideoStatus.visited) {
      icon = Icons.view_array;
      color = Colors.lightBlue;
    } else if (status == VideoStatus.remove) {
      icon = Icons.delete;
      color = Colors.redAccent;
    } else {
      icon = Icons.pending;
      color = Colors.yellow;
    }
    return RadiantGradientMask(
      start: color,
      end: Colors.pink,
      child: Icon(icon, size: size, color: color),
    );
  }
}

/// Bottom bar with Visited / Important / Delete; the current mark of [video]
/// is highlighted. [video] is null when nothing is selected.
class VideoMarkBar extends StatelessWidget {
  const VideoMarkBar({super.key, required this.video, required this.onMark});
  final Map? video;
  final ValueChanged<String> onMark;

  @override
  Widget build(BuildContext context) {
    final current = video == null ? null : VideoStatus.of(video!);
    return Material(
      color: Colors.green[100],
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(children: [
            _button(VideoStatus.visited, Icons.view_array, 'Visited',
                Colors.blue, current),
            _button(VideoStatus.important, Icons.label_important, 'Important',
                Colors.green, current),
            _button(VideoStatus.remove, Icons.delete, 'Delete', Colors.red,
                current),
          ]),
        ),
      ),
    );
  }

  Widget _button(String action, IconData icon, String label, Color color,
      String? current) {
    final bool selected = action == current;
    return Expanded(
      child: InkWell(
        onTap: () => onMark(action),
        child: Container(
          color: selected ? color.withOpacity(0.25) : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}
