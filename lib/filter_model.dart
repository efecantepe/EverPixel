import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;


/*

  Defining functions for interfacing c++ code.

*/

DynamicLibrary _lib = Platform.isAndroid
    ? DynamicLibrary.open('libopencv.so')
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



/* 

    I used provider for statemanagement

*/

class SingleFilterModel extends ChangeNotifier {
  File? _mainImage; // for holding the image from ImagePicker
  File? _selectedImage; 
  File? get selectedImage => _selectedImage;
  File? get mainImage => _mainImage;

  // Holding multiple elements for carousel slider
  List<String> _filterList = []; // for comparing filters and not calculating same filters again and again
  List<File?> _multipleImages = [];
  List<File?> get multipleImages => _multipleImages; // it wil hold intermediate images

  deletePhotos() {
    _selectedImage = null;
    _mainImage = null;
    notifyListeners();
  }

  Future<void> pickImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    final returnedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (returnedImage != null) {
      _mainImage = File(returnedImage.path);
      _selectedImage = _mainImage;
      _multipleImages.add(_mainImage);
      _filterList.add("O");
      notifyListeners();
    }
  }

  Future<void> convertOriginal() async {
    if (_mainImage == null) return;

    _selectedImage = _mainImage;
    notifyListeners();
  }

  // Main function for converting images. According to filter it will send the appropriate filters
  Future<String?> _convertImage(
      String filterType, File? mainImage, String? outputPath) async {
    final image = mainImage ?? _mainImage;
    if (image == null) return null;

    final Directory tempDir = await getTemporaryDirectory();
    final String uniqueFileName =
        '${path.basenameWithoutExtension(image.path)}_$filterType${path.extension(image.path)}';
    final outputFilePath = path.join(tempDir.path, uniqueFileName);

    final inputPathUtf8 = image.path.toNativeUtf8();
    final outputPathUtf8 = outputFilePath.toNativeUtf8();

    try {
      switch (filterType) {
        case 'G':
          _convertImageToGrayImage(inputPathUtf8, outputPathUtf8);
          break;
        case 'B':
          _convertImageToBlurImage(inputPathUtf8, outputPathUtf8);
          break;
        case 'S':
          _convertImageToSharpenImage(inputPathUtf8, outputPathUtf8);
          break;
        case 'E':
          _convertImageToEdgeImage(inputPathUtf8, outputPathUtf8);
          break;
        default:
          return null;
      }
    } finally {
      calloc.free(inputPathUtf8);
      calloc.free(outputPathUtf8);
    }

    _selectedImage = File(outputFilePath);
    notifyListeners();

    return outputFilePath;
  }

  Future<String?> convertGray({File? mainImage, String? outputPath}) async {
    return _convertImage('G', mainImage, outputPath);
  }

  Future<String?> convertBlur({File? mainImage, String? outputPath}) async {
    return _convertImage('B', mainImage, outputPath);
  }

  Future<String?> convertSharpen({File? mainImage, String? outputPath}) async {
    return _convertImage('S', mainImage, outputPath);
  }

  Future<String?> convertEdge({File? mainImage, String? outputPath}) async {
    return _convertImage('E', mainImage, outputPath);
  }


  // For calculating the intermediate images and notifying the page.
  Future<void> applyMultipleFilters(List<String> filters) async {
    if (filters.isEmpty) {
      _multipleImages.clear();
      _multipleImages.add(_mainImage);
      _filterList = List.from(filters);
      notifyListeners();
    }

    if (_mainImage == null || filters.isEmpty) return;

    int commonPrefixLength = 0;

    // Find the first different element in the filter list
    while (commonPrefixLength < _filterList.length &&
        commonPrefixLength < filters.length &&
        _filterList[commonPrefixLength] == filters[commonPrefixLength]) {
      commonPrefixLength++;
    }

    // If all elements are the same, return early. If not filters change to a certain point no need to recalculate again and again.
    if (commonPrefixLength == filters.length &&
        commonPrefixLength == _filterList.length) {
      return;
    }

    File? currentImage = (commonPrefixLength == 0)
        ? _mainImage
        : _multipleImages[commonPrefixLength - 1];

    List<File?> intermediateImages =
        _multipleImages.sublist(0, commonPrefixLength);

    for (int i = commonPrefixLength; i < filters.length; i++) {
      String? outputPath;
      switch (filters[i]) {
        case "G":
          outputPath = await convertGray(mainImage: currentImage);
          break;
        case "B":
          outputPath = await convertBlur(mainImage: currentImage);
          break;
        case "S":
          outputPath = await convertSharpen(mainImage: currentImage);
          break;
        case "E":
          outputPath = await convertEdge(mainImage: currentImage);
          break;
        case "O":
          outputPath = _mainImage!.path;
          break;
        default:
          continue;
      }

      if (outputPath != null) {
        currentImage = File(outputPath);
        intermediateImages.add(currentImage);
      }
    }

    _multipleImages = intermediateImages;
    _selectedImage = currentImage;
    _filterList = List.from(filters);
    notifyListeners(); // Notifying the user interface after the calculating the images.
  }

  Future<void> resetAll() async {
    _mainImage = null;
    _selectedImage = null;
    _multipleImages = [];
    _filterList = [];

    final Directory tempDir = await getTemporaryDirectory();
    await clearTemporaryDirectory(tempDir);
    notifyListeners();
  }

  Future<void> clearTemporaryDirectory(Directory tempDir) async {
    final files = tempDir.listSync();

    for (var file in files) {
      try {
        if (file is File) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting file: $e');
      }
    }
  }

  String getOpenCVVersion() {
    return _getOpenCVVersion().cast<Utf8>().toDartString();
  }

  void convertImageToGrayImage(String inputPath, String outputPath) {
    final inputPathUtf8 = inputPath.toNativeUtf8();
    final outputPathUtf8 = outputPath.toNativeUtf8();
    try {
      _convertImageToGrayImage(inputPathUtf8, outputPathUtf8);
    } finally {
      calloc.free(inputPathUtf8);
      calloc.free(outputPathUtf8);
    }
  }

  void convertImageToBlurImage(String inputPath, String outputPath) {
    final inputPathUtf8 = inputPath.toNativeUtf8();
    final outputPathUtf8 = outputPath.toNativeUtf8();
    try {
      _convertImageToBlurImage(inputPathUtf8, outputPathUtf8);
    } finally {
      calloc.free(inputPathUtf8);
      calloc.free(outputPathUtf8);
    }
  }

  void convertImageToSharpenImage(String inputPath, String outputPath) {
    final inputPathUtf8 = inputPath.toNativeUtf8();
    final outputPathUtf8 = outputPath.toNativeUtf8();
    try {
      _convertImageToSharpenImage(inputPathUtf8, outputPathUtf8);
    } finally {
      calloc.free(inputPathUtf8);
      calloc.free(outputPathUtf8);
    }
  }

  void convertImageToEdgeImage(String inputPath, String outputPath) {
    final inputPathUtf8 = inputPath.toNativeUtf8();
    final outputPathUtf8 = outputPath.toNativeUtf8();
    try {
      _convertImageToEdgeImage(inputPathUtf8, outputPathUtf8);
    } finally {
      calloc.free(inputPathUtf8);
      calloc.free(outputPathUtf8);
    }
  }
}
