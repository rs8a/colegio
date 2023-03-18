import 'package:colegio/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'blocs/authentication/auth_bloc/auth_bloc.dart';
import 'blocs/authentication/repository/auth_repository.dart';
import 'firebase_options.dart';

void main() async {
  initializeDateFormatting();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(authRepository: AuthRepository.instance),
        ),
      ],
      child: const MaterialApp(
        title: 'Instituto Privado Rio Blanco',
        home: SplashScreen(),
      ),
    );
  }
}
