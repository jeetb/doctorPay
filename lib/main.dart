import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hospital_finance_app/pages/wrapper.dart';
import 'package:hospital_finance_app/services/auth_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const hospApp());
}

class hospApp extends StatelessWidget {
  const hospApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        Provider<AuthService>(
          create: (_) => AuthService(),
          ),
      ],
      child: const MaterialApp(
        title: 'Login Demo',
        home: Wrapper(),
      ),
    );
  }
}

