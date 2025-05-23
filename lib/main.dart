import 'package:anapurna_app/resto-side/donation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'welcome.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async in main()
  await dotenv.load(fileName: ".env"); // Load the env file
  runApp(
    ChangeNotifierProvider(
      create: (context) => DonationProvider(),
      child: Anapurna(),
    ),
  ); // Run your app
}

class Anapurna extends StatelessWidget {
  const Anapurna({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anapurna',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Poppins'),
      home: WelcomePage(),
    );
  }
}
