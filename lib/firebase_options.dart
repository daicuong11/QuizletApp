// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAdG5MIxX5OX6DA3zP7z9Jf9LXcxY1Cz10',
    appId: '1:571950535063:web:d1d11aa3c2d9a9ade834d2',
    messagingSenderId: '571950535063',
    projectId: 'finalflutter-1f345',
    authDomain: 'finalflutter-1f345.firebaseapp.com',
    storageBucket: 'finalflutter-1f345.appspot.com',
    measurementId: 'G-M4GETHXRP6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA7rmnIhY7nhd8a-oaQnFirdFJKg-yoEUU',
    appId: '1:571950535063:android:cd039bc217cc5f64e834d2',
    messagingSenderId: '571950535063',
    projectId: 'finalflutter-1f345',
    storageBucket: 'finalflutter-1f345.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAI5JNGwm2GnQ98tYHQmI2d6vxTs_-8_WI',
    appId: '1:571950535063:ios:bdfb02486f283ec5e834d2',
    messagingSenderId: '571950535063',
    projectId: 'finalflutter-1f345',
    storageBucket: 'finalflutter-1f345.appspot.com',
    iosClientId: '571950535063-stkmc0vn5m47gjjavab7e9mr6iujl1it.apps.googleusercontent.com',
    iosBundleId: 'com.example.quizletflutterapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAI5JNGwm2GnQ98tYHQmI2d6vxTs_-8_WI',
    appId: '1:571950535063:ios:9ba5dd4528846c93e834d2',
    messagingSenderId: '571950535063',
    projectId: 'finalflutter-1f345',
    storageBucket: 'finalflutter-1f345.appspot.com',
    iosClientId: '571950535063-r4jp3k0ab9cb1sv6g3opdluut62vengk.apps.googleusercontent.com',
    iosBundleId: 'com.example.quizletflutterapp.RunnerTests',
  );
}
