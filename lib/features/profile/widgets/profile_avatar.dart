import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String profileImageUrl;

  const ProfileAvatar({super.key, required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 50,
      backgroundImage: NetworkImage(profileImageUrl),
    );
  }
}
