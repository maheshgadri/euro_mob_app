import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isUploading = false;
  List<String> _uploadedImages = [];
  String? _userId;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      _token = prefs.getString('token');
    });
    debugPrint('Loaded userId=$_userId token=$_token');
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.take(5).toList();
      });
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select images first")),
      );
      return;
    }

    if (_userId == null || _token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final uri = Uri.parse("http://localhost:5001/api/profile/upload/$_userId");
      var request = http.MultipartRequest('POST', uri);

      // Attach images
      for (var img in _selectedImages) {
        request.files.add(await http.MultipartFile.fromPath('photos', img.path));
      }

      // Add token
      request.headers['Authorization'] = 'Bearer $_token';

      // Send
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      debugPrint("Upload response: ${response.statusCode} => $respStr");

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        setState(() {
          _uploadedImages = List<String>.from(data['photos']);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile images uploaded successfully ✅")),
        );
      } else {
        throw Exception("Upload failed: $respStr");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Upload up to 5 photos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Image Picker Preview
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._selectedImages.map(
                      (img) => Stack(
                    children: [
                      Image.file(File(img.path),
                          width: 100, height: 100, fit: BoxFit.cover),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedImages.remove(img);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedImages.length < 5)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.add_a_photo, size: 30),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),

            if (_isUploading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Upload Photos"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
                onPressed: _uploadImages,
              ),
            const SizedBox(height: 20),

            if (_uploadedImages.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  itemCount: _uploadedImages.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final imageUrl =
                        "http://localhost:5001${_uploadedImages[index]}";
                    return Image.network(imageUrl, fit: BoxFit.cover);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
