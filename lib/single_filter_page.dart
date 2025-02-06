import 'dart:ffi';
import 'dart:io';

import 'package:before_after/before_after.dart';
import 'package:everpixel/single_filter_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:c_plugin/c_plugin.dart';

class SingleFilterPage extends StatefulWidget {
  const SingleFilterPage({super.key});

  @override
  State<SingleFilterPage> createState() => _SingleFilterPageState();
}

class _SingleFilterPageState extends State<SingleFilterPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SingleFilterModel>(
      builder: (context, value, child) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.yellow[100],
            actions: [
              IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () {
                    Navigator.popAndPushNamed(context, "/multipleFilter");
                  })
            ],
          ),
          backgroundColor: Colors.blue[50],
          bottomNavigationBar: BottomAppBar(
            color: Colors.yellow[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final singleFiler = context.read<SingleFilterModel>();
                    singleFiler.convertOriginal();
                  },
                  icon: Icon(Icons.image, color: Colors.green),
                ),
                IconButton(
                  onPressed: () {
                    final singleFilter = context.read<SingleFilterModel>();
                    singleFilter.convertGray();
                  },
                  icon: Icon(Icons.filter_b_and_w),
                ),
                IconButton(
                  onPressed: () {
                    final singleFilter = context.read<SingleFilterModel>();
                    singleFilter.convertBlur();
                  },
                  icon: Icon(Icons.blur_on, color: Colors.blue),
                ),
                IconButton(
                  onPressed: () {
                    final singleFilter = context.read<SingleFilterModel>();
                    singleFilter.convertSharpen();
                  },
                  icon: Icon(Icons.auto_awesome,
                      color: const Color.fromARGB(255, 235, 127, 163)),
                ),
                IconButton(
                  onPressed: () {
                    final singleFilter = context.read<SingleFilterModel>();
                    singleFilter.convertEdge();
                  },
                  icon: Icon(Icons.border_all),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: value.selectedImage != null
                    ? BeforeAfterSlider(
                        context: context,
                        filterValue: value,
                      )
                    : TextButton(
                        onPressed: () {
                          final singleFilter =
                              context.read<SingleFilterModel>();
                          singleFilter.pickImageFromGallery();
                        },
                        child: Text(
                          "Pick From Gallery",
                          style: TextStyle(fontSize: 20),
                        )),
              ),
            ),
          )),
    );
  }
}

class BeforeAfterSlider extends StatefulWidget {
  BuildContext context;
  SingleFilterModel filterValue;

  BeforeAfterSlider({
    super.key,
    required this.context,
    required this.filterValue,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _value = 0;
  bool _isSliderActivated = false;
  bool _isHorizontal = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
            onDoubleTap: () {
              setState(() {
                _isSliderActivated = !_isSliderActivated;
              });
            },
            onLongPress: () {
              setState(() {
                _isHorizontal = !_isHorizontal;
              });
            },
            child: _isSliderActivated
                ? BeforeAfter(
                    value: _value,
                    before: Image.file(widget.filterValue.selectedImage!),
                    after: Image.file(widget.filterValue.mainImage!),
                    hideThumb: false,
                    direction: _isHorizontal
                        ? SliderDirection.horizontal
                        : SliderDirection.vertical,
                    onValueChanged: (value) {
                      setState(() {
                        _value = value;
                      });
                    },
                  )
                : Image.file(widget.filterValue.selectedImage!)),
        TextButton(
            onPressed: () {
              final singleFilter = context.read<SingleFilterModel>();
              singleFilter.deletePhotos();
            },
            child: Text("X"))
      ],
    );
  }
}
