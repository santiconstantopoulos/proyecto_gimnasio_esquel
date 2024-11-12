import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:proyecto_gimnasio_esquel/models/user.dart';
import 'package:proyecto_gimnasio_esquel/services/credits_service.dart';
import 'package:proyecto_gimnasio_esquel/services/profile_services.dart';
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  _QrCodeScreen createState() => _QrCodeScreen();
}

class _QrCodeScreen extends State<QrCodeScreen> {
  final ProfileService _profileService = ProfileService();
  final ReservationsService _reservationsService = ReservationsService();
  final CreditsService _creditsService = CreditsService();
  final AuthService _authService = AuthService();
  User? currentUser;
  bool hasReservationToday = false;
  bool isAdmin = false;
  String? scannedQrCode;
  QRViewController? qrViewController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _checkAdminRole();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userDoc = await _profileService.getUserProfile();
      currentUser = User.fromFirestore(userDoc.id, userDoc.data()!);
      await _checkReservationToday();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el usuario: $e')),
      );
    }
  }

  Future<void> _checkAdminRole() async {
    isAdmin = await _authService.isAdmin;
    setState(() {});
  }

  Future<void> _checkReservationToday() async {
    try {
      final today = DateTime.now();
      final reservations =
          await _reservationsService.getUserReservations().first;
      hasReservationToday = reservations.any((userReservation) {
        final reservationDate = userReservation.reservation.fromDate.toDate();
        return reservationDate.year == today.year &&
            reservationDate.month == today.month &&
            reservationDate.day == today.day &&
            userReservation.isConfirmed;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al verificar la reserva: $e')),
      );
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

  Future<void> _scanQR() async {
    try {
      final scannedCode = await qrViewController!.scannedDataStream.first;
      scannedQrCode = scannedCode.code;

      // Busca la reserva del usuario
      final reservation =
          await _reservationsService.getReservationByQrCode(scannedQrCode!);

      // Verifica si la reserva es válida (del día de hoy y no está consumida)
      if (reservation != null &&
          DateTime.now().day == reservation.fromDate.toDate().day) {
        // Resta un crédito al usuario
        await _creditsService
            .consumeCredits(1); // TODO: restar creditos al usuario
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Crédito restado')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva no válida')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      qrViewController!.pauseCamera();
    }
  }

  void test() {
    print("asd");
  }

  @override
  void dispose() {
    qrViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar QR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar el QR si el usuario tiene una reserva para hoy
            if (hasReservationToday)
              QrImageView(
                data: currentUser!.qrCode,
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

            // Seccion para escanear QR si es administrador
            if (isAdmin)
              Expanded(
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.red,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 250,
                  ),
                  onPermissionSet: (ctrl, p) =>
                      _onPermissionSet(context, ctrl, p),
                ),
              )
            else
              const SizedBox(),

            if (isAdmin)
              ElevatedButton(
                onPressed: scannedQrCode?.isNotEmpty == true ? _scanQR : test,
                child: const Text('Escanear QR de Usuario'),
              ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      qrViewController = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedQrCode = scanData.code;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se concedieron los permisos')),
      );
    }
  }
}
