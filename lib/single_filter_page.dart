import 'package:before_after/before_after.dart';
import 'package:everpixel/filter_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SingleFilterPage extends StatefulWidget {
  const SingleFilterPage({super.key});

  @override
  State<SingleFilterPage> createState() => _SingleFilterPageState();
}

class _SingleFilterPageState extends State<SingleFilterPage> {
  bool _isSingleFilterActivated = true;

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
                    setState(() {
                      _isSingleFilterActivated = !_isSingleFilterActivated;
                      final singleFilter = context.read<SingleFilterModel>();
                      singleFilter.resetAll();
                      

                    });
                  })
            ],
          ),
          backgroundColor: Colors.blue[50],
          body: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: value.selectedImage != null
                    ? _isSingleFilterActivated
                        ? BeforeAfterSlider(
                            context: context,
                            filterValue: value,
                          )
                        : MultipleFilter(context: context, filterValue: value)
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
        Spacer(),
        SizedBox(
          width: double.infinity,
          child: CarouselSlider(
            items: [
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
                        before: Image.file(
                          widget.filterValue.selectedImage!,
                        ),
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
                    : Image.file(
                        widget.filterValue.selectedImage!,
                        fit: BoxFit.cover,
                      ),
              ),
            ],
            options: CarouselOptions(
                aspectRatio: 2.0,
                enlargeCenterPage: true,
                autoPlay: false,
                enableInfiniteScroll: false),
          ),
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                final singleFilter = context.read<SingleFilterModel>();
                singleFilter.convertOriginal();
              },
              icon: Icon(Icons.image, color: Colors.green),
            ),
            IconButton(
              onPressed: () {
                final singleFilter = context.read<SingleFilterModel>();
                singleFilter.sendImageToServer("G");
              },
              icon: Icon(Icons.filter_b_and_w),
            ),
            IconButton(
              onPressed: () {
                final singleFilter = context.read<SingleFilterModel>();
                singleFilter.sendImageToServer("B");
              },
              icon: Icon(Icons.blur_on, color: Colors.blue),
            ),
            IconButton(
              onPressed: () {
                final singleFilter = context.read<SingleFilterModel>();
                singleFilter.sendImageToServer("S");
              },
              icon: Icon(Icons.auto_awesome,
                  color: const Color.fromARGB(255, 235, 127, 163)),
            ),
            IconButton(
              onPressed: () {
                final singleFilter = context.read<SingleFilterModel>();
                singleFilter.sendImageToServer("E");
              },
              icon: Icon(Icons.border_all),
            ),
          ],
        ),
      ],
    );
  }
}

/*
  I used carousel slider for displaying the multiple images horizontally. I used BeforeAfter package to compare with the previous photo.
*/

class MultipleFilter extends StatefulWidget {
  BuildContext context;
  SingleFilterModel filterValue;

  MultipleFilter({
    super.key,
    required this.context,
    required this.filterValue,
  });

  @override
  State<MultipleFilter> createState() => _MultipleFilterState();
}

class _MultipleFilterState extends State<MultipleFilter> {
  double _value = 0;
  bool _isSliderActivated = false;
  bool _isHorizontal = false;

  List<String> _filterList = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),
        CarouselSlider.builder(
            itemCount: widget.filterValue.multipleImages.length,
            options: CarouselOptions(
                aspectRatio: 2.0,
                enlargeCenterPage: true,
                autoPlay: false,
                enableInfiniteScroll: false),
            itemBuilder: (context, index, realIdx) {
              return GestureDetector(
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
                          after: Image.file(
                              widget.filterValue.multipleImages[index]!),
                          before: Image.file(index == 0
                              ? widget.filterValue.mainImage!
                              : widget.filterValue.multipleImages[index - 1]!),
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
                      : Image.file(widget.filterValue.multipleImages[index]!));
            }),
        Spacer(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _filterList.map((item) {
                return IconButton(
                  icon: getIcon(item),
                  onPressed: () {
                    setState(() {
                      _filterList.remove(item);

                      if (_filterList.length == 0) {
                        final singleFilter = context.read<SingleFilterModel>();
                        singleFilter.applyMultipleFilters(_filterList);
                      }

                      final singleFilter = context.read<SingleFilterModel>();
                      singleFilter.applyMultipleFilters(_filterList);
                    });
                  },
                );
              }).toList()),
        ),

        /* After adding new filter by clickking to the filter buttons I call for applyMultipleFilters and recalculate the filters. This causes inefficiencies.
           Instead of that maybe a button might be added to call applyMultipleFilters.
        */ 
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _filterList.add("G");
                  final singleFilter = context.read<SingleFilterModel>();
                  singleFilter.applyMultipleFilters(_filterList);
                });
              },
              icon: Icon(Icons.filter_b_and_w),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _filterList.add("B");
                  final singleFilter = context.read<SingleFilterModel>();
                  singleFilter.applyMultipleFilters(_filterList);
                });
              },
              icon: Icon(Icons.blur_on, color: Colors.blue),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _filterList.add("S");
                  final singleFilter = context.read<SingleFilterModel>();
                  singleFilter.applyMultipleFilters(_filterList);
                });
              },
              icon: Icon(Icons.auto_awesome,
                  color: const Color.fromARGB(255, 235, 127, 163)),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _filterList.add("E");
                  final singleFilter = context.read<SingleFilterModel>();
                  singleFilter.applyMultipleFilters(_filterList);
                });
              },
              icon: Icon(Icons.border_all),
            ),
          ],
        ),
      ],
    );
  }
}

Icon getIcon(String iconName) {
  if (iconName == "G") {
    return Icon(Icons.filter_b_and_w);
  }

  if (iconName == "B") {
    return Icon(Icons.blur_on);
  }

  if (iconName == "S") {
    return Icon(Icons.auto_awesome);
  }

  if (iconName == "E") {
    return Icon(Icons.border_all);
  }

  return Icon(Icons.image);
}
