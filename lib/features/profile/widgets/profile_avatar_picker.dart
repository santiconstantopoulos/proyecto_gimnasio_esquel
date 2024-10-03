import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatelessWidget {
  final String profileImageUrl;
  final ValueChanged<XFile?> onImagePicked;

  const ProfileImagePicker({
    super.key,
    required this.profileImageUrl,
    required this.onImagePicked,
  });

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    onImagePicked(image);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(profileImageUrl),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _pickImage(context),
          ),
        ),
      ],
    );
  }
}
