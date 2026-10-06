import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Full screen date picker for phones and tablets, made for people with low
/// vision: big text and buttons, high contrast, and works with TalkBack.
/// Day, Month and Year each have large - and + buttons; tapping the value
/// shows all choices as big buttons. The chosen date is spoken when it
/// changes.
Future<DateTime?> showLargeDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return Navigator.of(context).push<DateTime>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _LargeDatePickerPage(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    ),
  );
}

// High contrast: dark blue on white is above 10:1
const Color _ink = Color(0xFF111111);
const Color _accent = Color(0xFF0D47A1);
const Color _accentLight = Color(0xFFE3EDFB);

class _LargeDatePickerPage extends StatefulWidget {
  const _LargeDatePickerPage({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_LargeDatePickerPage> createState() => _LargeDatePickerPageState();
}

class _LargeDatePickerPageState extends State<_LargeDatePickerPage> {
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = DateUtils.dateOnly(widget.initialDate);
  }

  // Keeps the day valid for the month and the date within first/last date.
  void _set(int year, int month, int day) {
    var date = DateTime(
        year, month, day.clamp(1, DateUtils.getDaysInMonth(year, month)));
    if (date.isBefore(widget.firstDate)) date = widget.firstDate;
    if (date.isAfter(widget.lastDate)) date = widget.lastDate;
    HapticFeedback.selectionClick();
    setState(() => _date = DateUtils.dateOnly(date));
  }

  // Wraps around, e.g. day 31 + 1 -> 1, month 1 - 1 -> 12.
  int _wrap(int value, int min, int max) =>
      value < min ? max : (value > max ? min : value);

  int get _daysInMonth => DateUtils.getDaysInMonth(_date.year, _date.month);

  void _changeDay(int delta) =>
      _set(_date.year, _date.month, _wrap(_date.day + delta, 1, _daysInMonth));
  void _changeMonth(int delta) =>
      _set(_date.year, _wrap(_date.month + delta, 1, 12), _date.day);
  void _changeYear(int delta) =>
      _set(_date.year + delta, _date.month, _date.day);

  /// All the choices as big buttons, returns the chosen one.
  Future<void> _chooseFrom(String title, List<String> labels, int selected,
      ValueChanged<int> onChosen) async {
    final int? index = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => _ChoiceSheet(
          scale: (MediaQuery.of(context).size.shortestSide / 400)
              .clamp(1.0, 1.6),
          title: title, labels: labels, selectedIndex: selected),
    );
    if (index != null) onChosen(index);
  }

  @override
  Widget build(BuildContext context) {
    // Bigger on tablets: 1 on phones, up to 1.6 on large tablets
    final double k =
        (MediaQuery.of(context).size.shortestSide / 400).clamp(1.0, 1.6);
    final String fullDate = DateFormat('EEEE, d MMMM yyyy').format(_date);
    final int firstYear = widget.firstDate.year;
    final int lastYear = widget.lastDate.year;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        title: const Text('Select date', style: TextStyle(fontSize: 24)),
        leading: IconButton(
          iconSize: 32,
          tooltip: 'Cancel',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            // Scrolls when the phone's font size is set very large
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600 * k),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Spoken by TalkBack each time the date changes
                      Semantics(
                        liveRegion: true,
                        label: 'Selected date $fullDate',
                        excludeSemantics: true,
                        child: Container(
                          padding: EdgeInsets.all(16 * k),
                          decoration: BoxDecoration(
                            color: _accentLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _accent, width: 2),
                          ),
                          child: Text(fullDate,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 30 * k,
                                  fontWeight: FontWeight.bold,
                                  color: _ink)),
                        ),
                      ),
                      SizedBox(height: 24 * k),
                      _DatePartRow(
                        scale: k,
                        label: 'Day',
                        value: '${_date.day}',
                        onChange: _changeDay,
                        onTapValue: () => _chooseFrom(
                            'Choose day',
                            [for (int d = 1; d <= _daysInMonth; d++) '$d'],
                            _date.day - 1,
                            (i) => _set(_date.year, _date.month, i + 1)),
                      ),
                      _DatePartRow(
                        scale: k,
                        label: 'Month',
                        value: DateFormat.MMMM().format(_date),
                        onChange: _changeMonth,
                        onTapValue: () => _chooseFrom(
                            'Choose month',
                            [
                              // Only up to the last month in its year
                              for (int m = 1;
                                  m <=
                                      (_date.year == lastYear
                                          ? widget.lastDate.month
                                          : 12);
                                  m++)
                                DateFormat.MMMM().format(DateTime(2000, m))
                            ],
                            _date.month - 1,
                            (i) => _set(_date.year, i + 1, _date.day)),
                      ),
                      _DatePartRow(
                        scale: k,
                        label: 'Year',
                        value: '${_date.year}',
                        onChange: _changeYear,
                        onTapValue: () => _chooseFrom(
                            'Choose year',
                            [
                              for (int y = firstYear; y <= lastYear; y++) '$y'
                            ],
                            _date.year - firstYear,
                            (i) =>
                                _set(firstYear + i, _date.month, _date.day)),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _accent,
                            side: const BorderSide(color: _accent, width: 2),
                            minimumSize: Size(200 * k, 56 * k),
                            textStyle: TextStyle(fontSize: 20 * k),
                          ),
                          onPressed: () {
                            final now = DateTime.now();
                            _set(now.year, now.month, now.day);
                          },
                          icon: Icon(Icons.today, size: 28 * k),
                          label: const Text('Today'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Cancel / OK stay at the bottom, always in reach
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _ink,
                    side: const BorderSide(color: _ink, width: 2),
                    minimumSize: Size.fromHeight(64 * k),
                    textStyle: TextStyle(fontSize: 22 * k),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Semantics(
                  label: 'OK, choose $fullDate',
                  excludeSemantics: true,
                  button: true,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      minimumSize: Size.fromHeight(64 * k),
                      textStyle: TextStyle(
                          fontSize: 22 * k, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => Navigator.of(context).pop(_date),
                    child: const Text('OK'),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// One of Day / Month / Year: big - and + buttons around the value. For
/// TalkBack the value is also adjustable (swipe up/down) like a slider.
class _DatePartRow extends StatelessWidget {
  const _DatePartRow({
    required this.scale,
    required this.label,
    required this.value,
    required this.onChange,
    required this.onTapValue,
  });
  final double scale;
  final String label;
  final String value;
  final ValueChanged<int> onChange;
  final VoidCallback onTapValue;

  Widget _stepButton(IconData icon, String tooltip, int delta) {
    final double size = 72 * scale;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: _accent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onChange(delta),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: 44 * scale, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * scale),
      child: Row(children: [
        _stepButton(Icons.remove, 'Previous ${label.toLowerCase()}', -1),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Semantics(
            label: label,
            value: value,
            hint: 'Double tap to see all, swipe up or down to change',
            onIncrease: () => onChange(1),
            onDecrease: () => onChange(-1),
            excludeSemantics: true,
            child: Material(
              color: _accentLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: _accent, width: 2),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTapValue,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Column(children: [
                    Text(label,
                        style: TextStyle(fontSize: 18 * scale, color: _ink)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(value,
                          style: TextStyle(
                              fontSize: 40 * scale,
                              fontWeight: FontWeight.bold,
                              color: _ink)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12 * scale),
        _stepButton(Icons.add, 'Next ${label.toLowerCase()}', 1),
      ]),
    );
  }
}

/// All choices as a grid of big buttons, scrolled to the selected one.
class _ChoiceSheet extends StatelessWidget {
  const _ChoiceSheet({
    required this.scale,
    required this.title,
    required this.labels,
    required this.selectedIndex,
  });
  final double scale;
  final String title;
  final List<String> labels;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    // Wider buttons for month names
    final double minWidth = (labels.first.length > 4 ? 170 : 96) * scale;
    final double rowHeight = 72 * scale;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 26 * scale,
                        fontWeight: FontWeight.bold,
                        color: _ink)),
              ),
              IconButton(
                iconSize: 36,
                tooltip: 'Close',
                icon: const Icon(Icons.close, color: _ink),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final int columns =
                  (constraints.maxWidth / minWidth).floor().clamp(1, 7);
              final controller = ScrollController(
                initialScrollOffset:
                    ((selectedIndex ~/ columns) - 1).clamp(0, 1 << 20) *
                        (rowHeight + 8),
              );
              return GridView.builder(
                controller: controller,
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: rowHeight,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: labels.length,
                itemBuilder: (context, index) {
                  final bool selected = index == selectedIndex;
                  return Semantics(
                    selected: selected,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selected ? _accent : _accentLight,
                        foregroundColor: selected ? Colors.white : _ink,
                        side: const BorderSide(color: _accent, width: 1.5),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(context).pop(index),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(labels[index],
                            style: TextStyle(
                                fontSize: 26 * scale, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ]),
      ),
    );
  }
}
