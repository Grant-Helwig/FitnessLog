import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hey_workout/repository/workout_repository.dart';
import 'package:intl/intl.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:unicons/unicons.dart';

import '../model/routine.dart';
import '../model/set.dart';
import '../model/workout.dart';
import '../model/workout_history.dart';
import '../utils/utils.dart';

class ExecuteWorkout extends StatefulWidget {
  final Routine? routine;
  final WorkoutHistory? history;
  final List<Workout>? workouts;
  const ExecuteWorkout({Key? key, required this.workouts, this.routine, this.history}) : super(key: key);

  @override
  State<ExecuteWorkout> createState() =>
      _ExecuteWorkoutState(workouts: this.workouts, routine: this.routine, history: this.history);
}

class _ExecuteWorkoutState extends State<ExecuteWorkout> {

  WorkoutRepository repo = WorkoutRepository();
  //need multiple forms to validate each workout separately
  List<GlobalKey<FormState>> formKeys = [];

  //used to hide the fields when each card is done
  List<bool> cardsCompleted = [];

  late List<Workout>? workouts;

  late Routine? routine;
  late WorkoutHistory? history;
  Duration stopWatchDuration = const Duration();
  late StopWatchTimer stopWatchTimer = StopWatchTimer(
    onChange: (value) {
      stopWatchDuration = Duration(milliseconds: value);
    }
  );

  _ExecuteWorkoutState({required this.workouts, this.routine, this.history});

  @override
  Widget build(BuildContext context) {
    return executeWorkout(context);
  }

  Future<void> executeStopWatch() async {

    return await showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: AlertDialog(
                  scrollable: true,
                  actions: [
                    TextButton(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                  content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StreamBuilder<int>(
                                stream: stopWatchTimer.rawTime,
                                initialData: stopWatchTimer.rawTime.value,
                                builder: (context, snap) {
                                  final value = snap.data!;
                                  final displayTime =
                                  StopWatchTimer.getDisplayTime(value, hours: true);
                                  return Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          displayTime,
                                          style: const TextStyle(
                                              fontSize: 30,
                                              fontFamily: 'Helvetica',
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: stopWatchTimer.isRunning ? MaterialStateProperty.all(Colors.orange)
                                                    : MaterialStateProperty.all(Colors.green),
                                              ),
                                              onPressed: () async {
                                                //_stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                                                // _stopWatchTimer.isRunning ? _stopWatchTimer.onExecute.add(StopWatchExecute.stop)
                                                //     : _stopWatchTimer.onExecute.add(StopWatchExecute.start);

                                                if(stopWatchTimer.isRunning){
                                                  //stopWatchDuration = Duration(milliseconds: value);
                                                  stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                                                } else {
                                                  stopWatchTimer.onExecute.add(StopWatchExecute.start);
                                                }
                                              },
                                              child: Text(
                                                stopWatchTimer.isRunning ? "Stop" : "Start",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.red),
                                              ),
                                              onPressed: () async {
                                                stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                                              },
                                              child: const Text(
                                                'Reset',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ]
                        );
                      }
                  )
              )
          );
        }
    );
  }

  Widget executeWorkout(BuildContext context) {
    //workouts = repo.readAllWorkoutsByRoutine(routine.id);
    formKeys = [];
    cardsCompleted = [];

    //get the workouts from the entries in order, then construct a list of execute workout cards
    return WillPopScope(
      onWillPop: () async {
        if(cardsCompleted.every((element) => element == true)){
          return true;
        }
        bool willLeave = false;
        // show the confirm dialog
        await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Quit Workout'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text('You have not saved your workout.'),
                    Text('Are you sure you want to exit?'),
                    Text('All unsaved progress will be lost.'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      willLeave = true;
                      Navigator.of(context).pop();
                    },
                    child: const Text('Yes')),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('No'))
              ],
            ));
        return willLeave;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            routine == null ? workouts![0].name : routine!.name,
            textAlign: TextAlign.center,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 10, top: 10),
                        itemCount: workouts == null? 0 : workouts!.length,
                        itemBuilder: (BuildContext context, int index) {
                          if(workouts != null) {
                            formKeys.add(GlobalKey<FormState>());
                            cardsCompleted.add(false);
                            return executeWorkoutCard(workouts![index], index);
                          } else {
                            return const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'No Workout(s)',
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                        }
                        )
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
           await executeStopWatch();
          },
          tooltip: 'Stopwatch',
          child: const Icon(UniconsLine.stopwatch),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget executeWorkoutCard(Workout workout, int index) {
    List<TextEditingController> weightControllers = [TextEditingController()];
    TextEditingController timerController = TextEditingController(text: Utils().printDuration(const Duration()));//Duration().toString().substring(0, Duration().toString().indexOf('.')));
    List<TextEditingController> repControllers = [TextEditingController()];
    TextEditingController distanceController = TextEditingController();
    TextEditingController caloriesController = TextEditingController();
    TextEditingController heartRateController = TextEditingController();
    List<WorkoutSet> sets = [];

    DateTime myDateTime = DateTime.now();
    TextEditingController dateController = TextEditingController(text: DateFormat('yyyy/MM/dd').format(myDateTime));
    TextEditingController timeController = TextEditingController(text: DateFormat('hh:mm a').format(myDateTime));
    bool hasDefault = true;
    //use similar logic to workout history page to validate the card and display the fields
    Future<WorkoutHistory?> recentHistory =
    repo.mostRecentWorkoutHistoryByWorkout(workout.id);

    if(history != null){
        recentHistory =   Future.value(history);
    } else {
      recentHistory =
          repo.mostRecentWorkoutHistoryByWorkout(workout.id);
    }

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return FutureBuilder<WorkoutHistory?>(
            future: recentHistory,
            builder: (context, snapshot) {
              if (snapshot.hasData ) {
                if(hasDefault){
                  repControllers.clear();
                  weightControllers.clear();
                  timerController = TextEditingController(
                      text: snapshot.data!.duration);
                  distanceController = TextEditingController(text: snapshot.data!.distance == 0 ? null :snapshot.data!.distance.toString());
                  caloriesController = TextEditingController(text: snapshot.data!.calories == 0 ? null : snapshot.data!.calories.toString());
                  heartRateController = TextEditingController(text: snapshot.data!.heartRate == 0 ? null : snapshot.data!.heartRate.toString());

                  for(var set in snapshot.data!.sets){
                    repControllers.add(TextEditingController(text: set.reps.toString()));
                    weightControllers.add(TextEditingController(text: set.weight.toString()));
                  }

                  log("reps ${repControllers.length}");
                  log("weights ${weightControllers.length}");
                  // if(repControllers.length == 0){
                  //   setState((){
                  //     repControllers.add(TextEditingController(text: null));
                  //     weightControllers.add(TextEditingController(text: null));
                  //   });
                  //
                  // }
                  //setController = TextEditingController(text: snapshot.data!.sets == 0 ? null : snapshot.data!.sets.toString());
                  //repController = TextEditingController(text: snapshot.data!.reps == 0 ? null : snapshot.data!.reps.toString());


                  if(history != null){
                    myDateTime = DateTime.parse(snapshot.data!.date);
                    dateController = TextEditingController(
                        text: DateFormat('yyyy/MM/dd').format(myDateTime));
                    timeController = TextEditingController(
                        text: DateFormat('hh:mm a').format(myDateTime));
                  } else {
                    myDateTime = DateTime.now();
                    dateController = TextEditingController(
                        text: DateFormat('yyyy/MM/dd').format(myDateTime));
                    timeController = TextEditingController(
                        text: DateFormat('hh:mm a').format(myDateTime));
                  }

                  hasDefault = false;
                }

              }
              return Card(
                margin: const EdgeInsets.all(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKeys[index],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            workout.name,
                            textAlign: TextAlign.center,
                          ),
                          const Divider(),
                          if (cardsCompleted[index])
                            const Text("Completed")
                          else
                            const SizedBox.shrink(),
                          Visibility(
                            visible: (workout.type == WorkoutType.strength.index ||
                                workout.type == WorkoutType.both.index) &&
                                !cardsCompleted[index],
                            child: Card(
                              margin: const EdgeInsets.only(top: 16.0),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: repControllers.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          log("reps ${repControllers.length}");
                                          log("weights ${weightControllers.length}");
                                          return  SizedBox(
                                                width: 150,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: TextFormField(
                                                        controller: weightControllers[index],
                                                        validator: (value) {
                                                          bool hasValue = false;
                                                          for(int i = 0; i < repControllers.length; i++){
                                                            if(repControllers[i].text.isNotEmpty || weightControllers[i].text.isNotEmpty){
                                                              hasValue = true;
                                                            }
                                                          }
                                                          if(!hasValue){
                                                            return "Fill out a value";
                                                          }
                                                          return null;
                                                        },
                                                        decoration: const InputDecoration(
                                                            hintText: "LBS", labelText: "Weight"),
                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.allow(
                                                              RegExp(r'[0-9.]')),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 100,
                                                      child: TextFormField(
                                                        controller: repControllers[index],
                                                        validator: (value) {
                                                          bool hasValue = false;
                                                          for(int i = 0; i < repControllers.length; i++){
                                                              if(repControllers[i].text.isNotEmpty || weightControllers[i].text.isNotEmpty){
                                                                hasValue = true;
                                                              }
                                                          }
                                                          if(!hasValue){
                                                            return "Fill out a value";
                                                          }
                                                          return null;
                                                        },
                                                        decoration: const InputDecoration(
                                                            hintText: "Reps", labelText: "Reps"),
                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.allow(
                                                              RegExp(r'[0-9]')),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                        }
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              setState((){
                                                repControllers.removeLast();
                                                weightControllers.removeLast();
                                              });
                                            },
                                            icon: const Icon(UniconsLine.minus_circle)
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              setState((){
                                                repControllers.add(TextEditingController(text: repControllers.isNotEmpty
                                                    ? repControllers.last.text : null));
                                                weightControllers.add(TextEditingController(text: weightControllers.isNotEmpty
                                                    ? weightControllers.last.text : null));
                                              });
                                            },
                                            icon: const Icon(UniconsLine.plus_circle)
                                        )
                                      ]
                                    )
                                  ],
                                ),
                              ),
                            )
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Container(
                            //       width: 50,
                            //       child: TextFormField(
                            //         controller: setController,
                            //         validator: (value) {
                            //           if(value != null){
                            //             if(value.isNotEmpty){
                            //               return null;
                            //             }
                            //           }
                            //
                            //           if(workout.type == WorkoutType.both.index){
                            //             if(timerController.text == "0:00:00" &&
                            //                 weightController.text.isEmpty &&
                            //                 repController.text.isEmpty &&
                            //                 distanceController.text.isEmpty &&
                            //                 caloriesController.text.isEmpty &&
                            //                 heartRateController.text.isEmpty){
                            //               return "Must Fill Out a Field";
                            //             }
                            //
                            //           } else if(workout.type == WorkoutType.strength.index){
                            //             if(weightController.text.isEmpty &&
                            //                 repController.text.isEmpty){
                            //               return "Must Fill Out a Field";
                            //             }
                            //
                            //           }
                            //           return null;
                            //         },
                            //         decoration: const InputDecoration(
                            //             hintText: "Sets", labelText: "Sets"),
                            //         keyboardType: TextInputType.number,
                            //         inputFormatters: <TextInputFormatter>[
                            //           FilteringTextInputFormatter.allow(
                            //               RegExp(r'[0-9]')),
                            //         ],
                            //       ),
                            //     ),
                            //     SizedBox(
                            //       width: 50,
                            //       child: TextFormField(
                            //         controller: repController,
                            //         validator: (value) {
                            //           if(value != null){
                            //             if(value.isNotEmpty){
                            //               return null;
                            //             }
                            //           }
                            //
                            //           if(workout.type == WorkoutType.both.index){
                            //             if(timerController.text == "0:00:00" &&
                            //                 weightController.text.isEmpty &&
                            //                 setController.text.isEmpty &&
                            //                 distanceController.text.isEmpty &&
                            //                 caloriesController.text.isEmpty &&
                            //                 heartRateController.text.isEmpty){
                            //               return "Must Fill Out a Field";
                            //             }
                            //
                            //           } else if(workout.type == WorkoutType.strength.index){
                            //             if(weightController.text.isEmpty &&
                            //                 setController.text.isEmpty){
                            //               return "Must Fill Out a Field";
                            //             }
                            //
                            //           }
                            //           return null;
                            //         },
                            //         decoration: const InputDecoration(
                            //             hintText: "Reps", labelText: "Reps"),
                            //         keyboardType: TextInputType.number,
                            //         inputFormatters: <TextInputFormatter>[
                            //           FilteringTextInputFormatter.allow(
                            //               RegExp(r'[0-9]')),
                            //         ],
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ),
                          Visibility(
                            visible: (workout.type == WorkoutType.cardio.index ||
                                workout.type == WorkoutType.both.index) &&
                                !cardsCompleted[index],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    controller: timerController,
                                    validator: (value) {
                                      if(value != null){
                                        if(value.isNotEmpty && value != Utils().printDuration(const Duration())){
                                          return null;
                                        }
                                      }
                                      if(workout.type == WorkoutType.both.index){
                                        if(timerController.text == Utils().printDuration(const Duration()) &&
                                            (repControllers.isEmpty && weightControllers.isEmpty) &&
                                            distanceController.text.isEmpty &&
                                            caloriesController.text.isEmpty &&
                                            heartRateController.text.isEmpty){
                                          return "Must Fill Out a Field";
                                        }

                                      } else if(workout.type == WorkoutType.cardio.index){
                                        if(distanceController.text.isEmpty &&
                                            caloriesController.text.isEmpty &&
                                            heartRateController.text.isEmpty){
                                          return "Must Fill Out a Field";
                                        }

                                      }
                                      return null;
                                    },
                                    onTap: () async{
                                      log("current timer${timerController.text}");
                                      Duration? curTimer = Utils().parseDuration(timerController.text); //double.tryParse(timerController.text);

                                      Duration? duration;
                                      if(curTimer != null){
                                        // duration = await showDurationPicker(context: context,
                                        //     initialDuration: Duration(microseconds: curTimer.toInt()),
                                        //     durationPickerMode: DurationPickerMode.Hour
                                        //);
                                        log("current timer${timerController.text}");
                                        duration = await Utils().selectDuration(context, curTimer);
                                      } else {
                                        // duration = await showDurationPicker(context: context,
                                        //     initialDuration: const Duration(microseconds: 0),
                                        //     durationPickerMode: DurationPickerMode.Hour
                                        //);
                                        log("current timer is null");
                                        duration = await Utils().selectDuration(context,const Duration(microseconds: 0));
                                      }
                                      log("saved duration ${duration.inSeconds.toString()}");

                                      setState(() {
                                        timerController.text = Utils().printDuration(duration!); //duration.toString().substring(0, duration.toString().indexOf('.') + 3);
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      timerController.text = Utils().printDuration(stopWatchDuration);//stopWatchDuration.toString().substring(0, stopWatchDuration.toString().indexOf('.') + 3);
                                    },
                                    icon: Icon(UniconsLine.stopwatch),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                            visible: (workout.type == WorkoutType.cardio.index ||
                                workout.type == WorkoutType.both.index) &&
                                !cardsCompleted[index],
                            child: TextFormField(
                              controller: distanceController,
                              validator: (value) {
                                if(value != null){
                                  if(value.isNotEmpty){
                                    return null;
                                  }
                                }

                                if(workout.type == WorkoutType.both.index){
                                  if(timerController.text == Utils().printDuration(const Duration()) &&
                                      (repControllers.isEmpty && weightControllers.isEmpty) &&
                                      caloriesController.text.isEmpty &&
                                      heartRateController.text.isEmpty){
                                    return "Must Fill Out a Field";
                                  }

                                } else if(workout.type == WorkoutType.cardio.index){
                                  if(timerController.text == Utils().printDuration(const Duration()) &&
                                      caloriesController.text.isEmpty &&
                                      heartRateController.text.isEmpty){
                                    return "Must Fill Out a Field";
                                  }

                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  hintText: "Miles", labelText: "Distance"),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: (workout.type == WorkoutType.cardio.index ||
                                workout.type == WorkoutType.both.index) &&
                                !cardsCompleted[index],
                            child: TextFormField(
                              controller: caloriesController,
                              validator: (value) {
                                if(value != null){
                                  if(value.isNotEmpty){
                                    return null;
                                  }
                                }

                                if(workout.type == WorkoutType.both.index){
                                  if(timerController.text == Utils().printDuration(const Duration()) &&
                                      (repControllers.isEmpty && weightControllers.isEmpty) &&
                                      distanceController.text.isEmpty &&
                                      heartRateController.text.isEmpty){
                                    return "Must Fill Out a Field";
                                  }

                                } else if(workout.type == WorkoutType.cardio.index){
                                  if(distanceController.text.isEmpty &&
                                      timerController.text == Utils().printDuration(const Duration()) &&
                                      heartRateController.text.isEmpty){
                                    return "Must Fill Out a Field";
                                  }

                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  hintText: "Calories", labelText: "Calories"),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: (workout.type == WorkoutType.cardio.index ||
                                workout.type == WorkoutType.both.index) &&
                                !cardsCompleted[index],
                            child: TextFormField(
                              controller: heartRateController,
                              validator: (value) {
                                if(value != null){
                                  if(value.isNotEmpty){
                                    return null;
                                  }
                                }

                                if(workout.type == WorkoutType.both.index){
                                  if(timerController.text == Utils().printDuration(const Duration()) &&
                                      (repControllers.isEmpty && weightControllers.isEmpty) &&
                                      distanceController.text.isEmpty &&
                                      caloriesController.text.isEmpty){
                                    return "Must Fill Out a Field";
                                  }

                                } else if(workout.type == WorkoutType.cardio.index){
                                  if(distanceController.text.isEmpty &&
                                      caloriesController.text.isEmpty &&
                                      timerController.text == Utils().printDuration(const Duration())){
                                    return "Must Fill Out a Field";
                                  }

                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  hintText: "BPM", labelText: "Heart Rate"),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: !cardsCompleted[index],
                            child: TextField(
                              controller: dateController,
                              readOnly: true,
                              onTap: () async {
                                DateTime now = DateTime.now();
                                var dateTemp = (await showDatePicker(
                                  context: context,
                                  initialDate: myDateTime,
                                  firstDate: DateTime(now.year - 5, now.month, now.day),
                                  lastDate: DateTime(now.year, now.month, now.day),
                                ));
                                if(dateTemp != null){
                                  myDateTime = DateTime(dateTemp.year, dateTemp.month, dateTemp.day, myDateTime.hour, myDateTime.minute);
                                  dateController.text =
                                      DateFormat('yyyy/MM/dd').format(myDateTime);
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                          Visibility(
                            visible: !cardsCompleted[index],
                            child: TextField(
                              controller: timeController,
                              readOnly: true,
                              onTap: () async {
                                var timeTemp = (await showTimePicker(
                                    context: context,
                                    initialTime:TimeOfDay.fromDateTime(myDateTime)
                                ));
                                if(timeTemp != null){
                                  myDateTime = DateTime(myDateTime.year, myDateTime.month, myDateTime.day, timeTemp.hour, timeTemp.minute);
                                  timeController.text =
                                      DateFormat('hh:mm a').format(myDateTime);
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                          Visibility(
                            visible: !cardsCompleted[index],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    if (formKeys[index].currentState!.validate()) {
                                      WorkoutHistory tempWorkoutHistory = WorkoutHistory();
                                      tempWorkoutHistory.workoutName = workout.name;
                                      tempWorkoutHistory.workoutType = workout.type;
                                      tempWorkoutHistory.workoutId = workout.id;
                                      tempWorkoutHistory.date = myDateTime.toString();
                                      // tempWorkoutHistory.sets = int.parse(setController.text.isEmpty
                                      //     ? "0"
                                      //     : setController.text);
                                      // tempWorkoutHistory.reps = int.parse(repController.text.isEmpty
                                      //     ? "0"
                                      //     : repController.text);

                                      // tempWorkoutHistory.weight = double.parse(weightController.text.isEmpty
                                      //     ? "0"
                                      //     : weightController.text);
                                      tempWorkoutHistory.duration = timerController.text;
                                      tempWorkoutHistory.distance = double.parse(distanceController.text.isEmpty
                                          ? "0"
                                          : distanceController.text);
                                      tempWorkoutHistory.calories = double.parse(caloriesController.text.isEmpty
                                          ? "0"
                                          : caloriesController.text);
                                      tempWorkoutHistory.heartRate = double.parse(heartRateController.text.isEmpty
                                          ? "0"
                                          : heartRateController.text);
                                      WorkoutHistory newHistory;
                                      if(history != null){
                                        tempWorkoutHistory.id = history!.id;
                                        await repo.updateWorkoutHistory(tempWorkoutHistory);
                                        newHistory = history!;
                                        //List<WorkoutSet>? tempSets = await repo.readAllSets(history!.id);
                                        //if(tempSets != null){
                                          for(var set in history!.sets){
                                            log("delete set id");
                                            log(set.id.toString());
                                            await repo.deleteSet(set.id);
                                          }
                                       // }
                                      } else {
                                        newHistory = await repo.saveWorkoutHistory(tempWorkoutHistory);
                                      }

                                      for(int i = 0; i < repControllers.length; i++){
                                        if(repControllers[i].text.isNotEmpty || weightControllers[i].text.isNotEmpty){
                                          WorkoutSet temp = WorkoutSet();
                                          temp.reps = int.parse(repControllers[i].text.isEmpty ? "0" : repControllers[i].text);
                                          temp.weight = double.parse(weightControllers[i].text.isEmpty
                                              ? "0"
                                              : weightControllers[i].text);
                                          temp.set = i;
                                          temp.workoutHistoryId = newHistory.id;
                                          repo.saveSet(temp);
                                        }
                                      }

                                      if(routine != null){
                                        var newRoutine = routine!;
                                        newRoutine.date = DateTime.now().toString();
                                        repo.updateRoutine(newRoutine);
                                      }

                                      setState(() {
                                        cardsCompleted[index] = true;
                                        if(cardsCompleted.every((element) => element == true)){
                                          Navigator.of(context).pop();
                                        }
                                        //workouts = repo.readAllWorkoutsByRoutine(routine.id);
                                      });
                                    }
                                  },
                                  child: const Text("Save"),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ));

            },
          );
        });
  }
}

