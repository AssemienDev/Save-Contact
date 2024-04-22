import 'dart:io';

class AdHelper{
  static String get bannerAdUnitId{
    if(Platform.isAndroid){
      return '/6499/example/banner'; //Test Ad ID
    }else{
      throw UnsupportedError('Plateforme Inconnu');
    }
  }
}