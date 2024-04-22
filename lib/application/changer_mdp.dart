import 'package:flutter/material.dart';
import 'package:save_contact/application/home_save_local.dart';
import 'package:save_contact/authentification/connexion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sd_flutter_easyloading/sd_flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ChangerMdp extends StatefulWidget{
  @override
  ChangeMdpState createState() => ChangeMdpState();
}

class ChangeMdpState extends State<ChangerMdp>{

  late TextEditingController anciensPasse;
  late TextEditingController nouveauPasse;
  late TextEditingController confirmePasse;
  String? email;
  String? passeCode;

  Future<void> recupMail() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? passe = prefs.getString('passe');
    setState(() {
      this.email = email;
      this.passeCode = passe;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    anciensPasse = TextEditingController();
    nouveauPasse = TextEditingController();
    confirmePasse = TextEditingController();
    recupMail();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    anciensPasse.dispose();
    nouveauPasse.dispose();
    confirmePasse.dispose();
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

  Future<void> updatePasse() async{
    try{
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(nouveauPasse.text);
        prefs.setString('passe', nouveauPasse.text);
        EasyLoading.dismiss();
        save_local_home();
      } else {
        _showSnackBar("Veuillez vous connecter d'abord");
      }
    }on FirebaseAuthException catch(e){
      if(e.code =='weak-password'){
        await Future.delayed(Duration(seconds: 2));
        EasyLoading.dismiss();
        _showSnackBar("Le mot de passe est trop faible");
      }else{
        EasyLoading.dismiss();
        _showSnackBar("Veuillez verifier que vous êtes connecté a internet.");
      }
    }
  }

  void verifier_passse(){
    print(passeCode);
    if(anciensPasse.text.isNotEmpty && nouveauPasse.text.isNotEmpty && confirmePasse.text.isNotEmpty){
      if(anciensPasse.text == passeCode){
        if(nouveauPasse.text == confirmePasse.text){
          updatePasse();
        }else{
          EasyLoading.dismiss();
          _showSnackBar("Vérifie le nouveau mot de passe est différent de confirme passe");
        }
      }else{
        EasyLoading.dismiss();
        _showSnackBar("Anciens mot de passe incorrect");
      }
    }else{
      EasyLoading.dismiss();
      _showSnackBar("Espace de saisie vide");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Save contacts',
              style: TextStyle(color: Colors.white),
            ),
            leading:  Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            backgroundColor: const Color.fromRGBO(21, 97, 224, 1),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const  Padding(padding: EdgeInsets.only(top: 60, left: 22),
                  child:  Text(
                    'Changer le mot de passe',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(21, 97, 224, 1),
                        fontWeight: FontWeight.w900,
                        fontSize: 25
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 40, left: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width-200),
                        child: const Text('Anciens mot de passe',
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
                              obscureText: true,
                              controller: anciensPasse,
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
                Padding(padding: EdgeInsets.only(top: 40, left: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width-200),
                        child: const Text('Nouveau Mot de passe',
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
                              controller: nouveauPasse,
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
                Padding(padding: EdgeInsets.only(top: 40, left: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width-270),
                        child: const Text('Confirmer nouveau mot de passe',
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
                              controller: confirmePasse,
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
                Padding(padding: EdgeInsets.only(top: 50, left: 20),
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
                    ), child: const Text('VALIDER',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          drawer: Drawer(
            elevation: 16.0,
            semanticLabel: 'Drawer',
            child: Container(
              color: Color.fromRGBO(21, 97, 224, 1),
              child: SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 220,
                        color: Color.fromRGBO(21, 97, 224, 1),
                        child: Column(
                          children: [
                            Icon(Icons.person, color: Colors.white,size: 180,),
                            Text('${this.email!=null ? this.email : ''}',
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            )
                          ],
                        ),
                      ),
                      TextButton(onPressed: save_local_home, child: Text('Acceuil', style: TextStyle(fontSize:18 ),)),
                      Divider(),
                      TextButton(onPressed: dialogueDeco, child: Text('Se déconnecter', style: TextStyle(fontSize:18 ),)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        onWillPop: () async {
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

  void dialogueDeco(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion.'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Voulez vous vraiement vous déconnecter?.", textAlign: TextAlign.center,),
              Padding(padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(onPressed:() async{
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.remove('email');
                        prefs.remove('passe');
                        prefs.remove('userId');
                        Navigator.pop(context);
                        await FirebaseAuth.instance.signOut();
                        connexion();
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