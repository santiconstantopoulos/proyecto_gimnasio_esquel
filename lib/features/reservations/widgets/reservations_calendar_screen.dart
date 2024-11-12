import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';

class CalendarScreen extends StatelessWidget {
  final Stream<List<Reservation>> reservationsStream;

  const CalendarScreen({super.key, required this.reservationsStream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Reservation>>(
        stream: reservationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Reservation> reservations = snapshot.data!;
            return SfCalendar(
              view: CalendarView.workWeek,
              dataSource: MeetingDataSource(reservations),
              monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment),
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
  MeetingDataSource(List<Reservation> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].fromDate.toDate().toLocal();
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].toDate.toDate().toLocal();
  }

  @override
  String getSubject(int index) {
    return appointments![index].className;
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
