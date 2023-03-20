import 'package:colegio/blocs/authentication/repository/auth_repository.dart';
import 'package:colegio/class/alumno.dart';
import 'package:colegio/class/gestu_navigate.dart';
import 'package:colegio/screens/add_alumno_screen.dart';
import 'package:colegio/screens/carnet_screen.dart';
import 'package:flutter/material.dart';
import 'package:rs_tools/rs_tools.dart';

class ListaAlumnosScreen extends StatefulWidget {
  const ListaAlumnosScreen({super.key});

  @override
  State<ListaAlumnosScreen> createState() => _ListaAlumnosScreenState();
}

class _ListaAlumnosScreenState extends State<ListaAlumnosScreen> {
  List<Alumno> alumnos = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumnos'),
        actions: [
          ElevatedButton(
            onPressed: () {
              gestuNavigatePushTo(context, child: const AgregarAlumnoScreen());
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
      body: FutureBuilder(
          // initialData: alumnos,
          future: AuthRepository().getAlumnos(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Alumno> alumnos = snapshot.data!;
              alumnos.sort((a, b) {
                return a.curso!.compareTo(b.curso!);
              });
              return ListView.builder(
                itemCount: alumnos.length,
                itemBuilder: (context, index) {
                  Alumno alumno = alumnos[index];
                  return ListTile(
                    leading: ImageAvatarWidget(
                      size: 50,
                      placeholder: 'assets/logo_colegio.png',
                      image: alumno.fotoUrl,
                      cacheEnabled: true,
                      displayName: alumno.nombre,
                    ),
                    title: Text(alumno.nombre!.toUpperCaseWords()),
                    subtitle: Text('${alumno.curso}'),
                    trailing: Checkbox(
                      value: alumno.createdCard,
                      onChanged: (value) {
                        if (value != null) {
                          alumno.createdCard = value;
                          alumno.saveItem();
                          setState(() {});
                        }
                      },
                    ),
                    onTap: () {
                      gestuNavigateModalTo(
                        context,
                        child: CarnetScreen(
                          alumno: alumno,
                        ),
                      );
                    },
                  );
                },
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return const Center(
              child: Text('Error al cargar los alumnos'),
            );
          }),
    );
  }
}
