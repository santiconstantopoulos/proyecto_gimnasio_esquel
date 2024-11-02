/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/credits_display.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/new_reservations_button.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_dialog.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_list.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_list_admin.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/services/credits_service.dart';
import 'package:proyecto_gimnasio_esquel/services/log_service.dart';
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:random/random.dart';
 */
/* class ReservationsScreenAdmin extends StatefulWidget {
  const ReservationsScreenAdmin({super.key});

  @override
  State<ReservationsScreenAdmin> createState() =>
      _ReservationsScreenAdminState();
} */

/*class _ReservationsScreenAdminState extends State<ReservationsScreenAdmin> {
  final ReservationsService _reservationsService = ReservationsService();
  final CreditsService _creditsService = CreditsService();

  // Mapa para asociar un color a cada tipo de clase
  final Map<String, Color> _classColors = {
    'Funcional': Colors.green,
    'Musculación': Colors.brown,
    'Yoga': Colors.red,
    // Agrega más clases y colores según tus necesidades
  };

  // Estado del calendario
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDate = DateTime.now();
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Opción para seleccionar un rango de fechas

  // Estado de la lista de reservas
  List<Reservation> _reservations = [];

  @override
  void initState() {
    super.initState();

    _reservationsService.getUserReservations().listen((reservations) {
      setState(() {
        _reservations = reservations;
      });
    });
  }

  // Actualiza la lista de reservas al cambiar el mes
  void _onCalendarChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  // Crea un nuevo diálogo para agregar una reserva
  void _showReservationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ReservationDialog(
          // Pasa los parámetros necesarios al diálogo
          onSubmit: (dateTime, name, instructorId, capacity, participants) {
            // Guarda la nueva reserva en la base de datos
            _reservationsService.createReservation(
              dateTime,
              name: name,
              instructorId: instructorId,
              capacity: capacity,
              participants: participants,
            );
            // Cierra el diálogo
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // Función para manejar el clic en la reserva
  void _handleReservationClick(Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // ... (Implementa los detalles del diálogo de la reserva)
        );
      },
    );
  }

  // Función para manejar el arrastre y soltar de la reserva
  void _handleReservationDrag(Reservation reservation) {
    // ... (Implementa la lógica para el arrastre y soltar)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminReservas),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Widget para mostrar los créditos del usuario
            CreditsDisplay(creditsStream: _creditsService.getUserCredits()),
            const SizedBox(height: 20),
            // Widget para crear una nueva reserva
            NewReservationButton(onPressed: _showReservationDialog),
            const SizedBox(height: 20),
            // Widget para mostrar el calendario
            TableCalendar(
              calendarFormat: _calendarFormat,
              selectedDate: _selectedDate,
              rangeSelectionMode: _rangeSelectionMode,
              onCalendarChanged: _onCalendarChanged,
              headerVisible: true,
              calendarBuilders: CalendarBuilders(
                selectedDayBuilder: (context, date, isSelectable) =>
                    Container(
                      decoration: BoxDecoration(
                        color: _classColors[date.toString()],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // ... (Muestra el nombre de la clase)
                    ),
                todayDayBuilder: (context, date, isSelectable) => Container(
                  // ... (Muestra la fecha actual)
                ),
                outsideDayBuilder: (context, date, isSelectable) => Container(
                  // ... (Muestra las fechas fuera del mes actual)
                ),
                defaultDayBuilder: (context, date, isSelectable) => Container(
                  // ... (Muestra el día del mes)
                ),
                weekendDayBuilder: (context, date, isSelectable) => Container(
                  // ... (Muestra los días de fin de semana)
                ),
              ),
              availableGestures: AvailableGestures.all,
              onPageChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
            ),
            const SizedBox(height: 20),
            // Widget para mostrar la lista de reservas
            Expanded(
              child: StreamBuilder<List<Reservation>>(
                stream: _reservationsService.getUserReservations(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final reservations = snapshot.data!;
                    // Filtra las reservas por fecha
                    final filteredReservations = reservations
                        .where((reservation) =>
                            reservation.date.toDate().month ==
                            _selectedDate.month &&
                            reservation.date.toDate().year ==
                            _selectedDate.year)
                        .toList();
                    return ReservationsListAdmin(
                      reservations: filteredReservations,
                      onOptionSelected: (value, reservation) {
                        // ... (Maneja las acciones del usuario)
                      },
                      onShowParticipants: (reservation) {
                        // ... (Muestra el diálogo de participantes)
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('${AppStrings.error} ${snapshot.error}'),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/