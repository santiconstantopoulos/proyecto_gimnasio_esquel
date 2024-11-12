import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';
import 'package:proyecto_gimnasio_esquel/features/benefits/benefits_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/credits/credits_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/notifications/notifications_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/qr/qr_code_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/user_reservations_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/menu/menu_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/admin_reservations_screen.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';

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

  final Icon _qrIcon = const Icon(Icons.qr_code,
      size: 30, color: Color.fromARGB(255, 255, 187, 0));

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
    });
  }

  final List<Widget> _userScreens = [
    const UserReservationsScreen(),
    const QrCodeScreen(),
    const NotificationsScreen(),
    const BenefitsScreen(),
    const MenuScreen(),
  ];

  final List<Widget> _adminScreens = [
    const AdminReservationsScreen(),
    const QrCodeScreen(),
    const NotificationsScreen(),
    const CreditsScreen(),
    const MenuScreen(),
  ];

  // Íconos para usuarios normales y administradores (solo un listado ahora)
  final List<Widget> _icons = const <Widget>[
    Icon(Icons.home, size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.qr_code,
        size: 30, color: Color.fromARGB(255, 255, 187, 0)), //  icono QR
    Icon(Icons.notifications,
        size: 30, color: Color.fromARGB(255, 255, 187, 0)),
    Icon(Icons.money,
        size: 30,
        color: Color.fromARGB(255, 255, 187, 0)), //  icono de créditos
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
            if (index == 1 && _qrIcon.icon == Icons.qr_code) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QrCodeScreen(),
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
