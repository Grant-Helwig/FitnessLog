import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hey_workout/repository/workout_repository.dart';
import 'package:hey_workout/ui/execute_workout_page.dart';
import 'package:hey_workout/ui/workout_profile_page.dart';
import 'package:intl/intl.dart';
import 'package:unicons/unicons.dart';
import '../../model/routine.dart';
import '../../model/workout.dart';
import '../../model/workout_history.dart';
import '../../utils/utils.dart';
import 'dart:async';

import 'bloc/workout_history_bloc.dart';

class WorkoutHistoryPage extends StatelessWidget {
  final Workout? workout;
  const WorkoutHistoryPage(
      {Key? key,
      required this.workout,
      required this.refreshCallback,
      required this.initialDateRange})
      : super(key: key);
  final Function(DateTimeRange result) refreshCallback;
  final DateTimeRange initialDateRange;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => WorkoutHistoryBloc()
        ..add(WorkoutHistoryEvent.started(
          initialDateRange,
          workout,
        )),
      child: _WorkoutHistoryPageState(
          workout: workout, initialDateRange: initialDateRange),
    );
  }
}

class _WorkoutHistoryPageState extends StatelessWidget {
  //used for when we are using the Workout History page from a Workout Profile
  late Workout? workout;
  late DateTimeRange initialDateRange;
  WorkoutRepository repo = WorkoutRepository();

  _WorkoutHistoryPageState(
      {required this.workout, required this.initialDateRange});

  //open the Date Range Picker and save the results
  void selectDates(
      BuildContext context, WorkoutHistoryBloc workoutHistoryBloc) async {
    DateTime now = DateTime.now();
    DateTime dateStart = DateTime(now.year - 5, now.month, now.day);
    DateTime dateEnd = DateTime(now.year, now.month, now.day);
    final DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: dateStart,
        lastDate: dateEnd,
        currentDate: now,
        saveText: 'Done');
    if (result != null) {
      workoutHistoryBloc.add(WorkoutHistoryEvent.updateDateRange(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      body: BlocBuilder<WorkoutHistoryBloc, WorkoutHistoryState>(
        builder: (context, state) {
          final workoutHistoryBloc = context.read<WorkoutHistoryBloc>();
          return state.when(
              initial: () => const CircularProgressIndicator(),
              loaded: ((dateRange, routines, routine, workouts) {
                return Column(
                  children: [
                    //Date Range Button
                    TextButton(
                        onPressed: () =>
                            selectDates(context, workoutHistoryBloc),
                        child: Text(
                          "${DateFormat('yyyy/MM/dd').format(dateRange.start)} - "
                          "${DateFormat('yyyy/MM/dd').format(dateRange.end)}",
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 18),
                        )),
                    const Divider(),

                    //do not show the routine dropdown on the Workout Profile
                    if (workout == null)
                      DropdownButton<Routine>(
                        isExpanded: true,
                        value: routine,
                        icon: const Icon(UniconsLine.angle_down),
                        elevation: 16,
                        style: const TextStyle(color: Colors.white),
                        underline: Container(
                          height: 2,
                          color: Colors.white,
                        ),
                        onChanged: (Routine? newValue) {
                          if (newValue != null) {
                            workoutHistoryBloc.add(
                                WorkoutHistoryEvent.updateRoutine(newValue));
                          }
                        },
                        items: routines
                            .map<DropdownMenuItem<Routine>>((Routine value) {
                          return DropdownMenuItem<Routine>(
                            value: value,
                            child: Text(value.name),
                          );
                        }).toList(),
                      ),

                    //build a list of workout history cards
                    if (workouts.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: workouts.length,
                            itemBuilder: (BuildContext context, int index) =>
                                buildWorkoutCard(context, workouts[index])),
                      )
                    else
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'No History',
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                );
              }));
        },
      ),
    );
  }

  //update and delete are both on long press
  Future<void> updateOptions(
      WorkoutHistory workoutHistory, BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Divider(),
                TextButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    //await addWorkoutHistoryForm(context, false, workoutHistory, true);
                    var workout =
                        await repo.readWorkout(workoutHistory.workoutId);
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ExecuteWorkout(
                                workouts: [workout!],
                                history: workoutHistory)));
                    // setState(() {
                    //   _workoutHistory =
                    //       repo.workoutHistoryByDates(_selectedDateRange!);
                    // });
                  },
                ),
                const Divider(),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await repo.deleteWorkoutHistory(workoutHistory.id);
                    // setState(() {
                    //   _workoutHistory =
                    //       repo.workoutHistoryByDates(_selectedDateRange!);
                    // });
                  },
                ),
                const Divider(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> noWorkoutsAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Workouts'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('No workouts have been added.'),
                Text('Please add workouts before adding history.'),
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

  Widget buildWorkoutCard(BuildContext context, WorkoutHistory workoutHistory) {
    WorkoutType type = WorkoutType.values[workoutHistory.workoutType];

    List<Widget> workoutItems = displayList(workoutHistory);
    //build a card depending on the type of workout
    return Container(
      margin: const EdgeInsets.all(0),
      child: Card(
        child: ListTile(
          onTap: () async {
            //await addWorkoutHistoryForm(context, false, workoutHistory, true);
            if (workout == null) {
              Workout? tempWorkout =
                  await repo.readWorkout(workoutHistory.workoutId);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          WorkoutProfile(workout: tempWorkout!)));
            }
          },
          onLongPress: () async {
            await updateOptions(workoutHistory, context);
          },
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('${workoutHistory.workoutName} '),
                    const Spacer(),
                    Text(
                      DateFormat('yyyy/MM/dd hh:mm a')
                          .format(DateTime.parse(workoutHistory.date)),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.white54,
              ),
              Container(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: workoutHistory.sets.isNotEmpty
                      ? ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: workoutHistory.sets.length,
                          itemBuilder: (BuildContext context, int index) {
                            return AspectRatio(
                              aspectRatio: MediaQuery.of(context).size.width /
                                  (MediaQuery.of(context).size.height / 24),
                              child: Row(
                                children: [
                                  Text(
                                      '${Utils().getWorkoutHistoryString(workoutHistory.sets[index].weight) ?? "No"} LBS'),
                                  const Spacer(),
                                  Text(
                                      '${Utils().getWorkoutHistoryString(workoutHistory.sets[index].reps) ?? "No"} Reps'),
                                ],
                              ),
                            );
                          })
                      : SizedBox.shrink()),
              workoutHistory.sets.isNotEmpty
                  ? const Divider(
                      color: Colors.white54,
                    )
                  : SizedBox.shrink(),
              workoutItems.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                      child: GridView.builder(
                        shrinkWrap: true,
                        primary: false,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: MediaQuery.of(context).size.width /
                              (MediaQuery.of(context).size.height / 12),
                          crossAxisCount: 2,
                        ),
                        itemCount: workoutItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          return workoutItems[index];
                        },
                      ))
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> displayList(WorkoutHistory workoutHistory) {
    List<Widget> historyList = [];
    var heartRate = Utils().getWorkoutHistoryString(workoutHistory.heartRate);
    var calories = Utils().getWorkoutHistoryString(workoutHistory.calories);
    var distance = Utils().getWorkoutHistoryString(workoutHistory.distance);
    log(workoutHistory.duration);
    var duration = workoutHistory.duration == "00:00:00.00"
        ? null
        : workoutHistory.duration;

    if (heartRate != null) {
      historyList.add(Text(
        '$heartRate BPM',
        textAlign:
            historyList.length % 2 == 0 ? TextAlign.left : TextAlign.right,
      ));
    }

    if (calories != null) {
      historyList.add(Text(
        '$calories Calories',
        textAlign:
            historyList.length % 2 == 0 ? TextAlign.left : TextAlign.right,
      ));
    }

    if (distance != null) {
      historyList.add(Text(
        '$distance Mi',
        textAlign:
            historyList.length % 2 == 0 ? TextAlign.left : TextAlign.right,
      ));
    }

    if (duration != null) {
      historyList.add(Text(
        'Duration: $duration',
        textAlign:
            historyList.length % 2 == 0 ? TextAlign.left : TextAlign.right,
      ));
    }

    return historyList;
  }
}
