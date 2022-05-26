
import 'package:draw_graph/draw_graph.dart';
import 'package:draw_graph/models/feature.dart';
import 'package:flutter/material.dart';
import 'package:hey_workout/model/weight.dart';
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


class WeightGraphs extends StatefulWidget {
  const WeightGraphs({Key? key, required this.refreshCallback, required this.initialDateRange}) : super(key: key);
  final Function(DateTimeRange result) refreshCallback;
  final DateTimeRange initialDateRange;

  @override
  State<WeightGraphs> createState() =>
      _WeightGraphsState(initialDateRange: this.initialDateRange);

}

class _WeightGraphsState extends State<WeightGraphs> {
  late Future<List<Weight>?> weightHistory;
  late DateTimeRange initialDateRange;
  WorkoutRepository repo = WorkoutRepository();
  late DateTimeRange _selectedDateRange = initialDateRange;
  _WeightGraphsState({required this.initialDateRange});


  @override
  void initState() {
    super.initState();
    weightHistory = repo.readAllWeightsByDate(_selectedDateRange);

  }
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
        weightHistory = repo.readAllWeightsByDate(_selectedDateRange);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: FutureBuilder<List<Weight>?>(
            future: weightHistory,
            builder: (context, projectSnap) {
              Widget? graphs =
              _graphFeaturesByWeightAndDate(projectSnap.data, context);
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


  Widget? _graphFeaturesByWeightAndDate(List<Weight>? weight, BuildContext context) {

    if (weight == null || weight.isEmpty) {
      return null;
    } else {
      weight.sort((a, b) {
        return a.date.compareTo(b.date);
      });

      //feature is the object that holds graph data
      List<Feature> features = [];

      //for width, if the width is less than the srceen width we want (400)? then do
      //60 width per item
      double graphWidth = MediaQuery.of(context).size.width - 40;
      if (graphWidth < weight.length * 60) {
        graphWidth = weight.length * 60;
      }

      //string for the x axis display
      List<String> dates = [];

      //string for the x axis display that only show first last
      List<String> compressedDates = [];


      //values for each attribute to graph
      List<double> dataWeight = [];

      //graph only goes from 0-1 so we need to use fractions with the max values
      double highestWeight =
          weight.reduce((a, b) => a.weight > b.weight ? a : b).weight;

      //set the fraction values and the date values
      for (var history in weight) {
        dataWeight.add(history.weight / highestWeight);

        dates.add(DateFormat("MM/dd").format(DateTime.parse(history.date)));

        compressedDates.add("");
      }

      compressedDates[0] = dates[0];
      compressedDates[dates.length-1] = dates[dates.length-1];

      features
          .add(Feature(title: "Weight", color: myRed, data: dataWeight));

      return SingleChildScrollView(
        child: Column(children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Max Weight: ${highestWeight} LBS"),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LineGraph(
                  features: features,
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
        ]),
      );
    }
  }
}


