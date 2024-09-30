import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/dark_mode_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/profile/profile_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/reservations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  bool _showMoreOptions = false; // Control para mostrar/ocultar la lista

  final List<Widget> _screens = [
    const ReservationsScreen(),
    const Center(child: Text('Notificaciones')),
    const Center(child: Text('Contenido de la pantalla "Más"')), // Aquí va el contenido de la pantalla "Más"
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Ajusta la duración de la animación
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMoreOptions() {
    setState(() {
      _showMoreOptions = !_showMoreOptions;
      if (_showMoreOptions) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }


//TODO  Hace falta arreglar la sección "mas" para que abra todas las secciones posibles. Reservas, beneficios, creditos, historial, etc.



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Lógica para abrir el perfil (opcional)
            },
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _screens[_selectedIndex], // La pantalla actual
          // La lista de opciones solo se muestra si _showMoreOptions es true
          AnimatedOpacity(
            opacity: _showMoreOptions ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showMoreOptions ? 200 : 0, // Ajusta la altura según la lista
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editar Perfil'),
                    onTap: () {
                      // Navega a la pantalla de editar perfil
                      _toggleMoreOptions();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(), // Ejemplo
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Mi Perfil'),
                    onTap: () {
                      // Navega a la pantalla de perfil
                      _toggleMoreOptions();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(), // Ejemplo
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Cerrar Sesión'),
                    onTap: () {
                      // Maneja la lógica de cierre de sesión
                      _toggleMoreOptions();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notificaciones'),
                    onTap: () {
                      // Navega a la pantalla de notificaciones
                      _toggleMoreOptions();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Center(
                              child: Text('Notificaciones Screen')), // Ejemplo
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 2) {
              _toggleMoreOptions();
            } else if (_showMoreOptions) {
              _toggleMoreOptions();
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Más',
          ),
        ],
      ),
    );
  }
}