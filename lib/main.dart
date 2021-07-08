// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

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
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay; // update `_focusedDay` here as well
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            // eventLoader: (day) {
            //   return _events;
            // },
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
                  if (day == focusedDay) {
                    return _getDayColorTile(day, _focusedDayColor);
                  } else {
                    return _getDayColorTile(day, _firstColor);
                  }
                }
              },
              selectedBuilder: (context, day, focusedDay) {
                _setDayColored(day);
                if (_getDayColored(day) == false) {
                  if (day == focusedDay) {
                    return _getDayColorTile(day, _focusedDayColor);
                  } else {
                    return _getDayColorTile(day, _transparentColor);
                  }
                } else {
                  return _getDayColorTile(day, _firstColor);
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

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Startup Name Generator'), actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ]),
        body: _buildSuggestions());
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();

          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair); // boolean
    return ListTile(
        title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
        ),
        onTap: () {
          setState(() {
            if (alreadySaved) {
              _saved.remove(pair);
            } else {
              _saved.add(pair);
            }
          });
        });
  }

  void _pushSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      final tiles = _saved.map((WordPair pair) {
        return ListTile(
            title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ));
      });
      final divided = tiles.isNotEmpty
          ? ListTile.divideTiles(context: context, tiles: tiles).toList()
          : <Widget>[];
      return Scaffold(
        appBar: AppBar(
          title: Text('Saved Suggestions'),
        ),
        body: ListView(children: divided),
      );
    }));
  }
}
