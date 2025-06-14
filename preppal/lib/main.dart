import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // auth
import 'package:flutter_riverpod/flutter_riverpod.dart'; // riverpod
import 'package:firebase_app_check/firebase_app_check.dart'; // app check
import 'firebase_options.dart'; // firebase options
import 'screens/login_screen.dart'; // login
import 'screens/home_screen.dart'; // home

void main() async { // main
  WidgetsFlutterBinding.ensureInitialized(); // init flutter
  await Firebase.initializeApp( // init firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // init app check
  try {
    
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
    print('Firebase App Check activated successfully.');
  } catch (e) {
    print('Error activating Firebase App Check: $e');
  }

  runApp(
    const ProviderScope( // provider scope
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrepPal', // app title
      theme: ThemeData(
        // theme
        primaryColor: const Color(0xFF81B29A), // primary
        hintColor: const Color(0xFFF2CC8F), // secondary
        scaffoldBackgroundColor: const Color(0xFFFAF0E6), // neutral
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF81B29A), // primary
          primary: const Color(0xFF81B29A),
          secondary: const Color(0xFFF2CC8F),
          background: const Color(0xFFFAF0E6), // neutral
          surface: const Color(0xFFF5EBE0), // neutral
          onPrimary: Colors.white, // text on primary
          onSecondary: Colors.black, // text on secondary
          onBackground: const Color(0xFF3D405B), // dark text
          onSurface: const Color(0xFF3D405B), // dark text
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF81B29A), // appbar primary
          foregroundColor: Colors.white, // appbar text/icons
          titleTextStyle: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF81B29A), // button primary
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF81B29A), // primary
            foregroundColor: Colors.white, // button text
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFF2CC8F), // fab secondary
          foregroundColor: Colors.black,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          displayMedium: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          displaySmall: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          headlineLarge: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          headlineMedium: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          headlineSmall: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          titleLarge: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          titleMedium: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          titleSmall: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          bodyLarge: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          bodyMedium: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          bodySmall: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          labelLarge: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontWeight: FontWeight.bold), // button text
          labelMedium: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
          labelSmall: TextStyle(fontFamily: 'Roboto', color: Color(0xFF3D405B)),
        ).apply(
          bodyColor: const Color(0xFF3D405B),
          displayColor: const Color(0xFF3D405B),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(), // auth wrapper
    );
  }
}

// AuthWrapper: auth state listener
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen(); // logged in
        }
        return const LoginScreen(); // not logged in
      },
    );
  }
}
