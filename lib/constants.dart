import 'package:flutter/material.dart';

double getheight(context) {
  return MediaQuery.of(context).size.height;
}

double getwidth(context) {
  return MediaQuery.of(context).size.width;
}

TextTheme gettext(BuildContext context) {
  return Theme.of(context).textTheme;
}

final border = OutlineInputBorder(
  borderSide: const BorderSide(color: Color(0xffF7D6D6)),
  borderRadius: BorderRadius.circular(4),
);
