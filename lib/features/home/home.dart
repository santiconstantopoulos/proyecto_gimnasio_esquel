import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/profile/profile_screen.dart'; // Importa la pantalla de perfil

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // Contenido de la pantalla inicial
    Center(
      child: Column(
        children: [
          Image.asset('dash.png'), // Reemplaza con tu imagen
          const Text(
            'Welcome!'
          ),
          // Agrega más widgets para la pantalla inicial
        ],
      ),
    ),
    // Contenido de la pantalla de notificaciones
    const Center(child: Text('Notificaciones')),
    // Contenido de la pantalla del menú lateral
    const Center(child: Text('Menú')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(), // Navega a la pantalla de perfil
                ),
              );
            },
          )
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Secciones de la App'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 0; // Selecciona Inicio
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Buscar'),
              onTap: () {
                // Lógica para navegar a Buscar
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificaciones'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 1; // Selecciona Notificaciones
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Mis compras'),
              onTap: () {
                // Lógica para navegar a Mis compras
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              onTap: () {
                // Lógica para navegar a Favoritos
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Ofertas'),
              onTap: () {
                // Lógica para navegar a Ofertas
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Cupones'),
              onTap: () {
                // Lógica para navegar a Cupones
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.headset_mic),
              title: const Text('Ayuda'),
              onTap: () {
                // Lógica para navegar a Ayuda
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}