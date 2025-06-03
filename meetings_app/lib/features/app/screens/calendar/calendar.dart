import 'package:flutter/material.dart';
import 'package:meetings_app/features/app/screens/calendar/widgets/event_list.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/controllers/calendar_controller.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    // Cargar los eventos en el controlador
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalendarController>(context, listen: false).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);
    final calendarController = Provider.of<CalendarController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: dark ? LColors.dark : LColors.light,
      ),
      backgroundColor:
          dark ? LColors.dark.withValues(alpha: 0.95) : LColors.light.withValues(alpha: 0.95),
      body: Column(
        children: [
          TableCalendar<Event>(
            focusedDay: _focusedDay,
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2026, 12, 31),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: dark ? LColors.primary : LColors.accent,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: dark ? LColors.accent2 : LColors.primary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(
                color: dark ? LColors.textWhite : Colors.redAccent,
              ),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                color: dark ? LColors.textWhite : LColors.dark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: dark ? LColors.textWhite : LColors.dark),
              rightChevronIcon: Icon(Icons.chevron_right, color: dark ? LColors.textWhite : LColors.dark),
            ),
            eventLoader: (day) {
              return calendarController.getEventsForDay(day);
            },
          ),
          const SizedBox(height: 16),
          // Mostrar la descripción o lista de eventos para el día seleccionado.
          Expanded(
            child: CalendarEventList(selectedDay: _selectedDay, controller: calendarController),
          ),
        ],
      ),
    );
  }
}

