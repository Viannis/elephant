import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ExcelSheet extends StatefulWidget {
  @override
  _ExcelSheetState createState() => _ExcelSheetState();
}

class _ExcelSheetState extends State<ExcelSheet> {
  final Firestore dbRef = Firestore.instance;
  bool downloadPreparing = false;
  FocusNode _focusNode;
  FocusNode startNode;
  FocusNode endNode;
  DateFormat format = DateFormat('dd-MM-yyyy');
  DateFormat reformat = DateFormat('yyyy-MM-dd');
  TextEditingController singleDate;
  TextEditingController startDate;
  TextEditingController endDate;
  Directory _downloadsDirectory;

  @override
  void initState() {
    singleDate = TextEditingController(text: format.format(DateTime.now()));
    startDate = TextEditingController(text: format.format(DateTime.now()));
    endDate = TextEditingController(text: format.format(DateTime.now()));
    _focusNode = FocusNode();
    startNode = FocusNode();
    endNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    singleDate.dispose();
    startDate.dispose();
    endDate.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _requestFocus(FocusNode someFocusNode, BuildContext con){
    setState(() {
      FocusScope.of(con).requestFocus(someFocusNode);
    });
  }

  Future<List<List<String>>> createExcelFile(QuerySnapshot finalDocs) async{
    List<List<String>> totalData = List();
    for (var i = 0; i < finalDocs.documents.length; i++) {
      List<String> data = List();
      Timestamp timestamp = finalDocs.documents[i].data['dateTime'];
      String dateAndTime = DateFormat('dd.MM.yyyy').add_jm().format(timestamp.toDate());
      String count = finalDocs.documents[i].data['count'].toString();
      String remarks = finalDocs.documents[i].data['remarks'];
      DocumentReference userRef = finalDocs.documents[i].data['userReference'];
      String reportedBy = await userRef.get().then((value) => value.data['name'] + " " + value.data['designation']);
      DocumentReference locationRef = finalDocs.documents[i].data['locationRef'];
      String location = await locationRef.get().then((value) => value.data['name']);
      GeoPoint latLon = await locationRef.get().then((value) => value.data['location']);
      String latLong = latLon.latitude.toString() + " " + latLon.longitude.toString();
      DocumentReference beatRef = locationRef.parent().parent();
      String beat = await beatRef.get().then((value) => value.data['name']);
      DocumentReference rangeRef = beatRef.parent().parent();
      String range = await rangeRef.get().then((value) => value.data['name']);
      data.add(dateAndTime);
      data.add(range);
      data.add(beat);
      data.add(location);
      data.add(latLong);
      data.add(count);
      data.add(reportedBy);
      data.add(remarks);
      totalData.add(data);
    }
    return totalData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(61, 90, 241, 1),
        title: Text(
          'Download Excel Sheet',
          style: TextStyle(
            color: Color.fromRGBO(240, 240, 240, 1),
            fontFamily: 'Poppins',
            letterSpacing: 0.2,
            fontStyle: FontStyle.normal,
            fontSize: 20.0,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.05, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    'Specific Date',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      letterSpacing: 0.5
                    ),
                  )
                ),
                SizedBox(
                  height: 15
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 160,
                      child: TextFormField( 
                        focusNode: _focusNode,
                        onTap: () => _requestFocus(_focusNode,context),
                        readOnly: true,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                        ),
                        textInputAction: TextInputAction.none,
                        controller: singleDate,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder( 
                            borderSide: BorderSide(
                              color: Color.fromRGBO(61, 90, 241, 1)
                            )
                          ),
                          labelText: 'Date',
                          labelStyle: TextStyle(
                            color: _focusNode.hasFocus ? Color.fromRGBO(61, 90, 241, 1) : Colors.black
                          ),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.date_range,
                              color: _focusNode.hasFocus ? Color.fromRGBO(61, 90, 241, 1) : Colors.grey,
                            ),
                            iconSize: 26,
                            onPressed: () async{
                              final DateTime selectedDate = await showDatePicker(
                                context: context, 
                                initialDate: DateTime.now(), 
                                firstDate: DateTime(2000), 
                                lastDate: DateTime(2025)
                              );
                              if(selectedDate != null){
                                setState(() {
                                  singleDate.text = format.format(selectedDate);
                                });
                              }
                            },
                          )
                        ),
                      ),
                    ),
                    FlatButton(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Color.fromRGBO(61, 90, 241, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)
                      ),
                      onPressed: () async{
                        if(await Permission.storage.request().isGranted){
                          setState(() {
                            downloadPreparing = true;
                          });
                          List<String> tempDate = singleDate.text.split("-");
                          DateTime singleDayStartTime = DateTime(int.parse(tempDate[2]),int.parse(tempDate[1]),int.parse(tempDate[0]));
                          DateTime singleDayEndTime = singleDayStartTime.add(Duration(days : 1));
                          QuerySnapshot finalDocs = await dbRef.collection("count").where('dateTime', isGreaterThanOrEqualTo: singleDayStartTime )
                            .where('dateTime', isLessThan: singleDayEndTime).orderBy('dateTime').getDocuments();
                          Excel excel = Excel.createExcel();
                          Sheet sheetObject = excel['Sheet1'];
                          CellStyle cellStyle = CellStyle(backgroundColorHex: "#1AFF1A", fontFamily : getFontFamily(FontFamily.Calibri));
                          cellStyle.underline = Underline.Single;
                          List<String> dataHeadings = ["DATE & TIME","RANGE","BEAT","LOCATION","G.P.S CO-ORDINATION","NO. OF. ELEPHANTS","REPORTED BY","REMARKS"];
                          sheetObject.insertRowIterables(dataHeadings, 0);
                          createExcelFile(finalDocs).then((finalData) async{
                            if(finalData.length > 0){
                              finalData.forEach((element) { 
                                sheetObject.appendRow(element);
                              });
                              try {
                                _downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
                                excel.encode().then((onValue){
                                  try {
                                    String tempNameGenerator = 'ExcelSheet' + DateFormat('dd.MM.yyyy').add_jms().format(DateTime.now());
                                    File(join("${_downloadsDirectory.path}/Yannai/$tempNameGenerator.xlsx"))..createSync(recursive: true)..writeAsBytesSync(onValue);
                                    setState(() {
                                      downloadPreparing = false;
                                    });
                                    Fluttertoast.showToast(
                                      msg: "Downloaded Successfully",
                                      timeInSecForIos: 2,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                    );
                                  } on PlatformException {
                                    setState(() {
                                      downloadPreparing = false;
                                    });
                                    Fluttertoast.showToast(
                                      msg: "Download Unsuccessful",
                                      timeInSecForIos: 2,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                    );
                                  }
                                });
                              } on PlatformException {
                                setState(() {
                                  downloadPreparing = false;
                                });
                                Fluttertoast.showToast(
                                  msg: "Storage permission denied",
                                  timeInSecForIos: 2,
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              }
                            }
                            else{
                              setState(() {
                                downloadPreparing = false;
                              });
                              Fluttertoast.showToast(
                                msg: "There is no data for ${singleDate.text}",
                                toastLength: Toast.LENGTH_LONG,
                                timeInSecForIos: 2,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                          });
                        }
                        else{
                            setState(() {
                              downloadPreparing = false;
                            });
                            Fluttertoast.showToast(
                              msg: "Storage Permission Required",
                              toastLength: Toast.LENGTH_LONG,
                              timeInSecForIos: 2,
                              gravity: ToastGravity.BOTTOM,
                            );  
                          }
                      },
                      child: Text(
                        'Download',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.5,
                          color: Colors.white
                        ),
                      )
                    )
                  ],
                ),
                SizedBox(
                  height: 30
                ),
                Container(
                  child: Text(
                    'Date Range',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      letterSpacing: 0.5
                    ),
                  )
                ),
                SizedBox(
                  height: 15
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 160,
                      child: TextFormField( 
                        focusNode: startNode,
                        onTap: () => _requestFocus(startNode,context),
                        readOnly: true,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                        ),
                        textInputAction: TextInputAction.none,
                        controller: startDate,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder( 
                            borderSide: BorderSide(
                              color: Color.fromRGBO(61, 90, 241, 1)
                            )
                          ),
                          labelText: 'Start Date',
                          labelStyle: TextStyle(
                            color: startNode.hasFocus ? Color.fromRGBO(61, 90, 241, 1) : Colors.black
                          ),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.date_range,
                              color: startNode.hasFocus ? Color.fromRGBO(61, 90, 241, 1) : Colors.grey,
                            ),
                            iconSize: 26,
                            onPressed: () async{
                              final DateTime selectedDate = await showDatePicker(
                                context: context, 
                                initialDate: DateTime.now(), 
                                firstDate: DateTime(2000), 
                                lastDate: DateTime(2025)
                              );
                              if(selectedDate != null){
                                setState(() {
                                  startDate.text = format.format(selectedDate);
                                });
                              }
                            },
                          )
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: TextFormField( 
                        focusNode: endNode,
                        onTap: () => _requestFocus(endNode,context),
                        readOnly: true,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                        ),
                        textInputAction: TextInputAction.none,
                        controller: endDate,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder( 
                            borderSide: BorderSide(
                              color: Color.fromRGBO(61, 90, 241, 1)
                            )
                          ),
                          labelText: 'End Date',
                          labelStyle: TextStyle(
                            color: endNode.hasFocus ? Color.fromRGBO(61, 90, 241, 1) : Colors.black
                          ),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.date_range,
                              color: endNode.hasFocus ? Color.fromRGBO(61, 90, 241, 1) : Colors.grey,
                            ),
                            iconSize: 26,
                            onPressed: () async{
                              final DateTime selectedDate = await showDatePicker(
                                context: context, 
                                initialDate: DateTime.now(), 
                                firstDate: DateTime(2000), 
                                lastDate: DateTime(2025)
                              );
                              if(selectedDate != null){
                                setState(() {
                                  endDate.text = format.format(selectedDate);
                                });
                              }
                            },
                          )
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15
                ),
                FlatButton(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Color.fromRGBO(61, 90, 241, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)
                  ),
                  onPressed: () async{
                    if(await Permission.storage.request().isGranted){
                      setState(() {
                        downloadPreparing = true;
                      });
                      List<String> tempStartDate = startDate.text.split("-");
                      List<String> tempEndDate = endDate.text.split("-");
                      DateTime startDateStartTime = DateTime(int.parse(tempStartDate[2]),int.parse(tempStartDate[1]),int.parse(tempStartDate[0]));
                      DateTime endDateStartTime = DateTime(int.parse(tempEndDate[2]),int.parse(tempEndDate[1]),int.parse(tempEndDate[0]));
                      DateTime endDateEndTime = endDateStartTime.add(Duration(days : 1));
                      QuerySnapshot finalDocs = await dbRef.collection("count").where('dateTime', isGreaterThanOrEqualTo: startDateStartTime )
                        .where('dateTime', isLessThan: endDateEndTime).orderBy('dateTime').getDocuments();
                      Excel excel = Excel.createExcel();
                      Sheet sheetObject = excel['Sheet1'];
                      CellStyle cellStyle = CellStyle(backgroundColorHex: "#1AFF1A", fontFamily : getFontFamily(FontFamily.Calibri));
                      cellStyle.underline = Underline.Single;
                      List<String> dataHeadings = ["DATE & TIME","RANGE","BEAT","LOCATION","G.P.S CO-ORDINATION","NO. OF. ELEPHANTS","REPORTED BY","REMARKS"];
                      sheetObject.insertRowIterables(dataHeadings, 0);
                      createExcelFile(finalDocs).then((finalData) async{
                        if(finalData.length > 0){
                          finalData.forEach((element) { 
                            sheetObject.appendRow(element);
                          });
                          try {
                            _downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
                            excel.encode().then((onValue){
                              try {
                                String tempNameGenerator = 'ExcelSheet' + DateFormat('dd.MM.yyyy').add_jms().format(DateTime.now());
                                File(join("${_downloadsDirectory.path}/Yannai/$tempNameGenerator.xlsx"))..createSync(recursive: true)..writeAsBytesSync(onValue);
                                setState(() {
                                  downloadPreparing = false;
                                });
                                Fluttertoast.showToast(
                                  msg: "Downloaded Successfully",
                                  timeInSecForIos: 2,
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              } on PlatformException {
                                setState(() {
                                  downloadPreparing = false;
                                });
                                Fluttertoast.showToast(
                                  msg: "Download Unsuccessful",
                                  timeInSecForIos: 2,
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              }
                              
                            });
                          } on PlatformException {
                            setState(() {
                              downloadPreparing = false;
                            });
                            Fluttertoast.showToast(
                              msg: "Storage permission denied",
                              timeInSecForIos: 2,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                            );
                          }
                        }
                        else{
                          setState(() {
                            downloadPreparing = false;
                          });
                          Fluttertoast.showToast(
                            msg: "No data available",
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIos: 2,
                            gravity: ToastGravity.BOTTOM,
                          );  
                        }
                      });
                    }
                    else{
                      setState(() {
                        downloadPreparing = false;
                      });
                      Fluttertoast.showToast(
                        msg: "Storage Permission Required",
                        toastLength: Toast.LENGTH_LONG,
                        timeInSecForIos: 2,
                        gravity: ToastGravity.BOTTOM,
                      );  
                    }
                  }, 
                  child: Text(
                    'Download',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                      color: Colors.white
                    ),
                  )
                )
              ],
            )
          ),
          downloadPreparing ? Container(
            color: Colors.white.withOpacity(0.85),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Preparing your download...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: 0.5
                    ),
                  )
                ],
              )
            )
          ) : Container(
            height: 0,
            width: 0
          )
        ]
      ),
    );
  }
}
