import 'dart:developer';

import 'package:gsheets_get/gsheets_get.dart';

Future<Map<dynamic, dynamic>> checkRollMess(String roll, String email) async {
  Map map = {'isPresent': false, 'roll': roll,'hostel': ''};
  for(int i=1;i<=14;i++)
    {
      final GSheetsGet sheet = GSheetsGet(
          sheetId: "1-nE8Cb_p3pcFGr4osgTjq26UZdm0NLRUqcM4Yxfv2oM",
          page: i,
          skipRows: 1);
      print(sheet.urlSheet);
      if(sheet==null)
        continue;
      GSheetsResult result = await sheet.getSheet();
      print(result.sheet.feed.title.text);
      List<String> allowedRollList = [];
      List<String> allowedEmailList = [];
      result.sheet.rows.forEach((row) {
        StringBuffer buffer = new StringBuffer();

        if (row != null) {
          row.cells.forEach((cell) {
            buffer.write(cell?.text.toString() + "|");
          });
        }
        allowedRollList.add(buffer.toString().split("|")[3]);
        allowedEmailList.add(buffer.toString().split("|")[4]);
      });
      if (allowedEmailList.contains(email)) {
        //update the roll number from the GSheet incase the Azure API didn't return the roll for this user.
        String rollNew = allowedRollList[allowedEmailList.indexOf(email)];
        if (rollNew != "null") {
          print('*******New Roll Number: ' + rollNew + '******');
          map['roll'] = rollNew;
        }
        map['hostel'] = result.sheet.feed.title.text;
        map['isPresent'] = true;
        break;
      } else if (allowedRollList.contains(roll)) {
        map['hostel'] = result.sheet.feed.title.text;
        map['isPresent'] = true;
        break;
      }
    }
  return map;
}
