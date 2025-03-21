import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(File image) onPickImage;
  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  void _pickImage() async {
    final pickImage = await ImagePicker().pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50, 
      maxWidth: 150
    );
    if (pickImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickImage.path);
    });
    print(_pickedImageFile);
    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        ),
        TextButton.icon(
          icon: const Icon(Icons.image),
          onPressed: _pickImage, 
          label: const Text('Add image'),
        ),
      ],
    );
  }
}