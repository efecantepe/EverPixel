import 'dart:io';

import 'package:everpixel/single_filter_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SingleFilterPage extends StatefulWidget {
  const SingleFilterPage({super.key});

  @override
  State<SingleFilterPage> createState() => _MyAppState();
}

class _MyAppState extends State<SingleFilterPage> {

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
        
          body: SafeArea(
        
            child: SizedBox(
        
              width: double.infinity,
        
              child: Column(
                
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
              
                children: [
              
                  ElevatedButton(onPressed: () {
                    final singleFilter = context.read<SingleFilterModel>();
                    singleFilter.pickImageFromGallery();  
                  },  
                  
                  child: Text("Pick Gallery")),
                  SizedBox(height: 24,),
                  ElevatedButton(onPressed: () => {}, child: Text("Pick Camera")),
                  SizedBox(height: 24,),
                  value.selectedImage != null ? Image.file(value.selectedImage!) : Text("Please Select Image")
                ],
              
              ),
            ),
        
          )
        
        ), 
      )
    );
  }

}
