import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class ImagesUpload {
  final BuildContext context;
  final List<XFile> filesList;
  final List<String>? fileNames;
  final String documetId;
  final String directory;
  final String? uniqueName;

  ImagesUpload(
    this.context, {
    required this.directory,
    required this.filesList,
    this.fileNames,
    required this.documetId,
    this.uniqueName,
  });

  static removeFile({required String path}) {
    Reference ref = FirebaseStorage.instance.ref().child(path);
    ref.delete();
  }

  static Future<UploadTask?> uploadFile(
    final BuildContext context, {
    XFile? file,
    required String documetId,
    required String directory,
    String? uniqueName,
  }) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file was selected'),
      ));
      return null;
    }

    UploadTask uploadTask;
    String nameFile = uniqueName ??
        '${DateTime.now()}-${getRandString(5)}${p.extension(file.path)}';
    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('$directory/$documetId')
        .child('/$nameFile');
    if (kIsWeb) {
      uploadTask = ref.putData(await file.readAsBytes());
    } else {
      uploadTask = ref.putFile(File(file.path));
    }

    return Future.value(uploadTask);
  }

  String getName(File file) {
    return file.path.split('/').last;
  }

  static String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  Future<List<String>> showUploadDetailDetail() async {
    return await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        pageBuilder: (_, Animation<double> animation,
                Animation<double> secondaryAnimation) =>
            FadeTransition(
          opacity: animation,
          child: ImageUploadPage(
            filesList: filesList,
            documetId: documetId,
            directory: directory,
            uniqueName: uniqueName,
            fileNames: fileNames,
            // barrierDismissible: this.barrierDismissible,
            // barrierColor: this.barrierColor,
          ),
        ),
      ),
    );
  }
}

class ImageUploadPage extends StatefulWidget {
  final List<XFile> filesList;
  final List<String>? fileNames;
  final String documetId;
  final String directory;
  final String? uniqueName;
  const ImageUploadPage({
    Key? key,
    required this.filesList,
    this.fileNames,
    required this.documetId,
    required this.directory,
    this.uniqueName,
  }) : super(key: key);

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage>
    with TickerProviderStateMixin {
  List<UploadTask> _uploadTasks = [];
  late AnimationController _introOutroAnimationController;
  late AnimationController _barrierAnimationController;
  dynamic opacityIntroOutroAnimation;
  dynamic scaleIntroOutroAnimation;
  dynamic scaleBarrierAnimation;

  List<String> links = [];
  bool isDismissable = true;

  @override
  void initState() {
    _introOutroAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _barrierAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    scaleIntroOutroAnimation = Tween(
      begin: -100.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
          parent: _introOutroAnimationController, curve: Curves.easeInOut),
    );
    opacityIntroOutroAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
          parent: _introOutroAnimationController, curve: Curves.easeInOut),
    );
    scaleBarrierAnimation = Tween(
      begin: 1.0,
      end: 1.015,
    ).animate(
      CurvedAnimation(
          parent: _barrierAnimationController, curve: Curves.easeIn),
    );
    // _controller.repeat(
    //   reverse: true,
    // );
    _introOutroAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 100), () async {
      // widget.filesList.forEach((element) async {
      for (int i = 0; i < widget.filesList.length; i++) {
        String? fileName;
        if (widget.fileNames != null && widget.fileNames!.length > i) {
          fileName = widget.fileNames![i];
        }

        String? nameFile = widget.uniqueName ?? fileName;
        UploadTask? task = await ImagesUpload.uploadFile(
          context,
          file: widget.filesList[i],
          documetId: widget.documetId,
          directory: widget.directory,
          uniqueName: nameFile,
        );
        if (task != null) {
          setState(() {
            _uploadTasks = [..._uploadTasks, task];
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // _introOutroAnimationController.reverse().then((_) {
        //   Navigator.pop(context);
        // });
        _barrierAnimationController
            .forward()
            .then((value) => _barrierAnimationController.reverse());
      },
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: dialogWidget(),
      ),
    );
  }

  AnimatedBuilder dialogWidget() {
    return AnimatedBuilder(
        animation: _barrierAnimationController.view,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleBarrierAnimation.value,
            child: AnimatedBuilder(
                animation: _introOutroAnimationController.view,
                builder: (context, child) {
                  return Opacity(
                    opacity: opacityIntroOutroAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, scaleIntroOutroAnimation.value),
                      // scale: scaleIntroOutroAnimation.value,
                      child: Center(
                        child: dialogDetail(),
                      ),
                    ),
                  );
                }),
          );
        });
  }

  Widget dialogDetail() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            (MediaQuery.of(context).size.width > 490 &&
                    MediaQuery.of(context).size.height > 514)
                ? 20
                : 0),
        color: Theme.of(context).cardColor,
        boxShadow: const [],
      ),
      width: MediaQuery.of(context).size.width > 500 ? 500 : null,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Subiendo Imagenes',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            // Text('${(uploadProgress * 100).toStringAsFixed(0)}'),
            // SizedBox(height: 20),
            AnimatedSize(
              curve: Curves.bounceOut,
              duration: const Duration(milliseconds: 500),
              child: _uploadTasks.isEmpty
                  ? const Center(child: Text("Calculando subida."))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _uploadTasks.length,
                      itemBuilder: (context, index) {
                        return UploadTaskListTile(
                          task: _uploadTasks[index],
                          // onDismissed: () => _removeTaskAtIndex(index),
                          onDownloadLink: () {
                            _downloadLink(_uploadTasks[index].snapshot.ref);
                          },
                          onCompletedUpload: () async {
                            int pru = 0;
                            for (var task in _uploadTasks) {
                              if (task.snapshot.state == TaskState.canceled ||
                                  task.snapshot.state == TaskState.success ||
                                  task.snapshot.state == TaskState.error) {
                                pru++;
                              }
                            }
                            String? lnk = await _downloadLink(
                                _uploadTasks[index].snapshot.ref);
                            if (lnk != null) {
                              if (!links.contains(lnk)) {
                                links.add(lnk);
                              }
                            }
                            if (pru == widget.filesList.length) {
                              _introOutroAnimationController
                                  .reverse()
                                  .then((_) {
                                if (isDismissable) {
                                  isDismissable = false;
                                  Navigator.of(context).pop(links);
                                }
                              });
                            }
                          },
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // void _removeTaskAtIndex(int index) {
  //   setState(() {
  //     _uploadTasks = _uploadTasks..removeAt(index);
  //   });
  // }

  Future<String?> _downloadLink(Reference ref) async {
    return await ref.getDownloadURL();
    // final link = await ref.getDownloadURL();

    // await Clipboard.setData(ClipboardData(
    //   text: link,
    // ));

    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text(
    //       'Success!\n Copied download URL to Clipboard!',
    //     ),
    //   ),
    // );
  }
}

/// Displays the current state of a single UploadTask.
class UploadTaskListTile extends StatelessWidget {
  // ignore: public_member_api_docs
  const UploadTaskListTile({
    Key? key,
    required this.task,
    this.onDismissed,
    this.onDownload,
    this.onDownloadLink,
    this.onCompletedUpload,
  }) : super(key: key);

  /// The [UploadTask].
  final UploadTask /*!*/ task;

  /// Triggered when the user dismisses the task from the list.
  final VoidCallback? /*!*/ onDismissed;

  /// Triggered when the user presses the download button on a completed upload task.
  final VoidCallback? /*!*/ onDownload;

  /// Triggered when the user presses the "link" button on a completed upload task.
  final VoidCallback? /*!*/ onDownloadLink;

  final VoidCallback? /*!*/ onCompletedUpload;

  /// Displays the current transferred bytes of the task.
  String _bytesTransferred(TaskSnapshot snapshot) {
    return ((snapshot.bytesTransferred / snapshot.totalBytes) * 100)
        .toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskSnapshot>(
      stream: task.snapshotEvents,
      builder: (
        BuildContext context,
        AsyncSnapshot<TaskSnapshot> asyncSnapshot,
      ) {
        Widget subtitle = const Text('---');
        TaskSnapshot? snapshot = asyncSnapshot.data;
        TaskState? state = snapshot?.state;

        if (asyncSnapshot.hasError) {
          if (asyncSnapshot.error is FirebaseException &&
              (asyncSnapshot.error as FirebaseException).code == 'canceled') {
            subtitle = const Text('Subida cancelada.');
          } else {
            // print(asyncSnapshot.error);
            onCompletedUpload?.call();
            subtitle = const Text('Algo salió mal.');
          }
        } else if (snapshot != null) {
          subtitle = Text('${_bytesTransferred(snapshot)} % Subido');
        }
        if (state == TaskState.success) {
          subtitle = const Text('Completo');
          onCompletedUpload?.call();
        }

        return ListTile(
          title: Text('Subiendo Imagen #${task.hashCode}'),
          subtitle: subtitle,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (state == TaskState.running)
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: task.pause,
                ),
              if (state == TaskState.running)
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    onCompletedUpload?.call();
                    task.cancel();
                  },
                ),
              if (state == TaskState.paused)
                IconButton(
                  icon: const Icon(Icons.file_upload),
                  onPressed: task.resume,
                ),
              // if (state == TaskState.success)
              //   IconButton(
              //     icon: const Icon(Icons.file_download),
              //     onPressed: onDownload,
              //   ),
              // if (state == TaskState.success)
              //   IconButton(
              //     icon: const Icon(Icons.link),
              //     onPressed: onDownloadLink,
              //   ),
            ],
          ),
        );
      },
    );
  }
}
