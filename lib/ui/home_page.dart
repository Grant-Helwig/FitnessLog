
import 'package:flutter/material.dart';
import 'package:hey_workout/ui/routine_page.dart';
import 'package:hey_workout/ui/weight_profile_page.dart';
import 'package:hey_workout/ui/workout_history/workout_history_page.dart';
import 'package:hey_workout/ui/workout_page.dart';
import 'package:unicons/unicons.dart';

import '../utils/utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTimeRange dateTimeRange = Utils().weekRange();
  //main page that has 3 tabs
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,

          //Tool and Weight Tracking Features to add later
          leading: IconButton(
            icon: const Icon(UniconsLine.wrench),
            onPressed: () async {
              await toolsAlert();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(UniconsLine.weight),
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const WeightProfile()));
              },
            ),
          ],
          title: const Text(
            "Fitness Log",
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
                      'Workouts',
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
                      'Routines',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                )
              ]),
        ),
        body: TabBarView(
          children: <Widget>[
            //Null workout object because we are viewing history for all workouts
            WorkoutHistoryPage(refreshCallback: (DateTimeRange result) {
              dateTimeRange = result;
              setState(() {});
            },
                initialDateRange: dateTimeRange,
                workout: null),
            WorkoutPage(),
            RoutinePage()
          ],
        ),
      ),
    );
  }

  Future<void> toolsAlert() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tools'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Tools Coming Soon!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> weightAlert() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Weight Tracking'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Weight Tracking Coming Soon!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
