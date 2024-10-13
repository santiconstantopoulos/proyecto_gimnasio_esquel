import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';

class ReservationsScreenAdmin extends StatefulWidget {
  const ReservationsScreenAdmin({super.key});

  @override
  State<ReservationsScreenAdmin> createState() =>
      _ReservationsScreenAdminState();
}

class _ReservationsScreenAdminState extends State<ReservationsScreenAdmin> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminReservas),
        centerTitle: true,
      ),
    );
  }
}
