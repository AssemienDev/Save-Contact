import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:save_contact/authentification/connexion.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sd_flutter_easyloading/sd_flutter_easyloading.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';


class Inscription extends StatefulWidget{

  @override
  InscriptionState createState() => InscriptionState();
}
class InscriptionState extends State<Inscription>{

  late TextEditingController email;
  late TextEditingController passe;
  late TextEditingController verifPasse;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseFirestore db = FirebaseFirestore.instance;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    email = TextEditingController();
    passe = TextEditingController();
    verifPasse = TextEditingController();
  }

  @override
  void dispose() {
    email.dispose();
    passe.dispose();
    verifPasse.dispose();
    super.dispose();
  }

  Future<void> faireInscription() async{

    bool result = await InternetConnectionChecker().hasConnection;
    if(result==true) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: email.text,
            password: passe.text
        );
        String uid = userCredential.user!.uid;
        await db.collection("users").doc(uid).collection("contacts").add({
          'displayName': "",
          'phoneNumber': "",
        });
        await Future.delayed(Duration(seconds: 6));
        EasyLoading.dismiss();
        dialogueAlerte();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          await Future.delayed(Duration(seconds: 2));
          EasyLoading.dismiss();
          _showSnackBar("Le mot de passe est trop faible");
        } else if (e.code == 'email-already-in-use') {
          await Future.delayed(Duration(seconds: 2));
          EasyLoading.dismiss();
          _showSnackBar("C'est email est déjà utilisé par un autre compte");
        } else {
          EasyLoading.dismiss();
          _showSnackBar("Veuillez verifier vos informations de connexion");
        }
      }
    }else{
      _showSnackBar("Veuillez verifier votre connexion internet");
    }
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: FadeInUp(
            child: Text(message, style: const TextStyle(
                color: Colors.white
              ),
            ),
          ),
          backgroundColor: const Color.fromRGBO(255, 2, 2, 1),
        ),
    );
  }

  void dialogueAlerte(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Inscription Valider'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Text("Inscription réussie vous allez être redirigés vers la page de connexion en cliquant sur compris.", textAlign: TextAlign.center,),
                Padding(padding: EdgeInsets.only(top: 20),
                child: TextButton(onPressed: connexion
                  , child: Text('Compris', style: TextStyle(
                    color: Colors.white
                ),
                ),
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromRGBO(21, 97, 224, 1),
                  ),
                ),
                )
            ],
          ),
        );
      },
    );
  }


  void verifier_passse(){
    if(email.text.isNotEmpty && passe.text.isNotEmpty && verifPasse.text.isNotEmpty){
      if(EmailValidator.validate(email.text)){
        if(verifPasse.text == passe.text){
          faireInscription();
        }else{
          EasyLoading.dismiss();
          _showSnackBar("Vérifie mot de passe est différent du mot de passe");
        }
      }else{
        EasyLoading.dismiss();
        _showSnackBar("Email invalide");
      }
    }else{
      EasyLoading.dismiss();
      _showSnackBar("Espace de saisie vide");
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const  Padding(padding: EdgeInsets.only(top: 80),
              child:  Text(
                'S\'inscrire',
                style: TextStyle(
                    color: Color.fromRGBO(21, 97, 224, 1),
                    fontWeight: FontWeight.w900,
                    fontSize: 30
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width-80),
                    child: const Text('Email',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 97, 224, 1),
                          fontWeight: FontWeight.w900
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width-60,
                        height: 50,
                        child: TextFormField(
                          controller: email,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(top: 1),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(21, 97, 224, 1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(21, 97, 224, 1)),
                            ),
                          ),
                        ),
                      )
                  )
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 60),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width-135),
                    child: const Text('Mot de passe',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 97, 224, 1),
                          fontWeight: FontWeight.w900
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width-60,
                        height: 50,
                        child: TextFormField(
                          controller: passe,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(top: 1),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(21, 97, 224, 1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(21, 97, 224, 1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(21, 97, 224, 1)),
                            ),
                          ),
                        ),
                      )
                  ),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 60),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width-195),
                    child: const Text('Confirmer mot de passe',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 97, 224, 1),
                          fontWeight: FontWeight.w900
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width-60,
                        height: 50,
                        child: TextFormField(
                          controller: verifPasse,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(top: 1),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(21, 97, 224, 1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(21, 97, 224, 1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(21, 97, 224, 1)),
                            ),
                          ),
                        ),
                      )
                  ),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 45),
              child: TextButton(onPressed: (){
                EasyLoading.instance
                  ..indicatorType = EasyLoadingIndicatorType.cubeGrid
                  ..loadingStyle = EasyLoadingStyle.dark
                  ..indicatorSize = 80.0
                  ..radius = 10.0
                  ..indicatorColor = Color.fromRGBO(21, 97, 224, 1);
                EasyLoading.show(maskType: EasyLoadingMaskType.black, dismissOnTap: false);
                verifier_passse();
              }
                ,
                style: TextButton.styleFrom(
                    minimumSize: Size(180, 35),
                    backgroundColor: Color.fromRGBO(21, 97, 224, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)
                    )
                ), child: const Text('INSCRIPTION',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Avez-vous déjà un compte?',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  TextButton(onPressed: connexion,
                    child: const Text(
                      'Connectez-vous',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 97, 224, 1),
                          fontSize: 14
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ), onWillPop: () async {
      dialogueQuiter();
      return false;
    }
    );
  }

  void dialogueQuiter(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quitter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Voulez vous vraiement quitter l'application?.", textAlign: TextAlign.center,),
              Padding(padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(onPressed:(){
                        SystemNavigator.pop();
                      }
                        ,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(21, 97, 224, 1),
                        ), child: const Text('valider', style: TextStyle(
                            color: Colors.white
                        ),
                        ),
                      ),
                      TextButton(onPressed:(){
                        Navigator.pop(context);
                      }
                        ,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                        ), child: const Text('annuler', style: TextStyle(
                            color: Colors.white
                        ),
                        ),
                      ),
                    ],
                  )
              )
            ],
          ),
        );
      },
    );
  }

  void connexion(){
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, _, child) {
          var begin = Offset(-1.0, 0.0);
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
}