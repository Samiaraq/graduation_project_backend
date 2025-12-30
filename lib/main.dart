import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'welcome_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'app_data_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppData>(
          create: (_) => AppData(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DepreSence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Beiruti',
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
