import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ReservationsService _reservationsService = ReservationsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Reservation>>(
        stream: _reservationsService.getReservations(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Reservation> reservations = snapshot.data!;
            return SfCalendar(
              view: CalendarView.month,
              dataSource: MeetingDataSource(reservations),
              monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(this.reservations);

  final List<Reservation> reservations;

  @override
  DateTime getStartTime(int index) {
    return reservations[index].fromDate.toDate();
  }

  @override
  DateTime getEndTime(int index) {
    return reservations[index].toDate.toDate();
  }

  @override
  String getSubject(int index) {
    return reservations[index].className;
  }

  @override
  Color getColor(int index) {
    return const Color(0xFF0F8644);
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}