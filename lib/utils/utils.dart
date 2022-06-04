
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';

class Utils {
  DateTimeRange todayRange() {
    DateTime now = DateTime.now();
    DateTime dateStart = DateTime(now.year, now.month, now.day);
    DateTime dateEnd = DateTime(now.year, now.month, now.day);
    return DateTimeRange(start: dateStart, end: dateEnd);
  }

  DateTimeRange weekRange() {
    DateTime now = DateTime.now();
    DateTime dateStart = DateTime(now.year, now.month, now.day - 7);
    DateTime dateEnd = DateTime(now.year, now.month, now.day);
    return DateTimeRange(start: dateStart, end: dateEnd);
  }

  bool datesEqual(DateTime one, DateTime two) {
    return one.year == two.year && one.month == two.month && one.day == two.day;
  }

  // Color getWorkoutColor(WorkoutType workoutType){
  //   switch(workoutType) {
  //     case WorkoutType.strength:
  //       return myRed;
  //     case WorkoutType.cardio:
  //       return myBlue;
  //     case WorkoutType.both:
  //       return myPurple;
  //   }
  // }

  String? getWorkoutHistoryString(dynamic number){
    if(number is int || number is double){
      return number == 0 ? null : number.toString();
    } else {
      return null;
    }
  }

  Future<Duration> selectDuration(BuildContext context, Duration defaultDuration) async {
    Duration _duration = const Duration();
    log((((defaultDuration.inSeconds / 60) / 60) / 60).floor().toString());
    var temp = await Picker(
      adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
        NumberPickerColumn(begin: 0, end: 999, suffix: const Text('h'), initValue: ((defaultDuration.inSeconds / 60) / 60).floor()),
        NumberPickerColumn(begin: 0, end: 60, suffix: const Text('m'), initValue: defaultDuration.inMinutes % 60),
        NumberPickerColumn(begin: 0, end: 60, suffix: const Text('s'), initValue: defaultDuration.inSeconds % 60),
      ]),
      delimiter: <PickerDelimiter>[
        PickerDelimiter(
          child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Icon(Icons.more_vert),
          ),
        )
      ],
      hideHeader: true,
      confirmText: 'OK',
      confirmTextStyle: TextStyle(inherit: false, color: Colors.red, fontSize: 22),
      title: const Text('Select duration'),
      selectedTextStyle: TextStyle(color: Colors.blue),
      onConfirm: (Picker picker, List<int> value) {
        // You get your duration here
        _duration = Duration(hours: picker.getSelectedValues()[0], minutes: picker.getSelectedValues()[1], seconds: picker.getSelectedValues()[2]);
      },
      onCancel: (){
        _duration = defaultDuration;
      }
    ).showDialog(context);
    return _duration;
  }

  String printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    int ms = duration.inMilliseconds.remainder(1000);
    // log(duration.inMilliseconds.toString());
    // log(ms.toString());
    String twoDigitMilliseconds = twoDigits( ms > 1000 ? (ms / 10).ceil() : (ms ~/ 10));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds.$twoDigitMilliseconds";
  }

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

}