import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_contact/authentification/connexion.dart';
import 'package:save_contact/information/infopage2.dart';
import 'package:dots_indicator/dots_indicator.dart';

class PageInfo3 extends StatefulWidget{
  @override
  PageInfo3State createState() => PageInfo3State();
}

class PageInfo3State extends State<PageInfo3>{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/img3.jpg'),
                fit: BoxFit.cover
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Padding(padding: EdgeInsets.only(top: 250),
              child: Text('Vos contacts sont en lieu sûr, la sécurité est notre priorité.',
                style: TextStyle(
                    fontSize: 24,
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
                          Padding(padding: EdgeInsets.only(left: 58),
                              child: DotsIndicator(
                                dotsCount: 3,
                                position: 2,
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
                      Padding(padding: EdgeInsets.only(top: 40),
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
                              ), child: const Text('Commencer',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 30),
                              child:  TextButton(onPressed: pagePrecedent
                                ,
                                style: TextButton.styleFrom(
                                    minimumSize: Size(190, 35),
                                    backgroundColor: Color.fromRGBO(21, 97, 224, 1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    )
                                ), child: const Text('Précédent',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white
                                  ),
                                ),
                              ),
                            )
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
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;

            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        pageBuilder: (_, __, ___) => Connexion(),
      ),
    );
  }

  void pagePrecedent(){
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