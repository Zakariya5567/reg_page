import 'package:flutter/material.dart';
import 'colors.dart';

class Heading extends StatelessWidget {
  const Heading({super.key,required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:  TextStyle(
          color: AppColor.primaryRed,
          fontSize: 36,
          fontWeight: FontWeight.bold
      ),
    );
  }
}
