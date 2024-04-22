import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_contact/information/infopage2.dart';
import 'package:dots_indicator/dots_indicator.dart';

class PageInfo1 extends StatefulWidget{
  @override
  PageInfo1State createState() => PageInfo1State();
}

class PageInfo1State extends State<PageInfo1>{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/img1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Padding(padding: EdgeInsets.only(top: 250),
                child: Text('Bienvenue sur SAVE CONTACT l’application qui vous permet sauvegarder vos contacts facilement.',
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w900
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(padding: EdgeInsets.only(left:58),
                              child: DotsIndicator(
                                dotsCount: 3,
                                position: 0,
                                decorator: DotsDecorator(
                                  spacing: EdgeInsets.only(left: 50),
                                  activeColor: Color.fromRGBO(21, 97, 224, 1),
                                  size: const Size.square(12.0),
                                  activeSize: const Size(15.0, 15.0),
                                  color: Colors.white70,
                                  activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                ),
                              )
                            )
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 60),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(onPressed: pageSuivante
                                  ,
                                style: TextButton.styleFrom(
                                  minimumSize: Size(190, 35),
                                  backgroundColor: Color.fromRGBO(21, 97, 224, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                  )
                                ), child: const Text('Suivant',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white
                                        ),
                                  ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
    );
  }

  void pageSuivante(){
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        pageBuilder: (_, __, ___) => PageInfo2(),
      ),
    );
  }
}