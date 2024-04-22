import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:save_contact/application/home_save_local.dart';
import 'package:save_contact/authentification/inscription.dart';
import 'package:email_validator/email_validator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sd_flutter_easyloading/sd_flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';


class Connexion extends StatefulWidget{

  @override
  ConnexionState createState() => ConnexionState();
}
class ConnexionState extends State<Connexion>{

  late TextEditingController email;
  late TextEditingController passe;
  late TextEditingController mailOublier;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    email = TextEditingController();
    passe = TextEditingController();
    mailOublier = TextEditingController();
  }

  @override
  void dispose() {
    email.dispose();
    passe.dispose();
    mailOublier.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const  Padding(padding: EdgeInsets.only(top: 100),
              child:  Text(
                'Se connecter',
                style: TextStyle(
                    color: Color.fromRGBO(21, 97, 224, 1),
                    fontWeight: FontWeight.w900,
                    fontSize: 30
                ),
              ),
            ),

            /*Email*/
            Padding(padding: EdgeInsets.only(top: 78),
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
                  Padding(padding: EdgeInsets.only(top: 15),
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

            /*Password*/
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
                  Padding(padding: EdgeInsets.only(top: 15),
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
                  )
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Mot de passe oublié?',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  TextButton(onPressed: dialogueAlerte,
                    child: const Text(
                      'Cliquer ici',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 97, 224, 1),
                          fontSize: 14
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 30),
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
                ), child: const Text('CONNEXION',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('N\'avez-vous pas de compte?',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  TextButton(onPressed: inscription,
                    child: const Text(
                      'Inscrivez-vous',
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


  void verifier_passse(){
    if(email.text.isNotEmpty && passe.text.isNotEmpty){
      if(EmailValidator.validate(email.text)){
          traiteConnexion();
      }else{
        EasyLoading.dismiss();
        _showSnackBar("Email invalide", Color.fromRGBO(255, 2, 2, 1));
      }
    }else{
      EasyLoading.dismiss();
      _showSnackBar("Espace de saisie vide", Color.fromRGBO(255, 2, 2, 1));
    }
  }


  void dialogueAlerte(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mot de passe oublié.'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Veuillez entrer votre email, vous allez recevoir un lien.", textAlign: TextAlign.center,),
                  TextFormField(
                    controller: mailOublier,
                  ),
                  Padding(padding: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(onPressed:(){
                          Navigator.pop(context);
                          passeOublierFunc();
                        }
                          ,
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromRGBO(21, 97, 224, 1),
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

  void save_local_home(){
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, _, child) {
          var begin = Offset(0.0, -1.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        pageBuilder: (_, __, ___) => SaveLocal(),
      ),
    );
  }


  Future<void> traiteConnexion() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = await InternetConnectionChecker().hasConnection;
    if(result==true){
      try{
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.text,
            password: passe.text
        );
        await prefs.setString('email',email.text);
        await prefs.setString('passe',passe.text);
        await prefs.setString('userId', userCredential.user!.uid);
        await Future.delayed(Duration(seconds: 5));
        EasyLoading.dismiss();
        save_local_home();
      }on FirebaseAuthException catch(e){
        String errorMessage = "Une erreur s'est produite lors de la connexion";
        if (e.code == 'user-not-found') {
          errorMessage = "Aucun utilisateur trouvé avec cet e-mail";
        } else if (e.code == 'invalid-credential') {
          errorMessage = "Mot de passe incorrect";
        }else{
          errorMessage = "Veuillez verifier vos informations de connexion";
        }
        EasyLoading.dismiss();
        _showSnackBar(errorMessage, Color.fromRGBO(21, 97, 224, 1));
      }
    }else{
      _showSnackBar("Veuillez verifier votre connexion internet", Colors.red);
    }

  }


  Future<void> passeOublierFunc() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if(result==true){
      try {

        var signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(mailOublier.text);

        if (signInMethods.isEmpty) {
          _showSnackBar("Aucun utilisateur trouvé avec cet e-mail.", Color.fromRGBO(255, 2, 2, 1));
          return;
        }
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: mailOublier.text,
        );
        mailOublier.text = "";
        _showSnackBar("Un lien vous a été envoyé", Color.fromRGBO(21, 97, 224, 1));
      } on FirebaseAuthException catch(e) {
        _showSnackBar("Une erreur s'est produite lors de l'envoi de l'e-mail de réinitialisation.", Color.fromRGBO(255, 2, 2, 1));
      }
    }else{
      _showSnackBar("Veuillez verifier votre connexion internet", Colors.red);
    }
  }



  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: FadeInUp(
          child: Text(message, style: const TextStyle(
              color: Colors.white
          ),
          ),
        ),
        backgroundColor: color,
      ),
    );
  }


  void inscription(){
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
        pageBuilder: (_, __, ___) => Inscription(),
      ),
    );
  }
}