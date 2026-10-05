import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Date picker made for a TV remote / D-pad: Left/Right moves between Day,
/// Month and Year, Up/Down changes the value and OK confirms. (The calendar
/// grid of Material's picker keeps the arrow keys, so a remote can't reach
/// its OK button.) Back cancels. The arrows can be tapped on touch screens.
Future<DateTime?> showTvDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (_) => _TvDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _TvDatePickerDialog extends StatefulWidget {
  const _TvDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_TvDatePickerDialog> createState() => _TvDatePickerDialogState();
}

class _TvDatePickerDialogState extends State<_TvDatePickerDialog> {
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
    setState(() => _date = DateUtils.dateOnly(date));
  }

  // Wraps around, e.g. day 31 + 1 -> 1, month 1 - 1 -> 12.
  int _wrap(int value, int min, int max) =>
      value < min ? max : (value > max ? min : value);

  void _submit() => Navigator.of(context).pop(_date);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Select date'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(DateFormat('EEE, d MMM yyyy').format(_date),
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DateField(
                label: 'Day',
                value: '${_date.day}',
                autofocus: true,
                onChange: (delta) => _set(
                    _date.year,
                    _date.month,
                    _wrap(_date.day + delta, 1,
                        DateUtils.getDaysInMonth(_date.year, _date.month))),
                onSubmit: _submit,
              ),
              _DateField(
                label: 'Month',
                value: DateFormat.MMM().format(_date),
                onChange: (delta) => _set(
                    _date.year, _wrap(_date.month + delta, 1, 12), _date.day),
                onSubmit: _submit,
              ),
              _DateField(
                label: 'Year',
                value: '${_date.year}',
                onChange: (delta) =>
                    _set(_date.year + delta, _date.month, _date.day),
                onSubmit: _submit,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('▲ ▼ change   ◀ ▶ move   OK to confirm',
              style: theme.textTheme.bodySmall),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        TextButton(onPressed: _submit, child: const Text('OK')),
      ],
    );
  }
}

/// One focusable Day/Month/Year box. Up/Down change it, OK submits; other
/// keys (Left/Right) are left to the normal focus movement.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChange,
    required this.onSubmit,
    this.autofocus = false,
  });
  final String label;
  final String value;
  final ValueChanged<int> onChange;
  final VoidCallback onSubmit;
  final bool autofocus;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      onChange(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      onChange(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (event is KeyDownEvent) onSubmit();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Focus(
      autofocus: autofocus,
      onKeyEvent: _onKey,
      child: Builder(builder: (context) {
        final focused = Focus.of(context).hasFocus;
        return Container(
          width: 80,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: focused ? primary.withOpacity(0.12) : null,
            border: Border.all(
                color: focused ? primary : Colors.black26,
                width: focused ? 3 : 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              GestureDetector(
                onTap: () => onChange(1),
                child: const Icon(Icons.keyboard_arrow_up),
              ),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              GestureDetector(
                onTap: () => onChange(-1),
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
        );
      }),
    );
  }
}
