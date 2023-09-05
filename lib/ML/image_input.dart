import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  final Function onSelectImage;
  const ImageInput(this.onSelectImage, {super.key});

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File _storedImage = File("");
  Future<void> _clickOrChoosePhoto(ImageSource imageSource) async {
    final picker = ImagePicker();
    Navigator.of(context).pop();
    final imageFile = await picker.pickImage(
        source: imageSource, maxWidth: 600, imageQuality: 100);
    if (imageFile == null) {
      return;
    }

    setState(() {
      _storedImage = File(imageFile.path);
      widget.onSelectImage(_storedImage);
    });
  }

  Future<void> _pictureButtonMethod() async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
              title: Text(
                'Select/Click Receipt Photo!',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              content: Text(
                "Select a method!",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                        onPressed: () {
                          _clickOrChoosePhoto(ImageSource.camera);
                        },
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: const Text("Camera")),
                    TextButton.icon(
                        onPressed: () {
                          _clickOrChoosePhoto(ImageSource.gallery);
                        },
                        icon: const Icon(Icons.photo),
                        label: const Text("Gallery"))
                  ],
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    Size scSize = MediaQuery.of(context).size;

    return Column(
      children: [
        Container(
          width:
              (scSize.height > 600) ? scSize.width * 0.8 : scSize.width * 0.4,
          height:
              (scSize.height > 600) ? scSize.height * 0.5 : scSize.height * 0.6,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: _storedImage.path != ""
              ? Image.file(
                  _storedImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : const Center(
                  child: Text(
                    "No Receipt Scanned",
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
        const SizedBox(
          width: 10,
        ),
        TextButton.icon(
          onPressed: _pictureButtonMethod,
          icon: const Icon(Icons.camera),
          label: const Text(
            "Take Picture",
          ),
        )
      ],
    );
  }
}
