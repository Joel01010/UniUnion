import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
        throw UnsupportedError('macOS is not configured.');
      case TargetPlatform.windows:
        throw UnsupportedError('Windows is not configured.');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux is not configured.');
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  // Android configuration from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAxl4DxXr8T04pY1AMp9Zz3A8lV4Oos3bg',
    appId: '1:791985764276:android:9a5571028e331c62fa24e1',
    messagingSenderId: '791985764276',
    projectId: 'uniunion-1c239',
    storageBucket: 'uniunion-1c239.firebasestorage.app',
  );

  // iOS configuration - needs to be configured via flutterfire
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAxl4DxXr8T04pY1AMp9Zz3A8lV4Oos3bg',
    appId: '1:791985764276:ios:placeholder', // Need actual iOS app ID
    messagingSenderId: '791985764276',
    projectId: 'uniunion-1c239',
    storageBucket: 'uniunion-1c239.firebasestorage.app',
    iosBundleId: 'com.vitchennai.vitChennaiStudentUtility',
  );

  // Web configuration from Firebase Console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBTspYlYcecISsizE8NARckppuCHv5N3rE',
    appId: '1:791985764276:web:b0d6cbcda39ce8defa24e1',
    messagingSenderId: '791985764276',
    projectId: 'uniunion-1c239',
    storageBucket: 'uniunion-1c239.firebasestorage.app',
    authDomain: 'uniunion-1c239.firebaseapp.com',
    measurementId: 'G-P9GLHVXJ87',
  );
}
