import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:proyecto_gimnasio_esquel/models/user.dart'; 
import 'package:proyecto_gimnasio_esquel/services/credits_service.dart'; 
import 'package:proyecto_gimnasio_esquel/services/profile_services.dart'; 
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart'; 

class GenerateQRScreen extends StatefulWidget {
  const GenerateQRScreen({Key? key}) : super(key: key);

  @override
  _GenerateQRScreenState createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  final ProfileService _profileService = ProfileService();
  final ReservationsService _reservationsService = ReservationsService();
  final CreditsService _creditsService = CreditsService();
  User? currentUser; 
  bool hasReservationToday = false; 

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userDoc = await _profileService.getUserProfile();
      currentUser = User.fromFirestore(userDoc.id, userDoc.data()!);
      await _checkReservationToday(); 
      setState(() {});
    } catch (e) {
      print('Error al cargar el usuario: $e');
    }
  }

  // Verifica si el usuario tiene una reserva para hoy (confirmada)
  Future<void> _checkReservationToday() async {
    try {
      final today = DateTime.now();
      final reservations = await _reservationsService.getUserReservations().first; 
      hasReservationToday = reservations.any((reservation) => 
        reservation.reservationDate.year == today.year && 
        reservation.reservationDate.month == today.month &&
        reservation.reservationDate.day == today.day &&
        reservation.isConfirmed 
      );
    } catch (e) {
      print('Error al verificar la reserva: $e');
    }
  }

  Future<void> _handleQRScan() async {
    try {
      // Si tiene una reserva para hoy, resta un crédito
      if (hasReservationToday) {
        await _creditsService.consumeCredits(1); // Consume un crédito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Crédito restado')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tienes una reserva para hoy')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Cierra la pantalla de QR
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar el QR si el usuario tiene una reserva para hoy
            if (hasReservationToday)
              QrImageView(
                data: currentUser!.qrCode!,
                version: QrVersions.auto,
                size: 200.0,
              )
            else
              const Text('No tienes una reserva para hoy'),

            // Botón para escanear el QR
            ElevatedButton(
              onPressed: hasReservationToday ? _handleQRScan : null,
              child: const Text('Escanear QR'),
            ),
          ],
        ),
      ),
    );
  }
}