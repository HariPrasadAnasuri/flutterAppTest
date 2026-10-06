import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_application_1/large_date_picker.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:flutter_application_1/tv_date_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class AppUtility{
  static Future<DateTime?> datePicker(BuildContext context) async{
    DateTime selectedDate;
    if(AppValues.importantPhotosDate.isNotEmpty){
      selectedDate = DateTime.parse(AppValues.importantPhotosDate);
    }else{
      selectedDate = DateTime.now();
    }
    DateTime? pickedDate = await showAppDatePicker(
        context: context, //context of current state
        initialDate: selectedDate,
        firstDate: DateTime(1990), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101)
    );
    return pickedDate;
  }

  /// showDatePicker, except when the app is being used with a TV remote /
  /// D-pad: the calendar grid keeps the arrow keys there, so a remote can't
  /// reach OK. Flutter switches to the traditional highlight mode once a key
  /// is pressed, and to touch mode on a touch.
  static Future<DateTime?> showAppDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    // There are no photos or videos from the future: stop at the end of the
    // current month
    final now = DateTime.now();
    final endOfThisMonth = DateTime(
        now.year, now.month, DateUtils.getDaysInMonth(now.year, now.month));
    if (lastDate.isAfter(endOfThisMonth)) lastDate = endOfThisMonth;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;
    if (FocusManager.instance.highlightMode == FocusHighlightMode.traditional) {
      return showTvDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate);
    }
    // Phones and tablets: big, high contrast picker that works with TalkBack
    return showLargeDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate);
  }
  static Widget createAnimationButton(
      String buttonText, Color textColor, double buttonHeight,
      double buttonWidth,Color gradient1, Color gradient2, double fontSize,
      double letterSpacing, VoidCallback callBackMethod){
    return AnimatedButton(
      height: buttonHeight,
      width: buttonWidth,
      text: buttonText,
      isReverse: true,

      selectedTextColor: Colors.black,
      transitionType: TransitionType.CENTER_ROUNDER,
      animatedOn: AnimatedOn.onHover,
      borderColor: Colors.yellow,
      borderRadius: 50,

      gradient: LinearGradient(
          colors: [
            gradient1,
            gradient2
          ],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: const [0.0, 1.0],
          tileMode: TileMode.clamp),
      textStyle: GoogleFonts.nunito(
          fontSize: fontSize,
          letterSpacing: letterSpacing,
          color: textColor,
          fontWeight: FontWeight.w800),
      onPress: () async {
        callBackMethod();
      },
    );
  }
}
