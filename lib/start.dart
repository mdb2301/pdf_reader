import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'routes.dart' as routes;


class MyStartPage extends StatefulWidget {
  @override
  _MyStartPageState createState() => _MyStartPageState();
}

class _MyStartPageState extends State<MyStartPage> {
  String filepath; PDFDocument doc; int group,after,pause,totalPages; bool blueLight;
  
  @override
  void initState() {
    blueLight = false;
    group = 1;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
  }
  
  select(val){
    setState(() {
      group = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            height: 550,
            child: Card(
              elevation: 8,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(30),
                    child: Text("Select Reading Mode",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 22)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: <Widget>[
                        Radio(value:1,groupValue: group, onChanged:select),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Pomodoro Mode",style:TextStyle(fontSize: 18)),
                            Text("Break after every 25 minutes")
                          ],
                        )
                      ],
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: <Widget>[
                        Radio(value:2,groupValue: group, onChanged:select),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("57/17 Mode",style:TextStyle(fontSize: 18)),
                            Text("Break after every 57 minutes")
                          ],
                        )
                      ],
                    )
                  ),
                  SizedBox(height:30),
                  Padding(
                    padding: EdgeInsets.only(left:20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width:70,height:70,
                          decoration: BoxDecoration(
                            color: blueLight ? Colors.blue[200] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(35)
                          ),
                          child: MaterialButton(
                            onPressed: change,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Icon(Icons.brightness_6)
                                )
                              ],
                            )
                          )
                        ),
                        Padding(
                          padding: EdgeInsets.only(left:20),
                          child: Text("Blue-Light Filter",style: TextStyle(fontWeight: FontWeight.bold))
                        )
                      ],
                    )
                  ),
                  SizedBox(height:20),
                  MaterialButton(
                    onPressed: getFile,
                    child: Text("Get Started",style: TextStyle(color:Colors.white)),
                    color: Colors.black,
                    elevation: 5,
                    height: 45
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:40),
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color:Colors.blue),
                        borderRadius: BorderRadius.circular(30)
                      ),
                      child: MaterialButton(
                        onPressed: launchPlayStore,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.share,color: Colors.blue),
                            Padding(
                              padding: EdgeInsets.only(left:20),
                              child: Text("Share App",style:TextStyle(fontSize: 15,color:Colors.blue))
                            )
                          ],
                        )
                      )
                    )
                  )
                ],
              )
            )
          )
        )
      )
    );
  }

  launchPlayStore() async {
    const url = "https://play.google.com/store/apps/details?id=com.alone_wolf_production.pdf_reader";
    if(await canLaunch(url)){
      await launch(url);
    } else {
      print("Error occured");
    }
  }

  change(){
    setState(() {
      blueLight = !blueLight;
    });
  }

  getFile() async {
    if(group==1){
      setState(() {
        after = 25;
        pause = 5;
      });
    } else {
      setState(() {
        after = 57;
        pause = 17;
      });
    }

    var path = await FilePicker.getFilePath(type: FileType.custom,allowedExtensions: ['pdf']);
    setState(() {
      filepath = path;
    });
    if(filepath != null){
      PDFDocument doc = await PDFDocument.fromFile(File(filepath));
      setState(() {
        totalPages = doc.count;
      });
      Navigator.of(context).push(routes.read(filepath,totalPages,after,pause,blueLight));
    }
  }
}