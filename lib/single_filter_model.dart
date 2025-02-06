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

final _convertImageToBlurImage = _lib
    .lookup<NativeFunction<Void Function(Pointer<Utf8>, Pointer<Utf8>)>>(
        'convertImageToBlurImage')
    .asFunction<void Function(Pointer<Utf8>, Pointer<Utf8>)>();

final _convertImageToSharpenImage = _lib
    .lookup<NativeFunction<Void Function(Pointer<Utf8>, Pointer<Utf8>)>>(
        'convertImageToSharpenImage')
    .asFunction<void Function(Pointer<Utf8>, Pointer<Utf8>)>();

final _convertImageToEdgeImage = _lib
    .lookup<NativeFunction<Void Function(Pointer<Utf8>, Pointer<Utf8>)>>(
        'convertImageToEdgeImage')
    .asFunction<void Function(Pointer<Utf8>, Pointer<Utf8>)>();

class SingleFilterModel extends ChangeNotifier {
  File? _mainImage; 
  File? _selectedImage;
  File? get selectedImage => _selectedImage;
  File? get mainImage => _mainImage;

  deletePhotos(){
    _selectedImage = null;
    _mainImage = null;
    notifyListeners();
  }

  Future pickImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    final returnedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (returnedImage != null) {
      _mainImage = File(returnedImage.path);
      _selectedImage = _mainImage;
      notifyListeners();
    }
  }

  Future<void> convertOriginal() async{

    if(_mainImage == null) return;

    _selectedImage = _mainImage;
    notifyListeners();

  }

  Future<void> convertGray() async {
    if (_mainImage == null) return;

    final Directory? downloadDir = await getDownloadsDirectory();
    final outputPath = '${downloadDir!.path}/gray_image.jpg';

    convertImageToGrayImage(_mainImage!.path, outputPath);

    _selectedImage = File(outputPath);
    notifyListeners();

    print("Gray image saved at: $outputPath");
  }

  Future<void> convertBlur() async {
    if (_mainImage == null) return;

    final Directory? downloadDir = await getDownloadsDirectory();
    final outputPath = '${downloadDir!.path}/blur_image.jpg';

    convertImageToBlurImage(_mainImage!.path, outputPath);

    _selectedImage = File(outputPath);
    notifyListeners();

    print("Blur image saved at: $outputPath");
  }

  Future<void> convertSharpen() async {
    if (_mainImage == null) return;

    final Directory? downloadDir = await getDownloadsDirectory();
    final outputPath = '${downloadDir!.path}/sharpen_image.jpg';

    convertImageToSharpenImage(_mainImage!.path, outputPath);

    _selectedImage = File(outputPath);
    notifyListeners();

    print("Sharpened image saved at: $outputPath");
  }

  Future<void> convertEdge() async {
    if (_mainImage == null) return;

    final Directory? downloadDir = await getDownloadsDirectory();
    final outputPath = '${downloadDir!.path}/edge_image.jpg';

    convertImageToEdgeImage(_mainImage!.path, outputPath);

    _selectedImage = File(outputPath);
    notifyListeners();

    print("Edge-detected image saved at: $outputPath");
  }

  

  String getOpenCVVersion() {
    return _getOpenCVVersion().cast<Utf8>().toDartString();
  }

  void convertImageToGrayImage(String inputPath, String outputPath) {
    _convertImageToGrayImage(
        inputPath.toNativeUtf8(), outputPath.toNativeUtf8());
  }

  void convertImageToBlurImage(String inputPath, String outputPath) {
    _convertImageToBlurImage(
        inputPath.toNativeUtf8(), outputPath.toNativeUtf8());
  }

  void convertImageToSharpenImage(String inputPath, String outputPath) {
    _convertImageToSharpenImage(
        inputPath.toNativeUtf8(), outputPath.toNativeUtf8());
  }

  void convertImageToEdgeImage(String inputPath, String outputPath) {
    _convertImageToEdgeImage(
        inputPath.toNativeUtf8(), outputPath.toNativeUtf8());
  }
}
