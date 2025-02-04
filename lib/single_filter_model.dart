import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class SingleFilterModel extends ChangeNotifier {

    File? _selectedImage;
    File? get selectedImage => _selectedImage;

    Future pickImageFromGallery() async{
      ImagePicker imagePicker = ImagePicker();
      final returnedImage = await imagePicker.pickImage(source: ImageSource.gallery);
      _selectedImage = File(returnedImage!.path);
      notifyListeners();
    }

}