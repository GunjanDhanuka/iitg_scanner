
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gsheets_get/gsheets_get.dart';
List<String> hostels = ['subansiri','siang','disang','dibang','manas','brahmaputra','dihing','umiam','kameng','barak','dhansiri','msh','kapili','lohit'];
int selectedIndex = 0;
String selectedHostel = hostels[0];
List<DropdownMenuItem<String>> hostelDropdown;
onChangeDropdownItem(String item)
{
  selectedHostel = item;
  selectedIndex = hostels.indexOf(item);
}
Map<dynamic,dynamic> data = new Map();
Future<Map<dynamic, dynamic>> checkRollMess(String roll, String email,BuildContext context,{String givenHostel}) async {
  bool loading = false;
  if(givenHostel!=null)
    {
      selectedIndex = hostels.indexOf(givenHostel);
      Map map = {'isPresent': false, 'roll': roll,'hostel': ''};
      final GSheetsGet sheet = GSheetsGet(
          sheetId: "1-nE8Cb_p3pcFGr4osgTjq26UZdm0NLRUqcM4Yxfv2oM",
          page: selectedIndex,
          skipRows: 1);
      print(sheet.urlSheet);
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
        return map;
      } else if (allowedRollList.contains(roll)) {
        map['hostel'] = result.sheet.feed.title.text;
        map['isPresent'] = true;
        return map;
      }
      return map;
    }
  else
    {
      List<DropdownMenuItem<String>> items = new List();
      for(String hostel in hostels)
      {
        items.add(DropdownMenuItem(
          value: hostel,
          child: Text(hostel,style: TextStyle(fontFamily: 'raleway', fontSize: 15, color: Colors.black)),
        ));
      }
      hostelDropdown = items;
      await showDialog(context: context, builder: (context){
         return StatefulBuilder(builder: (context,stateSetter){
           return AlertDialog(
            actions: [
              (loading)?Container():GestureDetector(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Submit',style: TextStyle(fontFamily: 'raleway', fontSize: 13, color: Colors.blue)),
                ),
                onTap: () async {
                  stateSetter((){
                    loading = true;
                  });
                  print('clicked');
                  Map map = {'isPresent': false, 'roll': roll,'hostel': ''};
                  final GSheetsGet sheet = GSheetsGet(
                      sheetId: "1-nE8Cb_p3pcFGr4osgTjq26UZdm0NLRUqcM4Yxfv2oM",
                      page: selectedIndex+1,
                      skipRows: 1);
                  print(sheet.urlSheet);
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
                  print(allowedEmailList);
                  if (allowedEmailList.contains(email)) {
                    //update the roll number from the GSheet incase the Azure API didn't return the roll for this user.
                    String rollNew = allowedRollList[allowedEmailList.indexOf(email)];
                    if (rollNew != "null") {
                      print('*******New Roll Number: ' + rollNew + '******');
                      map['roll'] = rollNew;
                    }
                    map['hostel'] = result.sheet.feed.title.text;
                    map['isPresent'] = true;
                  } else if (allowedRollList.contains(roll)) {
                    map['hostel'] = result.sheet.feed.title.text;
                    map['isPresent'] = true;
                  }
                  print(map);
                  stateSetter((){
                    data = map;
                    loading = false;
                  });
                  Navigator.pop(context);
                },
              )
            ],
            content:Container(
              width: MediaQuery.of(context).size.width-100,
              padding: EdgeInsets.symmetric(vertical: 20),
              child:(loading)?Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Center(child: CircularProgressIndicator(),),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Text("Please wait as we match your credentials with our data-sheets",style: TextStyle(fontFamily: 'raleway', fontSize: 14, color: Colors.black,),textAlign: TextAlign.center,),
                    width: MediaQuery.of(context).size.width-120,
                  )
                ],
              ):Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Choose Your Hostel',style: TextStyle(fontFamily: 'raleway', fontSize: 17, color: Colors.black),),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: DropdownButton(
                      iconDisabledColor: Colors.black,
                      iconEnabledColor: Colors.black,
                      hint: Text("Select Category"),
                      value: selectedHostel,
                      items: hostelDropdown,
                      onChanged: (item){
                        stateSetter((){
                          onChangeDropdownItem(item);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      });
      print(data);
      return data;
    }


}
