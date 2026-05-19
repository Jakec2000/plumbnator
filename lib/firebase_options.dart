import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Secure, decoupled Firebase configuration resolver for Plumbnator QLD.
class DefaultFirebaseOptions {
  /// Returns the configured options for the active target platform.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  /// Web configuration options.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY', defaultValue: 'dummy-web-api-key-12345'),
    appId: '1:450892:web:78a3b092',
    messagingSenderId: '450892',
    projectId: 'plumbnator-qld-sandbox',
    authDomain: 'plumbnator-qld-sandbox.firebaseapp.com',
    storageBucket: 'plumbnator-qld-sandbox.appspot.com',
  );

  /// Android configuration options.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY', defaultValue: 'dummy-android-api-key-12345'),
    appId: '1:450892:android:90d1f92e',
    messagingSenderId: '450892',
    projectId: 'plumbnator-qld-sandbox',
    storageBucket: 'plumbnator-qld-sandbox.appspot.com',
  );

  /// iOS configuration options.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY', defaultValue: 'dummy-ios-api-key-12345'),
    appId: '1:450892:ios:12c0a98f',
    messagingSenderId: '450892',
    projectId: 'plumbnator-qld-sandbox',
    storageBucket: 'plumbnator-qld-sandbox.appspot.com',
    iosBundleId: 'com.plumbnator.qld',
  );

  /// Windows configuration options.
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WINDOWS_API_KEY', defaultValue: 'dummy-windows-api-key-12345'),
    appId: '1:450892:windows:88e0b02d',
    messagingSenderId: '450892',
    projectId: 'plumbnator-qld-sandbox',
    storageBucket: 'plumbnator-qld-sandbox.appspot.com',
  );
}
