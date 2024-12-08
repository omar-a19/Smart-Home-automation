import 'package:SmartHomz/repos/authentication_repo.dart';
import 'package:SmartHomz/repos/device_repository.dart';
import 'package:SmartHomz/screens/homescreen.dart';
import 'package:SmartHomz/screens/login.dart';
import 'package:SmartHomz/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/device_bloc.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(AuthRepository()),
        ),
        BlocProvider<DeviceBloc>(
          create: (context) => DeviceBloc(DeviceRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Home Automation',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {

          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
        },

        home: LoginScreen(),
      ),
    );
  }
}
