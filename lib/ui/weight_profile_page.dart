import 'package:hey_workout/repository/workout_repository.dart';
import 'package:hey_workout/ui/weight_graph_page.dart';
import 'package:hey_workout/ui/weight_history_page.dart';
import 'package:hey_workout/ui/workout_graph_page.dart';
import 'package:hey_workout/ui/workout_history_page.dart';
import 'package:unicons/unicons.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import '../model/workout.dart';
import '../model/workout_history.dart';
import '../utils/utils.dart';

class WeightProfile extends StatefulWidget {
  const WeightProfile({Key? key}) : super(key: key);

  @override
  State<WeightProfile> createState() =>
      _WeightProfileState();
}

class _WeightProfileState extends State<WeightProfile> {

  final WorkoutRepository repo = WorkoutRepository();

  DateTimeRange dateTimeRange = Utils().weekRange();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Weight Profile",
            textAlign: TextAlign.center,
          ),
          bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: <Widget>[
                SizedBox(
                  height: 30.0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'History',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Metrics',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                )
              ]),
        ),
        body: TabBarView(
          children: <Widget>[
            //use same workout history page but with context this time
            WeightHistory(refreshCallback: (DateTimeRange result) {
              dateTimeRange = result;
              setState(() {});
            },
              initialDateRange: dateTimeRange,),
            WeightGraphs( refreshCallback: (DateTimeRange result) {
              dateTimeRange = result;
              setState(() {});
            },
              initialDateRange: dateTimeRange,)
          ],
        ),
      ),
    );
  }
}