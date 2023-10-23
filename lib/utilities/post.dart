import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  PickedFile? _image;
  final picker = ImagePicker();
  TextEditingController locationController = TextEditingController();
  TextEditingController productTypeController = TextEditingController();
  TextEditingController productStatusController = TextEditingController();
  TextEditingController productCostController = TextEditingController();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = PickedFile(pickedFile.path);
      }
    });
  }

  Future<void> uploadData() async {
    if (_image != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userEmail = user.email;
        final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now()}_$userEmail.jpg');
        final uploadTask = storageRef.putFile(File(_image!.path));
        await uploadTask.whenComplete(() {});

        final downloadURL = await storageRef.getDownloadURL();

        // Create a timestamp for the current time.
        final timestamp = Timestamp.now();

        // Now, you can store the download URL, location, product type, product status, product cost, and timestamp in Firestore.
        await FirebaseFirestore.instance.collection('users').doc(userEmail).collection('user_data').add({
          'location': locationController.text,
          'productType': productTypeController.text,
          'productStatus': productStatusController.text,
          'productCost': double.parse(productCostController.text),
          'imageUrl': downloadURL,
          'timestamp': timestamp,
          // You can add more fields as needed
        });

        // Navigate back to the previous screen or another page
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: _image == null
                    ? const Text('No image selected.')
                    : Image.file(File(_image!.path)),
              ),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Select Image'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: productTypeController,
                decoration: const InputDecoration(labelText: 'Product Type'),
              ),
              TextField(
                controller: productStatusController,
                decoration: const InputDecoration(labelText: 'Product Status'),
              ),
              TextField(
                controller: productCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Product Cost'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: uploadData,
                child: const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
