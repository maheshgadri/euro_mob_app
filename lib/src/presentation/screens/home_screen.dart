import 'dart:convert';
import 'dart:io';

import 'package:europhia/src/core/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:europhia/src/data/repositories/profile_repository.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:europhia/src/data/models/user_profile_model.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Upload variables
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isUploading = false;
  List<String> _uploadedImages = [];
  String? _userId;
  String? _token;

  UserProfileModel? _profile;
  bool _loadingProfile = true;

  File? _profileImage;


  @override
  void initState() {
    super.initState();
    _loadUserData();
    _tabController = TabController(length: 3, vsync: this);
  }
  Future<void> uploadProfilePic(String userId, File image) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/profile/profile/$userId");


    var request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath('profile', image.path));

    var response = await request.send();
    var respStr = await response.stream.bytesToString();

    print("UPLOAD RESPONSE => $respStr");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile picture updated!")),
      );
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    String? uid = prefs.getString('userId');
    String? tok = prefs.getString('token');

    setState(() {
      _userId = uid;
      _token = tok;
    });

    if (uid != null) {
      await _fetchUserProfile(uid);
    }
  }

  Future<void> _fetchUserProfile(String userId) async {
    try {
      final repo = ProfileRepository();
      final data = await repo.fetchProfile(userId);

      setState(() {
        _profile = data;
        _loadingProfile = false;
      });
    } catch (e) {
      print("Profile load error: $e");
      setState(() => _loadingProfile = false);
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _selectedImages = images.take(5).toList());
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select images first")));
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User ID Missing")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final uri =
      Uri.parse("http://localhost:5001/api/profile/upload/$_userId");
      var request = http.MultipartRequest('POST', uri);

      for (var img in _selectedImages) {
        request.files.add(await http.MultipartFile.fromPath('photos', img.path));
      }

      request.headers['Authorization'] = 'Bearer $_token';

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        setState(() => _uploadedImages = List<String>.from(data['photos']));
      }
    } catch (e) {
      debugPrint("Upload failed: $e");
    }

    setState(() => _isUploading = false);
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 180,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.pinkAccent),
                title: const Text("Take Photo"),
                  onTap: () async {
                    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      File imgFile = File(pickedFile.path);

                      setState(() => _profileImage = imgFile);

                      if (_userId != null) {
                        await uploadProfilePic(_userId!, imgFile);
                      }
                    }
                    Navigator.pop(context);
                  },

              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.pinkAccent),
                title: const Text("Choose from Gallery"),
                  onTap: () async {
                    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      File imgFile = File(pickedFile.path);

                      setState(() => _profileImage = imgFile);

                      if (_userId != null) {
                        await uploadProfilePic(_userId!, imgFile);
                      }
                    }
                    Navigator.pop(context);
                  },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // TOP PINK BANNER
            Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF729F), Color(0xFFFF4D86)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 50,
                    left: 20,
                    child: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
          Center(
            child: Stack(
              children: [
                // PROFILE IMAGE (either selected photo or placeholder)
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  )
                      : null,
                ),

                // SMALL + BUTTON
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showImagePicker,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.pinkAccent,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

                ],
              ),
            ),

            const SizedBox(height: 20),

            // TAB BAR
            TabBar(
              controller: _tabController,
              labelColor: Color(0xFFFF4D86),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFFFF4D86),
              indicatorWeight: 2,
              tabs: const [
                Tab(text: "Edit Profile"),
                Tab(text: "Add Photos"),
                Tab(text: "Settings"),
              ],
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildEditProfileTab(),
                  buildAddPhotosTab(),
                  const Center(child: Text("Settings Coming Soon")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------
  // EDIT PROFILE TAB (UI SAME AS YOUR SCREENSHOT)
  // --------------------------
  Widget buildEditProfileTab() {
    if (_loadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_profile == null) {
      return const Center(child: Text("Profile not found"));
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildField("Name", _profile!.name),
          // buildField("Age", _profile!.age?.toString() ?? "N/A"),
          buildField("Location", _profile!.location ?? "N/A"),
          buildField("Gender", _profile!.gender),
          // buildField("About Me", _profile!.about ?? "No description"),
          // buildField("Hobbies", _profile!.hobbies ?? "Not added yet"),

          const SizedBox(height: 40),
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Color(0xFFFF4D86),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  "Continue",
                  style: TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Field UI Builder
  Widget buildField(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const Divider(height: 20),
      ],
    );
  }

  // --------------------------
  // ADD PHOTOS TAB
  // --------------------------
  Widget buildAddPhotosTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "Upload up to 5 photos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

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
                          setState(() => _selectedImages.remove(img));
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
          _isUploading
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _uploadImages,
            child: const Text("Upload Photos"),
          ),

          const SizedBox(height: 20),

          if (_uploadedImages.isNotEmpty)
            Expanded(
              child: GridView.builder(
                itemCount: _uploadedImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemBuilder: (context, index) {
                  return Image.network(
                    "http://localhost:5001${_uploadedImages[index]}",
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
