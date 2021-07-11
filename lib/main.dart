// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(CalendarTrackerApp());

class CalendarTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Calendar Tracker',
        theme: ThemeData(primaryColor: Colors.black),
        home: Calendar());
  }
}

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;

  Map<DateTime, bool> _daysColored = {};

  Color _transparentColor = Colors.transparent;
  Color _focusedDayColor = Colors.lightBlue;

  Color _firstColor = Colors.green;
  Color _secondColor = Colors.red;

  _setDayColored(DateTime day) {
    if (_daysColored[day] == true) {
      _daysColored[day] = false;
    } else {
      _daysColored[day] = true;
    }
  }

  _getDayColored(day) {
    if (_daysColored[day] != null) {
      return _daysColored[day];
    } else {
      return false;
    }
  }

  Center _getDayColorTile(day, color) {
    DateFormat _dateFormat;
    if (day.day < 10) {
      _dateFormat = DateFormat('d');
    } else {
      _dateFormat = DateFormat('dd');
    }

    return Center(
        child: Container(
      color: color,
      child: new Text(_dateFormat.format(day)),
      alignment: Alignment(0.0, 0.0),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Calendar Tracker')),
        body: TableCalendar(
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2030, 1, 31),
            focusedDay: DateTime.now(),
            pageJumpingEnabled: false,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            calendarFormat: _calendarFormat,
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                if (day.weekday == DateTime.sunday) {
                  final text = DateFormat.E().format(day);

                  return Center(
                    child: Text(
                      text,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
              },
              defaultBuilder: (context, day, focusedDay) {
                if (_getDayColored(day)) {
                  return _getDayColorTile(day, _firstColor);
                }
              },
              selectedBuilder: (context, day, focusedDay) {
                if (day.month != focusedDay.month) {
                  return _getDayColorTile(day, _transparentColor);
                }

                _setDayColored(day);
                if (_getDayColored(day)) {
                  return _getDayColorTile(day, _firstColor);
                } else {
                  if (day == focusedDay) {
                    return _getDayColorTile(day, _focusedDayColor);
                  } else {
                    return _getDayColorTile(day, _transparentColor);
                  }
                }
              },
              todayBuilder: (context, day, focusedDay) {
                if (_getDayColored(day)) {
                  return _getDayColorTile(day, _firstColor);
                } else {
                  return _getDayColorTile(day, _focusedDayColor);
                }
              },
            )));
  }
}
