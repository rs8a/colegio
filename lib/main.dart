import 'package:colegio/alumno.dart';
import 'package:colegio/date_extension.dart';
import 'package:colegio/import_images_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'images_upload.dart';

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
    return const MaterialApp(
      title: 'Instituto Privado Rio Blanco',
      home: AgregarAlumnoScreen(),
    );
  }
}

class AgregarAlumnoScreen extends StatefulWidget {
  const AgregarAlumnoScreen({
    super.key,
  });

  @override
  State<AgregarAlumnoScreen> createState() => _AgregarAlumnoScreenState();
}

class _AgregarAlumnoScreenState extends State<AgregarAlumnoScreen> {
  List<String> cursos = [
    '7mo grado',
    '8vo grado',
    '9no grado',
    '1ro BTP',
    '2do Ciencias y humanidades',
    '2do Informatica',
    '2do Administracion de empresas',
    '3do Informatica',
    '3do Administracion de empresas'
  ];
  late String cursoSeleccionado;
  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController dniController = TextEditingController();
  dynamic imageSelected;
  DateTime? birthDay;
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    cursoSeleccionado = cursos.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instituto Privado Rio Blanco'),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Nombre'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Debe ingresar nombre completo';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Fecha de nacimiento'),
                        const SizedBox(width: 8),
                        Expanded(
                            child: TextFormField(
                          controller: dateController,
                          readOnly: true,
                          onTap: () async {
                            _selectDate(context).then((value) {
                              birthDay = value;
                              if (value != null) {
                                dateController.text = value.onlyDate(
                                    format: 'dd \'de\' MMMM \'de\' yyyy');
                              }
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Debe ingresar fecha de nacimiento';
                            }
                            return null;
                          },
                        )),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('DNI'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: dniController,
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          Alumno alumno = Alumno.newItem();
                          alumno.nombre = nameController.text.trim();
                          alumno.curso = cursoSeleccionado;
                          alumno.nacimiento = birthDay;
                          alumno.dni = dniController.text.trim();
                          if (imageSelected is XFile && mounted) {
                            final uploadedLinks = await ImagesUpload(
                              context,
                              filesList: [imageSelected],
                              directory: 'almunos',
                              documetId: alumno.documentId,
                              uniqueName: alumno.documentId,
                            ).showUploadDetailDetail();
                            if (uploadedLinks.isNotEmpty) {
                              alumno.fotoUrl = uploadedLinks.first;
                            }
                          } else {
                            alumno.fotoUrl = imageSelected ?? '';
                          }
                          alumno.saveItem();
                          nameController.text = '';
                          cursoSeleccionado = cursos.first;
                          birthDay = null;
                          dniController.text = '';
                          dateController.text = '';
                          imageSelected = null;
                        }
                      },
                      child: const Text('Guardar Alumno'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: ImportImagesWidget(
                      name: 'Foto',
                      image: imageSelected,
                      onImport: (photoFile) {
                        setState(() {
                          imageSelected = photoFile;
                        });
                      },
                      onRemove: () {
                        setState(() {
                          imageSelected = null;
                        });
                      },
                    ),
                  ),
                  Row(
                    children: [
                      const Text('Curso'),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: cursoSeleccionado,
                        items: [
                          ...cursos.map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              cursoSeleccionado = value;
                            });
                            FocusScope.of(context).unfocus();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    return picked;
  }
}
