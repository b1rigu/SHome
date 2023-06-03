import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(text),
      ),
    );
}

// Future<FilePickerResult?> pickImage() async {
//   final image = await FilePicker.platform.pickFiles(type: FileType.image);
//   return image;
// }
