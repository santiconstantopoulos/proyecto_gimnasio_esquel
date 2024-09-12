import 'package:flutter/material.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({Key? key}) : super(key: key);

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
      ),
      body: Center(
        child: Column(
          children: [
            // ... (Aquí agregarás el contenido para reservas)
            ElevatedButton(
              onPressed: () {
                // Lógica para crear una nueva reserva
              },
              child: const Text('Hacer Nueva Reserva'),
            ),
            const SizedBox(height: 20),
            // ... (Aquí agregarás el listado de reservas)
            Text('Tus Reservas', style: Theme.of(context).textTheme.titleLarge), // Corrección aquí
            const SizedBox(height: 10),
            // ... (Aquí agregarás la lista de reservas)
          ],
        ),
      ),
    );
  }
}