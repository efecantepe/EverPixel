import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';


DynamicLibrary _lib = Platform.isAndroid
    ? DynamicLibrary.open('libmy_functions.so')
    : DynamicLibrary.process();
final _getOpenCVVersion = _lib
    .lookup<NativeFunction<Pointer<Utf8> Function()>>('getOpenCVVersion')
    .asFunction<Pointer<Utf8> Function()>();
final _convertImageToGrayImage = _lib
    .lookup<NativeFunction<Void Function(Pointer<Utf8>, Pointer<Utf8>)>>(
        'convertImageToGrayImage')
    .asFunction<void Function(Pointer<Utf8>, Pointer<Utf8>)>();

class SingleFilterModel extends ChangeNotifier {
  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  Future pickImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    final returnedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    _selectedImage = File(returnedImage!.path);
    notifyListeners();
  }

  convertGray() async {

    final Directory? downloadDir = await getDownloadsDirectory();
    final outputPath = '${downloadDir!.path}/gray_image.jpg';
    convertImageToGrayImage(selectedImage!.path, outputPath);

    _selectedImage = File(outputPath);
    notifyListeners();

    print("Output path is $outputPath");

  }

  String getOpenCVVersion() {
    return _getOpenCVVersion().cast<Utf8>().toDartString();
  }

  void convertImageToGrayImage(String inputPath, String outputPath) {
    _convertImageToGrayImage(
        inputPath.toNativeUtf8(), outputPath.toNativeUtf8());
  }
}
