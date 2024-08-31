import 'package:flutter/material.dart';
import 'package:samata_dartachalani/constants.dart';

class Tauko extends StatelessWidget {
  final String header;

  const Tauko({
    super.key,
    required this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossA,
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Image.asset('assets/images/logotp.png')),
        Text('Samata Gharelu Laghubitta Bittiya Sanstha Ltd.',
            style: gettext(context).headlineSmall),
        Text('Banepa -07, Kavre, Nepal', style: gettext(context).bodySmall),
        Text('Tel: 011-597000', style: gettext(context).bodySmall),
        SizedBox(height: getheight(context) * 0.04),
        Text(header, style: gettext(context).headlineLarge),
        SizedBox(height: getheight(context) * 0.06),
      ],
    );
  }
}
