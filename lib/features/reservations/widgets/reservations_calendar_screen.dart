import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/credits_display.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/new_reservations_button.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_dialog.dart'; // Puede ser un dialogo de tipo "modal bottom sheet" de Flutter
import 'package:proyecto_gimnasio_esquel/models/participant.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/credits_service.dart';
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationsCalendarScreen extends StatefulWidget {
  final bool isAdmin;

  const ReservationsCalendarScreen({super.key, required this.isAdmin});

  @override
  State<ReservationsCalendarScreen> createState() =>
      _ReservationsCalendarScreenState();
}

class _ReservationsCalendarScreenState
    extends State<ReservationsCalendarScreen> {
  final ReservationsService _reservationsService = ReservationsService();
  final CreditsService _creditsService = CreditsService();

  final Map<String, Color> _classColors = {
    'Funcional': Colors.green,
    'Musculación': Colors.brown,
    'Yoga': Colors.red,
  };
  
  //  Estados para el calendario:
  CalendarFormat _calendarFormat = CalendarFormat.week; // Formato semanal
  DateTime _focusedDay = DateTime.now(); // Día actual
  DateTime _selectedDay = DateTime.now(); // Día actual 
  List<Reservation> _reservations = []; //  Lista de reservas

  //  Para manejo de reservas:
  void _showReservationDialog() {
  showDialog(
  context: context,
  builder: (context) {
    return const ReservationDialog( 
        );
            Navigator.of(context).pop();
          },
        );
  }

  //  Mostrar  la lista de participantes  
  void _handleReservationClick(Reservation reservation) {
    //   Mostrar el dialogo  de  detalles  de la reserva: 
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(reservation.className),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Fecha: ${reservation.fromDate.toDate().toLocal()} - ${reservation.toDate.toDate().toLocal()}'),
              Text('Instructor: ${reservation.instructorId}'), 
              Text('Cupo: ${reservation.places}'),
              const SizedBox(height: 16),
              Text('Estado: ${reservation.status}'),
              const SizedBox(height: 16),
              const Text('Participantes:'),
              StreamBuilder<List<Participant>>(
                stream: _reservationsService.getParticipants(reservation.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.isNotEmpty) {
                    final participants = snapshot.data!;
                    return SizedBox(
                      height: 200,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          final participant = participants[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: participant.user.profileImageUrl.isNotEmpty ? NetworkImage(participant.user.profileImageUrl) : null,
                              radius: 20,
                              child: participant.user.profileImageUrl.isEmpty ? const Icon(Icons.person) : null,
                            ),
                            title: Text(participant.user.name),
                            subtitle: Text('Estado: ${participant.status}'),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Center(child: Text('No hay participantes.'));
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _reservationsService.getReservations().listen((reservations) {
      setState(() {
        _reservations = reservations;
      });
    });
  }

  // Actualiza el calendario cuando  cambia el mes 
  void _onCalendarChanged(DateTime date) {
    setState(() {
      _focusedDay = date;
    });
  }

  //  Lista de eventos (reservas):
  List<Appointment> _getCalendarEvents() {
    List<Appointment> calendarAppointments = [];
    for (var reservation in _reservations) {
      //  Obtener datos del instructor, etc.
      String? className = reservation.className;
      String? instructorId = reservation.instructorId;
      Color? color = _classColors[className] ?? Colors.blue;

      Appointment calendarAppointment = Appointment(
        startTime: reservation.fromDate.toDate(),
        isAllDay: true, //  Para mostrar la reserva durante todo el día
        notes: 'Instructor: ${reservation.instructorId}',
        color: color, 
        subject: reservation.className, // Nombre de la clase 
        endTime: reservation.fromDate.toDate().add(const Duration(hours: 2)), //  Fecha de inicio 
      );

      calendarAppointments.add(calendarAppointment);
    }
    
    return calendarAppointments;
  }

  //   Widget para mostrar el calendario y lista de eventos:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reservas),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Widget para mostrar los créditos del usuario 
            CreditsDisplay(creditsStream: _creditsService.getUserCredits()),
            const SizedBox(height: 20),
            //  Botón para crear una reserva. 
            if (widget.isAdmin)
              NewReservationButton(onPressed: _showReservationDialog), 
            const SizedBox(height: 20),

            Expanded(
              child:  //  Calendario con eventos de reserva 
              SfCalendar(
                view: CalendarView.week, 
                firstDayOfWeek: 1, 
                headerStyle: const CalendarHeaderStyle(
                  textAlign: TextAlign.center, 
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w500, 
                    fontSize: 16.0,
                    color: Colors.black87 
                  ),
                ),
                initialDisplayDate: DateTime.now(),
                allowedViews: const [CalendarView.day, CalendarView.week, CalendarView.month],
                controller: CalendarController(), 
                onTap: (CalendarTapDetails details) {
                  _showReservationDialog(); 
                },
                onLongPress: (details) {
                  //   Manejo de gestos de presión larga  
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}