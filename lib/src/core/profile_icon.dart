import 'package:flutter/material.dart';

class ProfileAvatarPicker extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onAddPhoto;

  const ProfileAvatarPicker({
    super.key,
    this.imageUrl,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: imageUrl != null
              ? NetworkImage(imageUrl!)
              : null, // show uploaded image if exists
          child: imageUrl == null
              ? const Icon(
            Icons.person,
            size: 55,
            color: Colors.white,
          )
              : null,
        ),

        // + button
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onAddPhoto,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
