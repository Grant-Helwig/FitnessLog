
import 'package:draw_graph/draw_graph.dart';
import 'package:draw_graph/models/feature.dart';
import 'package:flutter/material.dart';
import 'package:hey_workout/repository/workout_repository.dart';
import 'package:intl/intl.dart';

import '../model/workout.dart';
import '../model/workout_history.dart';
import '../utils/utils.dart';

const Color myRed = Color.fromRGBO(255, 105, 97, 1);
const Color myYellow = Color.fromRGBO(248, 243, 141, 1);
const Color myPurple = Color.fromRGBO(199, 128, 232, 1);
const Color myGreen = Color.fromRGBO(77, 245, 77, 1);
const Color myBlue = Color.fromRGBO(89, 173, 246,1);
const Color myOrange = Color.fromRGBO(255, 180, 128, 1);
const Color myBlueGreen = Color.fromRGBO(66, 214, 164, 1);
const Color myYellowGreen = Color.fromRGBO(157, 148, 255, 1);


class WorkoutGraphs extends StatefulWidget {
  final Workout workout;
  const WorkoutGraphs({Key? key, required this.workout, required this.refreshCallback, required this.initialDateRange}) : super(key: key);
  final Function(DateTimeRange result) refreshCallback;
  final DateTimeRange initialDateRange;

  @override
  State<WorkoutGraphs> createState() =>
      _WorkoutGraphsState(workout: this.workout, initialDateRange: this.initialDateRange);
}

class _WorkoutGraphsState extends State<WorkoutGraphs> {
  late Workout workout;
  late Future<List<WorkoutHistory>?> workoutHistory;
  late DateTimeRange initialDateRange;
  WorkoutRepository repo = WorkoutRepository();
  late DateTimeRange _selectedDateRange = initialDateRange;
  _WorkoutGraphsState({required this.workout, required this.initialDateRange});

  void selectDates() async {
    DateTime now = DateTime.now();
    DateTime dateStart = DateTime(now.year - 5, now.month, now.day);
    DateTime dateEnd = DateTime(now.year, now.month, now.day);
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: dateStart,
      lastDate: dateEnd,
      currentDate: now,
      saveText: 'Done',
    );

    if (result != null) {
      setState(() {
        _selectedDateRange = result;
        widget.refreshCallback(result);
        workoutHistory =
            repo.workoutHistoryByWorkoutAndDates(workout.id, _selectedDateRange);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (workout != null) {
      workoutHistory =
          repo.workoutHistoryByWorkoutAndDates(workout.id, _selectedDateRange);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton(
            onPressed: selectDates,
            child: Text(
              "${DateFormat('yyyy/MM/dd').format(_selectedDateRange.start)} - "
                  "${DateFormat('yyyy/MM/dd').format(_selectedDateRange.end)}",
              style: const TextStyle(color: Colors.grey, fontSize: 18),
            )),
        const Divider(),

        //return a list of graph cards based on the workout history and workout type
        Expanded(
          child: FutureBuilder<List<WorkoutHistory>?>(
            future: workoutHistory,
            builder: (context, projectSnap) {
              Widget? graphs =
              _graphFeaturesByWorkoutAndDate(projectSnap.data, context);
              if (projectSnap.hasData && graphs != null && projectSnap.data!.length > 1) {
                return graphs;
              } else {
                return const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'No data',
                    textAlign: TextAlign.center,
                  ),
                );
              }
            },
          ),
        )
      ],
    );
  }


  Widget? _graphFeaturesByWorkoutAndDate(List<WorkoutHistory>? workoutHistory, BuildContext context) {

    if (workoutHistory == null || workoutHistory.isEmpty) {
      return null;
    } else {
      workoutHistory.sort((a, b) {
        return a.date.compareTo(b.date);
      });

      //feature is the object that holds graph data
      List<Feature> features = [];

      //match case with workout type
      //get the attributes that should be graphed, and construct a feature for each
      WorkoutType type = WorkoutType.values[workoutHistory[0].workoutType];

      //for width, if the width is less than the srceen width we want (400)? then do
      //60 width per item
      double graphWidth = MediaQuery.of(context).size.width - 40;
      if (graphWidth < workoutHistory.length * 60) {
        graphWidth = workoutHistory.length * 60;
      }

      //string for the x axis display
      List<String> dates = [];

      //string for the x axis display that only show first last
      List<String> compressedDates = [];

      //same process for each workout type, using different workout history attributes
      switch (type) {
        case WorkoutType.strength:

        //values for each attribute to graph
          List<double> dataWeight = [];
          List<double> dataSet = [];
          List<double> dataRep = [];

          //graph only goes from 0-1 so we need to use fractions with the max values
          double highestWeight =
              workoutHistory.reduce((a, b) => a.weight > b.weight ? a : b).weight;
          double highestSet = workoutHistory
              .reduce((a, b) => a.sets > b.sets ? a : b)
              .sets
              .toDouble();
          double highestRep = workoutHistory
              .reduce((a, b) => a.reps > b.reps ? a : b)
              .reps
              .toDouble();

          //set the fraction values and the date values
          for (var history in workoutHistory) {
            dataWeight.add(history.weight / highestWeight);
            dataSet.add(history.sets.toDouble() / highestSet);
            dataRep.add(history.reps.toDouble() / highestRep);

            dates.add(DateFormat("MM/dd").format(DateTime.parse(history.date)));

            compressedDates.add("");
          }

          compressedDates[0] = dates[0];
          compressedDates[dates.length-1] = dates[dates.length-1];

          features
              .add(Feature(title: "Weight", color: myRed, data: dataWeight));
          features
              .add(Feature(title: "Sets", color: myBlue, data: dataSet));
          features
              .add(Feature(title: "Reps", color: myPurple, data: dataRep));

          return SingleChildScrollView(
            child: Column(children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Weight $highestWeight LBS"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[0]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        (highestWeight / 2).round().toString(),
                        highestWeight.round().toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Sets $highestSet "),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[1]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        (highestSet / 2).round().toString(),
                        highestSet.round().toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Reps $highestRep"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[2]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        (highestRep / 2).round().toString(),
                        highestRep.round().toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Comparison"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: features,
                      size: Size(MediaQuery.of(context).size.width - 40, 400),
                      labelX: compressedDates,
                      labelY: const [""],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ]),
          );
      //return features;
        case WorkoutType.cardio:
          List<double> dataDuration = [];
          double highestDuration =
          Utils().parseDuration(workoutHistory.reduce((a, b)
          => Utils().parseDuration(a.duration).inSeconds > Utils().parseDuration(b.duration).inSeconds ? a : b).duration).inSeconds.toDouble();
          List<double> dataDistance = [];
          double highestDistance =
              workoutHistory.reduce((a, b) => a.distance > b.distance ? a : b).distance;
          List<double> dataCalories = [];
          double highestCalories =
              workoutHistory.reduce((a, b) => a.calories > b.calories ? a : b).calories;
          List<double> dataHeartRate = [];
          double highestHeartRate =
              workoutHistory.reduce((a, b) => a.heartRate > b.heartRate ? a : b).heartRate;

          for (var history in workoutHistory) {
            dataDuration.add(Utils().parseDuration(history.duration).inSeconds / highestDuration);
            dataDistance.add(history.distance / highestDistance);
            dataCalories.add(history.calories / highestCalories);
            dataHeartRate.add(history.heartRate / highestHeartRate);

            dates.add(DateFormat("MM/dd").format(DateTime.parse(history.date)));
            compressedDates.add("");
          }

          compressedDates[0] = dates[0];
          compressedDates[dates.length-1] = dates[dates.length-1];
          features.add(
              Feature(title: "Duration", color: myRed, data: dataDuration));
          features.add(
              Feature(title: "Distance", color: myBlue, data: dataDistance));
          features.add(
              Feature(title: "Calories", color: myPurple, data: dataCalories));
          features.add(
              Feature(title: "Heart Rate", color: myGreen, data: dataHeartRate));
          return SingleChildScrollView(
            child: Column(children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Duration $highestDuration Seconds"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[0]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        (highestDuration / 2).round().toString(),
                        highestDuration.round().toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Distance $highestDistance Miles"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[1]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        double.parse((highestDistance / 2).toStringAsFixed(2)).toString(),
                        double.parse((highestDistance).toStringAsFixed(2)).toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Calories $highestCalories"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[2]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        double.parse((highestCalories / 2).toStringAsFixed(2)).toString(),
                        double.parse((highestCalories).toStringAsFixed(2)).toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Heart Rate $highestDistance BPM"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[3]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        double.parse((highestHeartRate / 2).toStringAsFixed(2)).toString(),
                        double.parse((highestHeartRate).toStringAsFixed(2)).toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Comparison"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: features,
                      size: Size(MediaQuery.of(context).size.width - 40, 400),
                      labelX: compressedDates,
                      labelY: const [""],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ]),
          );
        case WorkoutType.both:
          List<double> dataWeight = [];
          double highestWeight =
              workoutHistory.reduce((a, b) => a.weight > b.weight ? a : b).weight;

          List<double> dataDuration = [];
          double highestDuration =
          Utils().parseDuration(workoutHistory.reduce((a, b)
          => Utils().parseDuration(a.duration).inSeconds > Utils().parseDuration(b.duration).inSeconds ? a : b).duration).inSeconds.toDouble();

          List<double> dataDistance = [];
          double highestDistance =
              workoutHistory.reduce((a, b) => a.distance > b.distance ? a : b).distance;
          List<double> dataCalories = [];
          double highestCalories =
              workoutHistory.reduce((a, b) => a.calories > b.calories ? a : b).calories;
          List<double> dataHeartRate = [];
          double highestHeartRate =
              workoutHistory.reduce((a, b) => a.heartRate > b.heartRate ? a : b).heartRate;

          List<double> dataSet = [];
          List<double> dataRep = [];
          double highestSet = workoutHistory
              .reduce((a, b) => a.sets > b.sets ? a : b)
              .sets
              .toDouble();
          double highestRep = workoutHistory
              .reduce((a, b) => a.reps > b.reps ? a : b)
              .reps
              .toDouble();

          for (var history in workoutHistory) {
            dataWeight.add(history.weight / highestWeight);
            dataDuration.add(Utils().parseDuration(history.duration).inSeconds / highestDuration);


            dataDistance.add(history.distance / highestDistance);
            dataCalories.add(history.calories / highestCalories);
            dataHeartRate.add(history.heartRate / highestHeartRate);


            dataSet.add(history.sets.toDouble() / highestSet);
            dataRep.add(history.reps.toDouble() / highestRep);

            dates.add(DateFormat("MM/dd").format(DateTime.parse(history.date)));
            compressedDates.add("");
          }

          compressedDates[0] = dates[0];
          compressedDates[dates.length-1] = dates[dates.length-1];

          features
              .add(Feature(title: "Weight", color: myRed, data: dataWeight));
          features
              .add(Feature(title: "Sets", color: myBlue, data: dataSet));
          features
              .add(Feature(title: "Reps", color: myPurple, data: dataRep));

          features.add(
              Feature(title: "Duration", color: myRed, data: dataDuration));
          features.add(
              Feature(title: "Distance", color: myBlue, data: dataDistance));
          features.add(
              Feature(title: "Calories", color: myPurple, data: dataCalories));
          features.add(
              Feature(title: "Heart Rate", color: myGreen, data: dataHeartRate));
          return SingleChildScrollView(
            child: Column(children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Weight $highestWeight LBS"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[0]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        (highestWeight / 2).round().toString(),
                        highestWeight.round().toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Sets $highestSet "),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[1]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        (highestSet / 2).round().toString(),
                        highestSet.round().toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Reps $highestRep"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[2]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        (highestRep / 2).round().toString(),
                        highestRep.round().toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Strength Comparison"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: features.sublist(0,3),
                      size: Size(MediaQuery.of(context).size.width - 40, 400),
                      labelX: compressedDates,
                      labelY: const [""],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Duration $highestDuration Seconds"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[3]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        (highestDuration / 2).round().toString(),
                        highestDuration.round().toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Distance $highestDistance Miles"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[4]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        double.parse((highestDistance / 2).toStringAsFixed(2)).toString(),
                        double.parse((highestDistance).toStringAsFixed(2)).toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Calories $highestCalories"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[5]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        double.parse((highestCalories / 2).toStringAsFixed(2)).toString(),
                        double.parse((highestCalories).toStringAsFixed(2)).toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Max Heart Rate $highestDistance BPM"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: [features[6]],
                      size: Size(graphWidth, 400),
                      labelX: dates,
                      labelY: [
                        double.parse((highestHeartRate / 2).toStringAsFixed(2)).toString(),
                        double.parse((highestHeartRate).toStringAsFixed(2)).toString()
                      ],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Cardio Comparison"),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineGraph(
                      features: features.sublist(3,7),
                      size: Size(MediaQuery.of(context).size.width - 40, 400),
                      labelX: compressedDates,
                      labelY: const [""],
                      showDescription: true,
                      graphColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ]),
          );
      }
    }
  }

}


