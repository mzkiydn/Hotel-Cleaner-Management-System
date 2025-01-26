import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Routes/route.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // This will use the platform-specific options
  );
  runApp(MyApp());
}

// easily create by type 'stless'
class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: Routes.generateRoute,  // Use the custom route generator
      initialRoute: '/login',
    );
  }
}