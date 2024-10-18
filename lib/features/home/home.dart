import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';
import 'package:proyecto_gimnasio_esquel/features/credits/credits_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/notifications/notifications_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/qr/qrCode_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/reservations_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/menu/menu_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/reservations_screen_admin.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  bool _loading = true;

  Widget _qrIcon = const Icon(Icons.qr_code, size: 30, color: Color.fromARGB(255, 255, 187, 0)); 

  final ReservationsService _reservationsService = ReservationsService(); 

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    AuthService authService = AuthService();
    bool isAdmin = await authService.isAdmin;
    setState(() {
      _isAdmin = isAdmin;
      _loading = false;
      _updateQRButton(); // Actualiza el icono del QR al iniciar la pantalla
    });
  }

  // Función para actualizar el icono del QR. Si el usuario tiene una reserva para hoy, se muestra el icono de QR, si no, se muestra en gris
  void _updateQRButton() async {
    // Lógica para consultar si el usuario tiene una reserva hoy
    final today = DateTime.now();
    final reservations = await _reservationsService.getUserReservations().first;

    _qrIcon = reservations.any((reservation) => 
      reservation.reservationDate.year == today.year && 
      reservation.reservationDate.month == today.month &&
      reservation.reservationDate.day == today.day &&
      reservation.isConfirmed 
    ) ? const Icon(Icons.qr_code, size: 30, color: Color.fromARGB(255, 255, 187, 0)) : const Icon(Icons.qr_code, size: 30, color: Colors.grey);

    setState(() {}); // Actualiza el estado para que se renderice el cambio en el navbar
  }

  final List<Widget> _userScreens = [
    const ReservationsScreen(),
    const GenerateQRPage(), // Actualiza la posición del QR en la lista
    const NotificationsScreen(),
    const Center(child: Text(AppStrings.beneficios)),
    const MenuScreen(),
  ];

  final List<Widget> _adminScreens = [
    const ReservationsScreenAdmin(),
    const CreditsScreen(),
    const NotificationsScreen(),
    const MenuScreen(),
  ];

  // Íconos para usuarios normales y administradores (solo un listado ahora)
  final List<Widget> _icons = const <Widget>[
    Icon(Icons.home, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.qr_code, size: 30, color: Color.fromARGB(255, 255, 187, 0)), //  icono QR
    Icon(Icons.notifications,
        size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.money, size: 30, color: Color.fromARGB(255, 255, 187, 0)), //  icono de créditos
    Icon(Icons.menu, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
  ];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _isAdmin
          ? _adminScreens[_selectedIndex]
          : _userScreens[_selectedIndex],
              bottomNavigationBar: CurvedNavigationBar(
              index: _selectedIndex,
              height: 50,
              items: _icons,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                  // Si se selecciona el botón QR, navega a GenerateQRPage solo si está habilitado
                  if (index == 1 && _icons[1] is Icon && (_icons[1] as Icon).icon == Icons.qr_code) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenerateQRPage(),
                      ),
                    );
                  }
                    });
                  },
        color: const Color.fromARGB(255, 54, 32, 68),
        backgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
      ),
    );
  }
}