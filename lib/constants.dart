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

// final List<String>  = ['2079/080', '2080/081', '2081/082', '2082/083', '2083/084',];
// give me list of 10

final List<String> fiscalYears = [
  '2080/081',
  '2081/082',
  '2082/083',
  '2083/084',
  '2084/085',
  '2085/086',
  '2086/087',
  '2087/088',
  '2088/089',
  '2089/090',
  '2090/091',
  '2091/092',
  '2092/093',
  '2093/094',
  '2094/095',
  '2095/096',
  '2096/097',
  '2097/098',
  '2098/099',
];

final Map<String, List<String>> companyOptions = {
  'External': [
    'Nepal Rastra Bank',
    'Company Registrar Office',
    'Security Board Of Nepal',
    'External Training Institutes',
    'Nepal Stock Exchange (NEPSE)',
    'CDS and Clearing Limited (CDSC)',
    'Deposit and Credit Guarantee Fund (DCGF)',
    'Share Registrar (RTS)',
    'Inland Revenue Department (IRD)',
    'Bank & Financial Institutions (BFI\'s)',
    'Nepal Microfinance Banker Association (NMBA)',
    'Credit Information Bureau (CIB)',
    'Insurance Company',
    'Labour Office',
    'Internal Audit',
    'External audit',
    'Legal Advisor',
    'Others'
  ],
  'Internal': ['Samata'],
};
const title =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red);
const inside =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black);
