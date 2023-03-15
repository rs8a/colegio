import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rs_tools/rs_tools.dart';

class ImportImagesWidget extends StatefulWidget {
  final dynamic image;
  final String? name;
  final VoidCallback? onRemove;
  final Function(XFile? photoFile)? onImport;
  final Function(String heroName, dynamic image)? onImageTap;
  final double? maxHeight;
  final double? maxWidth;
  final String? actionTitle;
  final bool hideRemoveButton;

  const ImportImagesWidget({
    Key? key,
    required this.name,
    this.image,
    this.onRemove,
    this.onImport,
    this.onImageTap,
    this.maxHeight,
    this.maxWidth,
    this.actionTitle,
    this.hideRemoveButton = false,
  }) : super(key: key);

  @override
  State<ImportImagesWidget> createState() => _ImportImagesWidgetState();
}

class _ImportImagesWidgetState extends State<ImportImagesWidget> {
  final ImagePicker _picker = ImagePicker();
  dynamic image;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    image = widget.image;
    bool isEmpty =
        (image is String) ? (image as String).isEmpty : image == null;
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.bounceOut,
      child: isEmpty ? emptyListImages() : imagesAdded(),
    );
  }

  Widget imagesAdded() {
    return Center(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ImageAvatarWidget(
            placeholder: 'assets/logo.jpg',
            maxHeight: widget.maxHeight,
            maxWidth: widget.maxWidth,
            radius: 10,
            // heroTag: heroTag,
            displayName: widget.name,
            image: image,
            // onTapImage: (photoURL) {
            //   widget.onImageTap?.call(heroTag, image);
            // },
          ),
          if (!widget.hideRemoveButton)
            Align(
              widthFactor: 1.0,
              heightFactor: 2.0,
              alignment: const Alignment(0, -1.5),
              child: ElevatedButton(
                onPressed: widget.onRemove,
                style: ElevatedButton.styleFrom(
                  // onPrimary: Colors.green,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(5),
                ),
                child: const Icon(Icons.close),
              ),
            ),
        ],
      ),
    );
  }

  Widget emptyListImages({double? size}) {
    return DottedBorder(
      radius: const Radius.circular(20),
      color: Theme.of(context).iconTheme.color!.withOpacity(0.5),
      strokeWidth: 1,
      borderType: BorderType.RRect,
      dashPattern: const [8, 4, 2, 4],
      child: SizedBox(
        height: size ?? 200,
        width: size ?? double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Opacity(
              opacity: 0.5,
              child: Icon(Icons.cloud_upload, size: 50),
            ),
            ElevatedButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.gallery, context: context);
              },
              child: size == null
                  ? Text(widget.actionTitle ?? 'Agregar Archivo')
                  : const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {
      final pickedFileList = await _picker.pickImage(source: source
          // maxWidth: maxWidth,
          // maxHeight: maxHeight,
          // imageQuality: quality,
          );
      widget.onImport?.call(pickedFileList);
    } catch (e) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(
            '$e',
          ),
        ),
      );
    }
  }
}
