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

  // Holding multiple elements for carousel slider
  List<String> _filterList = [];
  List<File?> _multipleImages = [];
  List<File?> get multipleImages => _multipleImages;

  deletePhotos() {
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

  Future<String?> convertGray({File? mainImage, String? outputPath}) async {
    final image = mainImage ?? _mainImage;
    final output = outputPath ?? "/gray_image";


    final Directory? tempDir = await getTemporaryDirectory();
    final defaultOutputPath = '${tempDir!.path}$output.jpg';
    final outputFilePath = outputPath ?? defaultOutputPath;

    
    if (image == _mainImage) {

      print("SADJKHSDKJHDSAKJDSAHDASKJ");


      print("SADJKHSDKJHDSAKJDSAHDASKJ");

      convertImageToGrayImage(_mainImage!.path, outputFilePath);
      _selectedImage = File(outputFilePath);
      notifyListeners();
      return null;
    }

    convertImageToGrayImage(image!.path, outputFilePath);

    _selectedImage = File(outputFilePath);
    notifyListeners();

    return outputFilePath;
  }

  Future<String?> convertBlur({File? mainImage, String? outputPath}) async {
    final image = mainImage ?? _mainImage;
    final output = outputPath ?? "/blur_image";

    if (image == null) return null;

    final Directory? tempDir = await getTemporaryDirectory();
    final defaultOutputPath = '${tempDir!.path}$output.jpg';
    final outputFilePath = outputPath ?? defaultOutputPath;

    convertImageToBlurImage(image.path, outputFilePath);

    _selectedImage = File(outputFilePath);
    notifyListeners();

    return outputFilePath;
  }

  Future<String?> convertSharpen({File? mainImage, String? outputPath}) async {
    final image = mainImage ?? _mainImage;
    final output = outputPath ?? "/sharpen_image";

    if (image == null) return null;

    final Directory? tempDir = await getTemporaryDirectory();
    final defaultOutputPath = '${tempDir!.path}$output.jpg';
    final outputFilePath = outputPath ?? defaultOutputPath;

    convertImageToSharpenImage(image.path, outputFilePath);

    _selectedImage = File(outputFilePath);
    notifyListeners();

    return outputFilePath;
  }

  Future<String?> convertEdge({File? mainImage, String? outputPath}) async {
    final image = mainImage ?? _mainImage;

    final output = outputPath ?? "/edge_image";

    if (image == null) return null;

    final Directory? tempDir = await getTemporaryDirectory();
    final defaultOutputPath = '${tempDir!.path}$output.jpg';
    final outputFilePath = outputPath ?? defaultOutputPath;

    convertImageToEdgeImage(image.path, outputFilePath);

    _selectedImage = File(outputFilePath);
    notifyListeners();

    return outputFilePath;
  }

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

    // If all elements are the same, return early
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
    notifyListeners();
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
