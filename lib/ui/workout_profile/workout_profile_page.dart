import 'package:hey_workout/repository/workout_repository.dart';
import 'package:hey_workout/ui/execute_workout_page.dart';
import 'package:hey_workout/ui/workout_graph_page.dart';
import 'package:hey_workout/ui/workout_history/workout_history_page.dart';
import 'package:unicons/unicons.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import '../../model/workout.dart';
import '../../model/workout_history.dart';
import '../../utils/utils.dart';

class WorkoutProfile extends StatelessWidget {
  final Workout workout;
  const WorkoutProfile({Key? key, required this.workout}) : super(key: key);

  @override
  Widget build(BuildContext context) => _WorkoutProfileState(workout: workout);
}

class _WorkoutProfileState extends StatelessWidget {
  late Workout workout;
  final WorkoutRepository repo = WorkoutRepository();
  _WorkoutProfileState({required this.workout});

  Future<void> exitWorkoutAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quit Workout'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('You have not saved your workout.'),
                Text('Are you sure you want to exit?'),
                Text('All unsaved progress will be lost'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Quit'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  DateTimeRange dateTimeRange = Utils().weekRange();
  @override
  Widget build(BuildContext context) {
    log("current workout is ${workout.name}");
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ExecuteWorkout(workouts: [workout])));
                },
                icon: const Icon(UniconsLine.play))
          ],
          centerTitle: true,
          title: Text(
            workout.name,
            textAlign: TextAlign.center,
          ),
          bottom: const TabBar(indicatorColor: Colors.white, tabs: <Widget>[
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
            WorkoutHistoryPage(
              refreshCallback: (DateTimeRange result) {
                dateTimeRange = result;
              },
              initialDateRange: dateTimeRange,
              workout: workout,
            ),
            WorkoutGraphs(
                refreshCallback: (DateTimeRange result) {
                  dateTimeRange = result;
                },
                initialDateRange: dateTimeRange,
                workout: workout)
          ],
        ),
      ),
    );
  }
}
