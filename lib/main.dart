import 'dart:async';
import 'package:flutter/material.dart';
import "package:pdf/routes.dart" as routes;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indian PDF Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyLandingPage(),
    );
  }
}

//###########################################################################################################//

class MyLandingPage extends StatefulWidget {
  @override
  _MyLandingPageState createState() => _MyLandingPageState();
}

class _MyLandingPageState extends State<MyLandingPage> {
  Timer timer;
  @override
  void initState(){
    timer = Timer(Duration(seconds: 3),(){
      Navigator.of(context).push(routes.start());
      setState(() {
        timer.cancel();
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top:280),
              child: Image.asset('assets/logo.png',scale:10)
            ),
            Text(
              "INDIAN PDF\nREADER",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)
            ),
            Expanded(child:Container()),
            Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Made with  "),
                  Image.asset('assets/heart.png',scale:5),
                  Text("  in India")
                ],
              )
            )
          ],
        )
      )
    );
  }
}

//###########################################################################################################//

