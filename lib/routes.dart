import 'package:flutter/widgets.dart';
import 'package:pdf/read.dart';
import 'package:pdf/start.dart';

Route<Object> start() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MyStartPage(),         
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
              new Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .animate(animation),
          child: new SlideTransition(
            position: new Tween<Offset>(
                    begin: Offset.zero, end: const Offset(1.0, 0.0))
                .animate(secondaryAnimation),
            child: child,
          ),
        );
      },
    );
  }

Route<Object> read(String filepath,int totalPages,int after, int pause, bool blueLight) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MyReaderPage(filepath,totalPages,after,pause,blueLight),         
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
              new Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .animate(animation),
          child: new SlideTransition(
            position: new Tween<Offset>(
                    begin: Offset.zero, end: const Offset(1.0, 0.0))
                .animate(secondaryAnimation),
            child: child,
          ),
        );
      },
    );
  }