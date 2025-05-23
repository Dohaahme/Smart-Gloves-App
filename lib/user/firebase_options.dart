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
    apiKey: 'AIzaSyBLBo8XH-DcAWU72eM81t4vi4gFd7JMejA',
    appId: '1:446279012895:web:b31ca3f422577df3813b2a',
    messagingSenderId: '446279012895',
    projectId: 'gproject-cbcd2',
    authDomain: 'gproject-cbcd2.firebaseapp.com',
    databaseURL: 'https://gproject-cbcd2-default-rtdb.firebaseio.com',
    storageBucket: 'gproject-cbcd2.appspot.com',
    measurementId: 'G-X0VR1K8J8F',


  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBdRHY7V0ZEvbdQ338JFFcaZGnl-osYpSo',
    appId: '1:446279012895:android:16669cf9c503a4bb813b2a',
    messagingSenderId: '446279012895',
    projectId: 'gproject-cbcd2',
    storageBucket: 'gproject-cbcd2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDMhypsNY6dkc4vJoMGEQAaB6xRy-C-Qb4',
    appId: '1:446279012895:ios:957068c721a2fed7813b2a',
    messagingSenderId: '446279012895',
    projectId: 'gproject-cbcd2',
    storageBucket: 'gproject-cbcd2.appspot.com',
    iosBundleId: 'com.example.testGproject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDMhypsNY6dkc4vJoMGEQAaB6xRy-C-Qb4',
    appId: '1:446279012895:ios:957068c721a2fed7813b2a',
    messagingSenderId: '446279012895',
    projectId: 'gproject-cbcd2',
    storageBucket: 'gproject-cbcd2.appspot.com',
    iosBundleId: 'com.example.testGproject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBLBo8XH-DcAWU72eM81t4vi4gFd7JMejA',
    appId: '1:446279012895:web:a7d597f3d4fa1445813b2a',
    messagingSenderId: '446279012895',
    projectId: 'gproject-cbcd2',
    authDomain: 'gproject-cbcd2.firebaseapp.com',
    storageBucket: 'gproject-cbcd2.appspot.com',
    measurementId: 'G-91NRSW7ECR',
  );
}
