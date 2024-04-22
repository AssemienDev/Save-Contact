import 'package:flutter/material.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:save_contact/ad_helper.dart';
import 'package:save_contact/application/changer_mdp.dart';
import 'package:save_contact/authentification/connexion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sd_flutter_easyloading/sd_flutter_easyloading.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacter;
import 'package:google_mobile_ads/google_mobile_ads.dart';


class SaveLocal extends StatefulWidget {
  const SaveLocal({super.key});

  @override
  SaveLocalState createState() => SaveLocalState();
}

class SaveLocalState extends State<SaveLocal> with TickerProviderStateMixin {
  late final TabController _tabController;
  late TextEditingController search;
  List? contacts;
  List? filteredContacts;
  List<Map<String, dynamic>> contactCloud = [];
  List<Map<String, dynamic>> filteredCloud = [];
  String? email;
  String? userId;
  List<Contact> selectedContacts = [];
  List<Map<String, dynamic>> selectedCloud = [];
  FirebaseFirestore db = FirebaseFirestore.instance;
  Map<String, Map<String, dynamic>> contactsMap = {};
  bool etat_rech = false;
  bool _dialVisible = true;
  AdManagerBannerAd? _bannerAd;
  bool _isLoaded = false;

  //ca-app-pub-9231727841147172/4943502545
  final adUnitId = '/6499/example/banner';

  /// Loads a banner ad.
  void loadAd() {
    _bannerAd = AdManagerBannerAd(
      adUnitId: adUnitId,
      request: const AdManagerAdRequest(),
      sizes: [AdSize(width: 320, height: 50)],
      listener: AdManagerBannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('AdManagerBannerAd failed to load: ${err.message}');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }



  Future<void> contactsListe() async{
    final contacts = await FastContacts.getAllContacts();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? userId = prefs.getString('userId');
    setState(() {
      this.contacts = contacts;
      this.filteredContacts = contacts;
      this.email = email;
      this.userId = userId;
    });
  }

  Future<void> contactsCloud() async {

    try {
      User? user = FirebaseAuth.instance.currentUser;


      var querySnapshot = await db.collection("users").doc(user?.uid).collection("contacts").get();


      List<Map<String, dynamic>> contactsDataList = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> contactData = doc.data() as Map<String, dynamic>;
        contactsDataList.add(contactData);
      }

      setState(() {
        this.contactCloud = contactsDataList;
        this.filteredCloud = contactsDataList;
      });


    } catch (e) {
      print('Erreur lors de la récupération des contacts depuis Firestore: $e');
    }
  }



  Future<void> _handleTabSelection() async{
    if (_tabController.index == 0) {
      search.addListener(_onSearchTextChangedLocal);
      contactsListe();
      EasyLoading.instance
        ..indicatorType = EasyLoadingIndicatorType.cubeGrid
        ..loadingStyle = EasyLoadingStyle.dark
        ..indicatorSize = 80.0
        ..radius = 10.0
        ..indicatorColor = Color.fromRGBO(21, 97, 224, 1);
      EasyLoading.show(maskType: EasyLoadingMaskType.black, dismissOnTap: false);
      setState(() {
        _tabController.index =0;
      });
      await Future.delayed(Duration(seconds: 2));
      EasyLoading.dismiss();
    }else if (_tabController.index == 1) {
      search.addListener(_onSearchTextChangeCloud);
      contactsCloud();
      EasyLoading.instance
        ..indicatorType = EasyLoadingIndicatorType.cubeGrid
        ..loadingStyle = EasyLoadingStyle.dark
        ..indicatorSize = 80.0
        ..radius = 10.0
        ..indicatorColor = Color.fromRGBO(21, 97, 224, 1);
      EasyLoading.show(maskType: EasyLoadingMaskType.black, dismissOnTap: false);
      setState(() {
        _tabController.index =1;
      });
      await Future.delayed(Duration(seconds: 2));
      EasyLoading.dismiss();
    }
  }

  void onCheckboxChangedLocal(bool value, Contact contact) {
    setState(() {
      if (value) {
        selectedContacts.add(contact);
      } else {
        selectedContacts.remove(contact);
      }
    });
  }


  void performActionLocal() async{

    for (var contact in selectedContacts) {
      User? user = FirebaseAuth.instance.currentUser;

      var contactsRef = db.collection("users").doc(user?.uid).collection("contacts");

      // Effectue une requête pour vérifier si un document avec les mêmes informations existe déjà
      var existingContact = await contactsRef
          .where('displayName', isEqualTo: contact.displayName)
          .where('phoneNumber', isEqualTo: contact.phones.first.number)
          .get();

      // Vérifie si aucun document n'a été trouvé
      if (existingContact.docs.isEmpty) {
        // Ajouter le contact uniquement s'il n'existe pas déjà
        await contactsRef.add({
          'contactId':contact.id,
          'displayName': contact.displayName,
          'phoneNumber': contact.phones.first.number,
        });
        _showSnackBar('Le contact ${contact.displayName} bien enregistré dans le cloud.', Color.fromRGBO(21, 97, 224, 1));
        await Future.delayed(Duration(seconds: 1));
        EasyLoading.dismiss();
      } else {
        // Le contact existe déjà, vous pouvez afficher un message ou prendre d'autres mesures si nécessaire
        await Future.delayed(Duration(seconds: 1));
        EasyLoading.dismiss();
        _showSnackBar('Le contact ${contact.displayName} existe déjà dans le cloud.', Colors.red);
      }
    }
    setState(() {
      selectedContacts.clear();
    });
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



  void onCheckboxChangedCloud(bool value, Map<String, dynamic> contact) {
    setState(() {
      if (value) {
        selectedCloud.add(contact);
      } else {
        selectedCloud.remove(contact);
      }
    });
  }

  Future<bool> checkIfContactExists(String displayName, String phoneNumber) async {
    // Récupérer tous les contacts
    final contacts = await FastContacts.getAllContacts();

    // Vérifier si un contact correspond au displayName et au phoneNumber
    for (var contact in contacts.toList()) {
      if (contact.displayName == displayName && contact.phones.first.number == phoneNumber) {
        return true; // Le contact existe déjà
      }
    }
    return false; // Le contact n'existe pas
  }



  void performActionCloud() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      for (var contactData in selectedCloud) {
        // Vérifier si le contact existe déjà
        bool contacte = await checkIfContactExists(contactData['displayName'],contactData['phoneNumber']);

        // Si le contact n'existe pas, l'ajouter
        if (contacte == false) {
          // Ajouter le contact
          var newContact = contacter.Contact()
            ..displayName = contactData['displayName']
            ..phones = [contacter.Phone(contactData['phoneNumber'])];
          final contactere = await contacter.FlutterContacts.openExternalInsert(newContact);

          bool contacte = await checkIfContactExists(contactData['displayName'],contactData['phoneNumber']);
          if(contacte == true){
            _showSnackBar('Le contact ${contactData['displayName']} est bien enregistré en local.', Color.fromRGBO(21, 97, 224, 1));
            await Future.delayed(Duration(seconds: 1));
            EasyLoading.dismiss();
          }else{
            // refuser le contact
            _showSnackBar('Le contact ${contactData['displayName']} n\'a pas été enregistré en local.', Colors.red);
            await Future.delayed(Duration(seconds: 1));
            EasyLoading.dismiss();
          }
        }else{
          // refuser le contact
          _showSnackBar('Le contact ${contactData['displayName']} est déjà enregistré en local.', Colors.red);
          await Future.delayed(Duration(seconds: 1));
          EasyLoading.dismiss();
        }
      }
    }

    setState(() {
      selectedCloud.clear();
    });
  }



  void performSuppCloud() async{
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      CollectionReference contactsRef = db.collection("users").doc(user.uid).collection("contacts");
      for (var contactData in selectedCloud) {
        String contactId = contactData['contactId'];

        QuerySnapshot contactSnapshot = await contactsRef.where('contactId', isEqualTo: contactId).get();
        if (contactSnapshot.docs.isNotEmpty) {

          DocumentSnapshot documentSnapshot = contactSnapshot.docs[0];

          await documentSnapshot.reference.delete();
        } else {
          print("Aucun document trouvé avec l'ID de contact spécifié.");
        }
        contactsCloud();
        await Future.delayed(Duration(seconds: 2));
        EasyLoading.dismiss();

      }
    }
    setState(() {
      selectedCloud.clear();
    });
  }


  @override
  void initState(){
    super.initState();
    loadAd();
    print("etat de la $_bannerAd");
    search = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    contactsListe();
    contactsCloud();
  }


  @override
  void dispose() {
    _tabController.dispose();
    search.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        dialogueQuiter();
        return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: etat_rech == false ? const Text(
              'Save contacts',
              style: TextStyle(color: Colors.white),
            ) : TextField(
              controller: search,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
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
            actions: [
              etat_rech == false ? IconButton(onPressed: (){
                setState(() {
                  etat_rech = true;
                });
              }
                  , icon: Icon(Icons.search), color: Colors.white,
              ): IconButton(onPressed: (){
                setState(() {
                  etat_rech = false;
                  search.clear();
                });
              }
                  , icon: Icon(Icons.clear), color: Colors.white,
              )
            ],
            backgroundColor: const Color.fromRGBO(21, 97, 224, 1),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: const Color.fromRGBO(21, 97, 224, 1),
                  tabs: const [
                    Tab(icon: Icon(Icons.phone_android, size: 30,)),
                    Tab(icon: Icon(Icons.cloud_outlined, size: 30,)),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CustomScrollView(
                      slivers: <Widget>[
                        SliverAppBar(
                          backgroundColor: Colors.white,
                          pinned: true,
                          floating: true,
                          snap: true,
                          automaticallyImplyLeading: false,
                          flexibleSpace: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                selectedContacts.length != contacts?.length ? TextButton(onPressed: (){
                                  for (var contact in contacts!) {
                                    if (!selectedContacts.contains(contact)) {
                                      setState(() {
                                        selectedContacts.add(contact);
                                      });
                                    }
                                  }
                                },
                                    child: const Text(
                                       "Tout sélectionner"
                                    )
                                ) : const Text("Tout sélectionner", style: TextStyle(color: Colors.black45),
                                ),
                                selectedContacts.isNotEmpty ? TextButton(onPressed: (){
                                  setState(() {
                                    selectedContacts.clear();
                                  });
                                },
                                    child: const Text(
                                         "Tout désélectionner"
                                    )
                                ): const Text("Tout sésélectionner", style: TextStyle(color: Colors.black45)
                                ),
                                Padding(padding: EdgeInsets.only(left: 10),
                                  child: Text("${selectedContacts.length}/${contacts?.length}"),
                                )
                              ],
                            )
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate(
                            listeContact(),
                          ),
                        ),
                      ],
                    ),
                    CustomScrollView(
                      slivers: <Widget>[
                        SliverAppBar(
                          backgroundColor: Colors.white,
                          pinned: true,
                          floating: true,
                          snap: true,
                          automaticallyImplyLeading: false,
                          flexibleSpace:Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                            child: SizedBox(
                              width: 300,
                              height: 50,
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  selectedCloud.length != contactCloud.length ? TextButton(onPressed: (){
                                    for (var contact in contactCloud) {
                                      if (!selectedCloud.contains(contact)) {
                                        setState(() {
                                          selectedCloud.add(contact);
                                        });
                                      }
                                    }
                                  },
                                      child: const Text(
                                          "Tout sélectionner"
                                      )
                                  ) : const Text("Tout sélectionner", style: TextStyle(color: Colors.black45),
                                  ),
                                  selectedCloud.isNotEmpty ? TextButton(onPressed: (){
                                    setState(() {
                                      selectedCloud.clear();
                                    });
                                  },
                                      child: const Text(
                                          "Tout désélectionner"
                                      )
                                  ): const Text("Tout sésélectionner", style: TextStyle(color: Colors.black45)
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 10),
                                    child: Text("${selectedCloud.length}/${contactCloud.length}"),
                                  )
                                ],
                              )
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate(
                            listeCloud(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_bannerAd != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 320,
                    height: 50,
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
            ],
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
                      TextButton(onPressed: changeMdp, child: Text('Changer le mot de passe', style: TextStyle(fontSize:18 ),)),
                      Divider(),
                      TextButton(onPressed: dialogueDeco, child: Text('Se déconnecter', style: TextStyle(fontSize:18 ),)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: _tabController.index ==0 ?IconButton(
            onPressed: dialogueSave ,
            icon: const Icon(Icons.upload, color: Colors.white, size: 35,),
            style: IconButton.styleFrom(
              backgroundColor: Color.fromRGBO(21, 97, 224, 1)
            ),
          ) : SpeedDial(
            backgroundColor: Color.fromRGBO(21, 97, 224, 1),
            animatedIcon: AnimatedIcons.menu_close,
            visible: _dialVisible,
            curve: Curves.bounceIn,
            foregroundColor: Colors.white,
            children: [
              SpeedDialChild(
                child: Icon(Icons.delete, color: Colors.white,),
                backgroundColor: Colors.blue,
                label: 'Supprimer',
                onTap: () {
                    dialogueDel();
                },
              ),
              SpeedDialChild(
                child: Icon(Icons.download, color: Colors.white),
                backgroundColor: Colors.blue,
                label: 'Télécharger',
                onTap: () {
                  dialogueRecup();
                },
              ),
            ],
          ),
        )
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
                const Text("Voulez vous vraiment vous déconnecter?.", textAlign: TextAlign.center,),
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



  void dialogueSave(){
    if(selectedContacts.isNotEmpty){
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sauvegarder Contact'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Voulez-vous vraiment le(s) sauvegarder?.", textAlign: TextAlign.center,),
                  Padding(padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(onPressed:(){
                            EasyLoading.instance
                              ..indicatorType = EasyLoadingIndicatorType.cubeGrid
                              ..loadingStyle = EasyLoadingStyle.dark
                              ..indicatorSize = 80.0
                              ..radius = 10.0
                              ..indicatorColor = Color.fromRGBO(21, 97, 224, 1);
                            EasyLoading.show(maskType: EasyLoadingMaskType.black, dismissOnTap: false);
                            performActionLocal();
                            Navigator.pop(context);
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
    }else{
      _showSnackBar("Veuillez selectionner au moins un contact", Colors.red);
    }
  }

  void dialogueRecup(){
    if(selectedCloud.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Récuperer Contact'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Voulez-vous vraiment le(s) recuperer?.",
                  textAlign: TextAlign.center,),
                Padding(padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(onPressed: () {
                          EasyLoading.instance
                            ..indicatorType = EasyLoadingIndicatorType.cubeGrid
                            ..loadingStyle = EasyLoadingStyle.dark
                            ..indicatorSize = 80.0
                            ..radius = 10.0
                            ..indicatorColor = Color.fromRGBO(21, 97, 224, 1);
                          EasyLoading.show(maskType: EasyLoadingMaskType.black,
                              dismissOnTap: false);
                          performActionCloud();
                          Navigator.pop(context);
                        }
                          ,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                                21, 97, 224, 1),
                          ), child: const Text('valider', style: TextStyle(
                              color: Colors.white
                          ),
                          ),
                        ),
                        TextButton(onPressed: () {
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
    }else{
      _showSnackBar("Veuillez selectionner au moins un contact", Colors.red);
    }
  }

  void dialogueDel(){
    if(selectedCloud.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Supprimer Contact'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Voulez-vous vraiment le(s) supprimer?.",
                  textAlign: TextAlign.center,),
                Padding(padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(onPressed: () {
                          EasyLoading.instance
                            ..indicatorType = EasyLoadingIndicatorType.cubeGrid
                            ..loadingStyle = EasyLoadingStyle.dark
                            ..indicatorSize = 80.0
                            ..radius = 10.0
                            ..indicatorColor = Color.fromRGBO(21, 97, 224, 1);
                          EasyLoading.show(maskType: EasyLoadingMaskType.black,
                              dismissOnTap: false);
                          performSuppCloud();
                          Navigator.pop(context);
                        }
                          ,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                                21, 97, 224, 1),
                          ), child: const Text('valider', style: TextStyle(
                              color: Colors.white
                          ),
                          ),
                        ),
                        TextButton(onPressed: () {
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
    }else{
      _showSnackBar("Veuillez selectionner au moins un contact", Colors.red);
    }
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
              const Text("Voulez vous vraiment quitter l'application?.", textAlign: TextAlign.center,),
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

  void changeMdp(){
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
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
        pageBuilder: (_, __, ___) => ChangerMdp(),
      ),
    );
  }



  void _onSearchTextChangeCloud() {
    if (search.text.isEmpty) {
      setState(() {
        filteredCloud = contactCloud;
      });
      return;
    }

    List<Map<String, dynamic>> filteredContactsData = [];

    // Filtrer les contacts et mettre à jour filteredContacts
    List<Map<String, dynamic>> filteredList = contactCloud.where((contact) {
      // Vous devez accéder aux valeurs appropriées dans la map pour effectuer la comparaison de texte
      return contact['displayName'].toString().toLowerCase().contains(search.text.toLowerCase()) ||
          contact['phoneNumber'].toString().toLowerCase().contains(search.text.toLowerCase());
    }).toList();
    setState(() {
      filteredCloud = filteredList;
    });
  }

  List<Widget> listeCloud() {
    List<Widget> contactWidgets = [];
    if (filteredCloud != null) {
      for (var contact in filteredCloud!) {
        // Ajoutez ici la logique pour afficher les contacts en fonction de la structure de votre Map
        contactWidgets.add(
          Column(
            children: [
              ListTile(
                title: Text(
                  contact['displayName'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  contact['phoneNumber'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                leading: Checkbox(
                  value: selectedCloud.contains(contact),
                  onChanged: (value) => onCheckboxChangedCloud(value ?? false, contact),
                ),
              ),
              const Divider(thickness: 1),
            ],
          ),
        );
      }
    }
    return contactWidgets;
  }



  void _onSearchTextChangedLocal() {
    if (search.text.isEmpty) {
      setState(() {
        filteredContacts = contacts;
      });
      return;
    }
    List? filteredList = contacts!.where((contact) {
      return contact.toString().toLowerCase().contains(search.text.toLowerCase());
    }).toList();
    setState(() {
      filteredContacts = filteredList;
    });
  }


  List<Widget> listeContact() {
    List<Widget> contactWidgets = [];
    if (filteredContacts != null) {
      filteredContacts!.sort((a, b) => a.displayName!.compareTo(b.displayName!));

    for (var contact in filteredContacts!) {
      if (contact.phones != null && contact.phones!.isNotEmpty) {
        for (var phone in contact.phones!) {
          contactWidgets.add(
              Column(
                children: [
                  ListTile(
                    title: Text(
                      contact.displayName ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      phone.number,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    leading: Checkbox(
                      value: selectedContacts.contains(contact),
                      onChanged: (value) => onCheckboxChangedLocal(value ?? false, contact),
                    ),
                  ),
                  const Divider(thickness: 1),
                ],
              )
          );
        }
      } else {
        // Afficher quelque chose si le contact n'a pas de numéro de téléphone
        contactWidgets.add(Container());
      }
    }
  }
  return contactWidgets;
  }


}
