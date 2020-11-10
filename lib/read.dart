import 'dart:async';
import 'dart:io';
import "routes.dart" as routes;
import "page.dart" as mypage;
import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:url_launcher/url_launcher.dart';

class MyReaderPage extends StatefulWidget {
  final String filepath;
  final int totalPages,after,pause;
  final bool blueLight;

  MyReaderPage(this.filepath, this.totalPages, this.after, this.pause, this.blueLight);
  @override
  _MyReaderPageState createState() => _MyReaderPageState();
}

class _MyReaderPageState extends State<MyReaderPage> {
  String filepath;
  int totalPages,after,pause,currentPage;
  bool blueLight,isOnePage;
  PDFViewController controller;
  Widget adBox; Orientation lastOrientation;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lastOrientation = MediaQuery.of(context).orientation;
    });
    filepath = widget.filepath;
    totalPages = widget.totalPages;
    after = widget.after;
    pause = widget.pause;
    blueLight = widget.blueLight;
    currentPage = mypage.currentPage != null ? mypage.currentPage : 0;
    isOnePage = totalPages == 1;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight]);
    loadAd();
    super.initState();
  }

  takeBreak(Timer timer){
    return showDialog(
        context: context,
        builder: (context){
          return Dialog(
            child: Container(
              height: 200,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Icon(Icons.timer,size:40)
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Take a break of $pause minutes\n(Drink some water/Stretch your body/Visualize)",style: TextStyle(fontSize:20))
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: adBox
                  )
                ],
              )
            )
          );
        }
      );
  }

  repushViewer() {
    mypage.currentPage = currentPage;
    Navigator.of(context).pushReplacement(routes.read(filepath,totalPages,after,pause,blueLight));
  }

  @override
  Widget build(BuildContext context) {
    Timer.periodic(Duration(minutes: after),takeBreak);

    if(lastOrientation != null && lastOrientation != MediaQuery.of(context).orientation){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        repushViewer();
      });
    }

    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
          onWillPop: back,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(255,77,77,1),
              title: Text((filepath.split('/').last)),
              automaticallyImplyLeading: false,
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: next,
                  itemBuilder: (BuildContext context)=><PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: '1',
                      child: ListTile(
                        contentPadding: EdgeInsets.only(top:1,bottom:1),
                        trailing: Icon(Icons.brightness_6),
                        title: Text("Dark Mode On/Off")
                      )
                    ),
                    PopupMenuItem<String>(
                      value: '2',
                      child: ListTile(
                        contentPadding: EdgeInsets.only(top:1,bottom:1),
                        trailing: Icon(Icons.info),
                        title: Text("About")
                      )
                    ),
                  ],
                )
              ],
            ),
            body: ColorFiltered(
              colorFilter: blueLight ? ColorFilter.mode(Colors.red[100],BlendMode.darken) : ColorFilter.mode(Colors.transparent, BlendMode.darken),
              child: Stack(
                  children: <Widget>[
                    PDFView(
                      filePath: filepath,
                      defaultPage: currentPage,
                      onPageChanged: changed,
                      onViewCreated: created,
                      swipeHorizontal: true,
                    ),
                    Positioned(
                      bottom:10,
                      left: MediaQuery.of(context).orientation == Orientation.portrait ? width/6.7 : width/4,
                      child: Visibility(
                          visible: !isOnePage,
                          child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right:width/8),
                                  child: GestureDetector(
                                    child: Icon(Icons.first_page),
                                    onTap: firstPage
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right:width/24),
                                  child: GestureDetector(
                                    child: Icon(Icons.arrow_back_ios),
                                    onTap: previousPage
                                  ),
                                ),
                                GestureDetector(
                                  child: Container(
                                    width: 60, height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Color.fromRGBO(255,77,77,1)
                                    ),
                                    child: Icon(Icons.view_carousel,color:Colors.white)
                                  ),
                                  onTap: pickPage,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left:width/24),
                                  child: GestureDetector(
                                    child: Icon(Icons.arrow_forward_ios),
                                    onTap: nextPage
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left:width/8),
                                  child: GestureDetector(
                                    child: Icon(Icons.last_page),
                                    onTap: lastPage
                                  ),
                                )
                              ],
                            ),
                          )
                        ),
                  ],
                )
            )
        )
    ); 
  }

  previousPage(){
    setState(() {
      currentPage = currentPage - 1;
      controller.setPage(currentPage);
    });
  }

  nextPage(){
    setState(() {
      currentPage = currentPage + 1;
      controller.setPage(currentPage);
    });
  }

  firstPage(){
    setState(() {
      currentPage = 0;
      controller.setPage(0);
    });
  }

  lastPage(){
    setState(() {
      currentPage = totalPages - 1;
      controller.setPage(totalPages - 1);
    });
  }

  created(PDFViewController ctrl){
    setState(() {
      controller = ctrl;
    });
  }

  changed(int current,int total){
    setState(() {
      currentPage = current;
    });
  }

  pickPage(){
    showDialog<int>(
      context: context,
      builder: (BuildContext context){
        return NumberPickerDialog.integer(
          title: Text("Jump to page"),
          minValue: 1, 
          maxValue: totalPages, 
          initialIntegerValue: currentPage + 1);
      }
    ).then((int value){
      if(value != null){
        setState(() {
          controller.setPage(value - 1);
        });
      }
    });
  }

  next(String value){
    if(value == '1'){
      setState(() {
        blueLight = !blueLight;
      });
    } else {
      showAboutDialog(
        context: context,
        applicationIcon: Image.asset('assets/logo.png',scale:15),
        applicationVersion: '1.1.0',
        children: [
          Text("Let's support Made in India"),
          SizedBox(height:20),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Founder:"),
                    Text("Akshay Narwade")
                  ],
                ),
                Expanded(child:Container()),
                MaterialButton(
                  onPressed: launchInsta,
                  child: Image.asset('assets/insta.png',scale:15)
                )
              ],
            )
          ),
        ]
      );
    }
  }

  launchInsta() async {
    const url = "https://www.instagram.com/alonewolf_v2.0/?igshid=dkrfzt5xb39b";
    if(await canLaunch(url)){
      await launch(url);
    }else{
      print("Error occured");
    }
  }

  Future<bool> back() async {
    return (await showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Exit app?"),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                exit(0);
              },
              child: Text("Yes")
            ),
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("No")
            )
          ],
          content: adBox,
        );
      }
      )
    );
  }

  loadAd(){
    setState(() {
      adBox = FacebookBannerAd(
        placementId: "811271466309066_811837129585833",
        bannerSize: BannerSize.STANDARD,
        listener: (result,value){
          print("Result: $result \n Value: $value \n\n");
        },
      );
    });
  }
}