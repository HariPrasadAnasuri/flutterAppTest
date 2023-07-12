import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:google_fonts/google_fonts.dart';

class AppUtility{
  static Future<DateTime?> datePicker(BuildContext context) async{
    DateTime selectedDate;
    if(AppValues.importantPhotosDate.isNotEmpty){
      selectedDate = DateTime.parse(AppValues.importantPhotosDate);
    }else{
      selectedDate = DateTime.now();
    }
    DateTime? pickedDate = await showDatePicker(
        context: context, //context of current state
        initialDate: selectedDate,
        firstDate: DateTime(1990), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101)
    );
    return pickedDate;
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
