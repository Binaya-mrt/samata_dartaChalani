import 'package:flutter/material.dart';
import 'package:samata_dartachalani/constants.dart';

class Tauko extends StatelessWidget {
  final String header;

  Tauko({
    super.key,
    required this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Image.asset('assets/images/logotp.png')),
        Text('Samata Gharelu Laghubitta',
            style: gettext(context).headlineMedium),
        SizedBox(height: getheight(context) * 0.04),
        Text(header, style: gettext(context).headlineLarge),
        SizedBox(height: getheight(context) * 0.04),
      ],
    );
  }
}
