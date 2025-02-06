import 'dart:io';

import 'package:everpixel/multiple_filter_page.dart';
import 'package:everpixel/single_filter_model.dart';
import 'package:everpixel/single_filter_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(

    ChangeNotifierProvider(
      create: (context) => SingleFilterModel(),
      child: MaterialApp(

        debugShowCheckedModeBanner: false,
        initialRoute: '/singleFilter',
        routes: {

          '/singleFilter': (context) => const SingleFilterPage(),
          '/multipleFilter' : (context) => const MultipleFilterPage()

        },

      ) 
      
      
    ),

  );
}
