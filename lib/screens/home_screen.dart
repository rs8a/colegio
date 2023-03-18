import 'package:flutter/material.dart';

import 'lista_alumnos_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListaAlumnosScreen();
    // return const Scaffold(
    //   body: Center(
    //     child: Text('Hola Mundo'),
    //   ),
    // );
  }
}
