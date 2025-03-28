// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBGfQXCWLubvpWW9eJg91RNCpR-CrWZA-U',
    appId: '1:1009662286391:web:f3df35dfcbf2b6176d3db2',
    messagingSenderId: '1009662286391',
    projectId: 'inv-puskesmas',
    authDomain: 'inv-puskesmas.firebaseapp.com',
    databaseURL: 'https://inv-puskesmas-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'inv-puskesmas.appspot.com',
    measurementId: 'G-B8BHD47BY0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmvCarJuQg9SMkM8qcSMd7wFrqMleaAik',
    appId: '1:1009662286391:android:5cdbb5104813175d6d3db2',
    messagingSenderId: '1009662286391',
    projectId: 'inv-puskesmas',
    databaseURL: 'https://inv-puskesmas-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'inv-puskesmas.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDCOspbKATzyRY14eSOsnmtPYz81lcd2iQ',
    appId: '1:1009662286391:ios:6f0eba7cb2b33adb6d3db2',
    messagingSenderId: '1009662286391',
    projectId: 'inv-puskesmas',
    databaseURL: 'https://inv-puskesmas-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'inv-puskesmas.appspot.com',
    iosBundleId: 'com.example.adminApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDCOspbKATzyRY14eSOsnmtPYz81lcd2iQ',
    appId: '1:1009662286391:ios:6f0eba7cb2b33adb6d3db2',
    messagingSenderId: '1009662286391',
    projectId: 'inv-puskesmas',
    databaseURL: 'https://inv-puskesmas-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'inv-puskesmas.appspot.com',
    iosBundleId: 'com.example.adminApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBGfQXCWLubvpWW9eJg91RNCpR-CrWZA-U',
    appId: '1:1009662286391:web:8e565549a1b378266d3db2',
    messagingSenderId: '1009662286391',
    projectId: 'inv-puskesmas',
    authDomain: 'inv-puskesmas.firebaseapp.com',
    databaseURL: 'https://inv-puskesmas-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'inv-puskesmas.appspot.com',
    measurementId: 'G-NGTHBW0MT6',
  );
}
