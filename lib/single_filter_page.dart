import 'dart:ffi';
import 'dart:io';

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
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Consumer<SingleFilterModel>(
          builder: (context, value, child) => Scaffold(

              backgroundColor: Colors.blue[50],
              
              bottomNavigationBar: BottomAppBar(
                color: Colors.yellow[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {

                        print(sum(1, 3));

                      },
                      icon: Icon(Icons.image, color: Colors.green),
                    ),
                    IconButton(
                      onPressed: () {

                        print(efe(1,2));

                      },
                      icon: Icon(Icons.filter_b_and_w),
                    ),
                    IconButton(
                      onPressed: () => {},
                      icon: Icon(Icons.blur_on, color: Colors.blue),
                    ),
                    IconButton(
                      onPressed: () => {},
                      icon: Icon(Icons.auto_awesome,
                          color: const Color.fromARGB(255, 235, 127, 163)),
                    ),
                    IconButton(
                      onPressed: () => {},
                      icon: Icon(Icons.border_all),
                    ),

                    IconButton(
                      onPressed: () {

                          

                      },
                      icon: Icon(Icons.abc),
                    ),

                  ],
                ),
              ),
              body: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: value.selectedImage != null
                        ? Image.file(value.selectedImage!)
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
        ));
  }
}
