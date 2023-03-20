import 'dart:html' as html;
import 'dart:typed_data';

import 'package:colegio/class/alumno.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:rs_tools/rs_tools.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class CarnetScreen extends StatefulWidget {
  final Alumno alumno;
  const CarnetScreen({super.key, required this.alumno});

  @override
  State<CarnetScreen> createState() => _CarnetScreenState();
}

class _CarnetScreenState extends State<CarnetScreen> {
  Set<String> selected = {'Frontal'};
// WidgetsToImageController to access widget
  WidgetsToImageController controller = WidgetsToImageController();
  // to save image bytes of widget
  Uint8List? bytes;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        Navigator.pop(context);
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color.fromARGB(255, 17, 57, 102),
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            floatingActionButton: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
              child: FloatingActionButton(
                elevation: 1,
                mini: true,
                child: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SegmentedButton(
                    segments: const [
                      ButtonSegment(
                        value: 'Frontal',
                        label: Text('Frontal'),
                      ),
                      ButtonSegment(
                        value: 'Trasera',
                        label: Text('Trasera'),
                      ),
                    ],
                    selected: selected,
                    onSelectionChanged: (p0) {
                      setState(() {
                        selected = p0;
                      });
                      debugPrint('selected: ${selected.first}');
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xff003a6d),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5.0,
                          offset: const Offset(0, 2),
                          color: Theme.of(context).shadowColor.withOpacity(0.5),
                        )
                      ],
                    ),
                    width: 638 / 2,
                    height: 1004 / 2,
                    child: WidgetsToImage(
                      controller: controller,
                      child: selected.first == 'Frontal'
                          ? FrontalWidget(alumno: widget.alumno)
                          : BackWidget(alumno: widget.alumno),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _captureAndSavePng(),
                    child: const Text('Exportar'),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLoading
                ? Container(
                    color: Colors.black38,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndSavePng() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    String fileName = widget.alumno.nombre ?? 'file';
    fileName = fileName.split(' ').join('_');
    final pngBytes = await controller.capture();
    final blob = html.Blob([pngBytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download =
          '${fileName.toLowerCase()}_${selected.first.toLowerCase()}.png';
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);

    setState(() {
      isLoading = false;
    });
  }
}

class FrontalWidget extends StatelessWidget {
  final Alumno alumno;
  const FrontalWidget({super.key, required this.alumno});

  @override
  Widget build(BuildContext context) {
    double width = 638 / 2;
    List<String> name = alumno.nombre!.split(' ');
    String firstName = name.first;
    name.removeAt(0);
    String lastName = name.join(' ');
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Opacity(
            opacity: 0.8,
            child: Image.asset(
              'assets/fondo.png',
              width: 638 / 2,
              height: 1004 / 2,
            ),
          ),
          Positioned(
            bottom: 5,
            right: 2,
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/logo_colegio.png',
                width: 90,
                // height: 1004 / 4,
                // fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xff003a6d),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: ImageAvatarWidget(
                    width: width / 2,
                    radius: 10,
                    borderPadding: 0,
                    borderColor: const Color(0xff003a6d),
                    placeholder: 'assets/logo_colegio.png',
                    image: alumno.fotoUrl,
                    cacheEnabled: true,
                    displayName: alumno.nombre,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  firstName.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 25,
                    color: Color(0xff003a6d),
                  ),
                ),
                Text(
                  lastName.toUpperCaseWords(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Text(
                    '${alumno.curso}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  alumno.documentId,
                  style: const TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Color(0xff003a6d),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackWidget extends StatelessWidget {
  final Alumno alumno;
  const BackWidget({Key? key, required this.alumno}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // double width = 638 / 2;
    // List<String> name = alumno.nombre!.split(' ');
    // String firstName = name.first;
    // name.removeAt(0);
    // String lastName = name.join(' ');
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Opacity(
            opacity: 0.8,
            child: Image.asset(
              'assets/fondo_back.png',
              width: 638 / 2,
              height: 1004 / 2,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: PrettyQr(
                      image: const AssetImage('assets/logo_colegio.png'),
                      typeNumber: 3,
                      size: 200,
                      data: alumno.documentId,
                      errorCorrectLevel: QrErrorCorrectLevel.M,
                      roundEdges: true,
                    )),
                const SizedBox(height: 16),
                const Text(
                  'Instituto Privado\nRio Blanco',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 25,
                    color: Color(0xff003a6d),
                  ),
                ),
                const Text(
                  'San Pedro Sula',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Valido hasta Diciembre 2023',
                  style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Color(0xff003a6d),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          alumno.nombre!.toUpperCaseWords(),
                          textAlign: TextAlign.right,
                        ),
                        Opacity(
                          opacity: 0.5,
                          child: Text(
                            alumno.documentId,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 24.0),
                //   child: Text(
                //     'Curso: ${alumno.curso}',
                //     textAlign: TextAlign.center,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
