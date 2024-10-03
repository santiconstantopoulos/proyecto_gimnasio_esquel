// profile_screen.dart
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/profile/services/profile_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_gimnasio_esquel/features/profile/widgets/profile_avatar.dart';
import 'widgets/profile_name.dart';
import 'widgets/profile_edit_button.dart';
import 'widgets/profile_avatar_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  String userName = "Cargando...";
  String profileImageUrl = "";
  bool isEditing = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> profileData =
          await _profileService.getUserProfile();

      String? fetchedProfileImageUrl = profileData.data()?['profile_image_url'];

      if (fetchedProfileImageUrl == null || fetchedProfileImageUrl.isEmpty) {
        final Reference defaultImageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/default_avatar.jpg');
        fetchedProfileImageUrl = await defaultImageRef.getDownloadURL();
      }

      setState(() {
        userName = profileData.data()?['name'] ?? 'Usuario desconocido';
        profileImageUrl = fetchedProfileImageUrl!;
        _nameController.text = userName;
      });
    } catch (e) {
      setState(() {
        userName = "Error al cargar perfil $e";
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      await _profileService.updateUserName(_nameController.text);
      setState(() {
        userName = _nameController.text;
        isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el perfil: $e')),
      );
    }
  }

  Future<void> _updateProfileImage(XFile? image) async {
    if (image != null) {
      try {
        final file = File(image.path);
        final String nameFile = file.path.split("/").last;
        final FirebaseStorage storage = FirebaseStorage.instance;

        Reference ref = storage.ref().child("profile_images").child(nameFile);

        final UploadTask uploadTask = ref.putFile(file);
        final TaskSnapshot snapshot = await uploadTask.whenComplete(() => true);
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        await _profileService.updateUserProfileImage(downloadUrl);

        setState(() {
          profileImageUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen de perfil actualizada')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al actualizar la imagen de perfil: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isEditing
                ? ProfileImagePicker(
                    profileImageUrl: profileImageUrl,
                    onImagePicked: _updateProfileImage,
                  )
                : ProfileAvatar(profileImageUrl: profileImageUrl),
            const SizedBox(height: 20),
            ProfileName(
              isEditing: isEditing,
              userName: userName,
              nameController: _nameController,
            ),
            const SizedBox(height: 20),
            ProfileEditButton(
              isEditing: isEditing,
              onSave: _saveProfile,
              onEdit: () {
                setState(() {
                  isEditing = true;
                });
              },
              onCancel: () {
                setState(() {
                  isEditing = false;
                  _nameController.text = userName;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
