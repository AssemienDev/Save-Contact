import 'package:flutter/material.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:save_contact/application/home_save_local.dart';
import 'package:save_contact/information/infopage1.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:sd_flutter_easyloading/sd_flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gh_asset_pre_cache/gh_asset_pre_cache.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  GhAssetPreCache().startImageCache();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save Contacts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(21, 97, 224, 1)),
        useMaterial3: true,
      ),
      home: MyHomePage(),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? userId;

  void precacheImageS() {
    GhAssetPreCache().startImageCache();
  }

  Future<void> verif() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    setState(() {
      userId = userId;
    });

    var status = await Permission.contacts.status;
    if (status.isGranted) {
      print("Contact Permission Granted");
    } else {
      await Permission.contacts.request();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImages();
  }

  void precacheImages() {
    precacheImage(AssetImage('images/img1.jpg'), context);
    precacheImage(AssetImage('images/img2.jpg'), context);
    precacheImage(AssetImage('images/img3.jpg'), context);
    precacheImage(AssetImage('images/logo.png'), context);
  }

  @override
  void initState() {
    super.initState();
    verif();
    precacheImageS();
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset('images/logo.png'),
      showLoader: false,
      navigator: userId == null ? PageInfo1() : SaveLocal(),
      durationInSeconds: 6,
    );
  }
}
