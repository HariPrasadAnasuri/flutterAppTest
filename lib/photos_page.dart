import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_application_1/app_utility.dart';
import 'package:flutter_application_1/list_photos.dart';
import 'package:flutter_application_1/ShowVideo.dart';
import 'package:flutter_application_1/selected_photos.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:flutter_application_1/show_qr_code_photo.dart';
import 'package:flutter_application_1/slideshow_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhotosPage extends StatefulWidget {
  const PhotosPage({super.key});

  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

List<String> list = <String>['Hari', 'Jyothi'];

class _PhotosPageState extends State<PhotosPage> {
  String textEntered = "";
  String url = "";
  late String dropdownValue = list.first;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(children: [
      const SizedBox(height: 33),
      AppUtility.createAnimationButton(
          "Categorise Photos",
          Colors.blueAccent,
          200,
          MediaQuery.of(context).size.width,
          const Color.fromARGB(60, 0, 255, 204),
          const Color.fromARGB(255, 26, 163, 255),
          40,
          2, () {
        onCategorisePhotosButtonPressed();
      }),
      const SizedBox(height: 12),
      AppUtility.createAnimationButton(
          "Chosen Photos",
          Colors.cyanAccent,
          200,
          MediaQuery.of(context).size.width,
          const Color.fromARGB(40, 60, 27, 109),
          const Color.fromARGB(255, 239, 70, 27),
          40,
          2, () {
        onChosenPhotosButtonPressed();
      }),
      const SizedBox(height: 12),
      AppUtility.createAnimationButton(
          "QR Scanner",
          Colors.blueGrey,
          200,
          MediaQuery.of(context).size.width,
          const Color.fromARGB(60, 0, 255, 204),
          const Color.fromARGB(255, 26, 163, 255),
          40,
          2, () {
        onQrCodeControllerButtonPressed();
      }),
      const SizedBox(height: 12),
      AppUtility.createAnimationButton(
          "Slideshow",
          Colors.amberAccent,
          200,
          MediaQuery.of(context).size.width,
          const Color.fromARGB(40, 60, 27, 109),
          const Color.fromARGB(255, 26, 163, 255),
          40,
          2, () {
        onSlideshowButtonPressed();
      }),
    ])));
  }

  void onCategorisePhotosButtonPressed() {
    AppUtility.datePicker(context).then((selectedDate) => {
          if (selectedDate != null)
            {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext buildContext) {
                    return const ListPhotos();
                  },
                ),
              )
            }
        });
  }

  void onChosenPhotosButtonPressed() {
    AppUtility.datePicker(context).then((selectedDate) => {
          if (selectedDate != null)
            {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext buildContext) {
                    AppValues.importantPhotosDate = selectedDate.toString();
                    debugPrint(
                        "Selected date: ${AppValues.importantPhotosDate}");
                    return const SelectedPhotos();
                  },
                ),
              )
            }
        });
  }
  /// Asks the start date, then which photos, then starts the slideshow.
  Future<void> onSlideshowButtonPressed() async {
    final DateTime? selectedDate = await AppUtility.datePicker(context);
    if (selectedDate == null || !mounted) return;
    final String? filter = await askSlideshowFilter();
    if (filter == null || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext buildContext) {
          return SlideshowPage(
              startDate: selectedDate.toString(), filter: filter);
        },
      ),
    );
  }

  /// 'all', 'important', 'visited' or 'deleted', null when cancelled.
  Future<String?> askSlideshowFilter() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: const Text('Which photos?'),
          children: [
            slideshowOption(dialogContext, 'all', 'All', Icons.photo_library,
                Colors.blue),
            slideshowOption(dialogContext, 'important', 'Important',
                Icons.favorite, Colors.green),
            slideshowOption(dialogContext, 'visited', 'Visited',
                Icons.view_array, Colors.lightBlue),
            slideshowOption(
                dialogContext, 'deleted', 'Deleted', Icons.delete, Colors.red),
          ],
        );
      },
    );
  }

  Widget slideshowOption(BuildContext dialogContext, String filter,
      String label, IconData icon, Color color) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(dialogContext, filter),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(children: [
        Icon(icon, color: color),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 18)),
      ]),
    );
  }

  void onQrCodeControllerButtonPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext buildContext) {
          return const ShowQrCodePhoto();
        },
      ),
    );
  }

}
