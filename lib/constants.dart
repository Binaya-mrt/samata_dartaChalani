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
final List<String> fiscalYears = ['2079/80', '2080/81', '2081/82', '2082/83'];
final Map<String, List<String>> companyOptions = {
  'External': [
    'Nepal rastra bank',
    'Company Registrar Office',
    'Security Board of Nepal',
    'NEPSE',
    'CDSC',
    'Share Registrar(RTS)',
    'Inland Revenue Department(IRD)',
    'Bank & Financial institute(BFI\'s)',
    'Labour Office',
    'Nepal Microfinance Banker Association(NMBA)',
    'External Training Institute',
    'Deposit Credit Gaunty Fund',
    'Credit Information Beauro',
    'Insurance Company',
    'Internal Audit',
    'External audit',
    'Legal Advisor',
    'Internal Audit',
    'Others'
  ],
  'Internal': ['Samata'],
};
const title =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red);
const inside =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black);
