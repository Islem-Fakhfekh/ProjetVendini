import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vendini/pages/connexion.dart';
import 'package:vendini/pages/paiement.dart';
import 'package:vendini/pages/vendeur.dart';
import 'firebase_options.dart'; // Ensure this file is generated and up to date
import 'package:vendini/pages/favoris.dart'; // Import FavorisPage
import 'package:vendini/pages/splash_screen.dart';
import 'package:vendini/pages/welcome_screen.dart';
import 'package:vendini/pages/threepage.dart';
import 'package:vendini/pages/fourpage.dart';
import 'package:vendini/pages/fivepage.dart';
import 'package:vendini/pages/sixpage.dart';
import 'package:vendini/pages/panier.dart';
import 'package:vendini/pages/post.dart'; // Example: add a product
import 'package:vendini/pages/history.dart'; // Uncomment if this page is implemented
import 'package:vendini/pages/infprod.dart'; // Uncomment if this page is implemented
import 'package:vendini/pages/profil.dart'; // Import ProfilePage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vendini',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Initial home page
      routes: {
        '/favoris': (context) => const FavorisPage(),
        '/profil': (context) {
          final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID
          return ProfilPage(userId: userId!); // Pass the userId to ProfilPage
        },
        '/vendeur': (context) => const VendeurPage(), // Ensure this matches your VendeurPage class
        '/infoProd': (context) => const Infprod(), // Ensure this matches your Infprod class
        '/addProduct': (context) => const AddProductPage(), // Route for adding a product
        '/history': (context) => const HistoryPage(), // Route for history page
        '/cart': (context) => const PanierPage(),
        '/infoProduit': (context) => const Infprod(), // Ensure this matches your Infprod class
        '/welcome': (context) => const WelcomeScreen(),
        '/three': (context) => const ThreePage(),
        '/four': (context) => const FourPage(),
        '/five': (context) => const FivePage(),
        '/six': (context) => const SixPage(),
        '/payement': (context) => const Paiement(), // Ensure this matches your Paiement class
        '/login': (context) => const LoginPage(),
      },
      theme: ThemeData(
        primaryColor: const Color(0xFFE6B8AF),
        hintColor: const Color(0xFFA34961),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(),
        buttonTheme: ButtonThemeData(
          buttonColor: const Color(0xFFA34961),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
    );
  }
}