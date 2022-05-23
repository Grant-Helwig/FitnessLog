import 'package:hey_workout/repository/workout_repository.dart';
import 'package:hey_workout/ui/workout_history_page.dart';
import 'package:unicons/unicons.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import '../model/workout.dart';
import '../model/workout_history.dart';
import '../utils/utils.dart';

class WorkoutProfile extends StatefulWidget {
  final Workout workout;
  const WorkoutProfile({Key? key, required this.workout}) : super(key: key);

  @override
  State<WorkoutProfile> createState() =>
      _WorkoutProfileState(workout: this.workout);
}

class _WorkoutProfileState extends State<WorkoutProfile> {
  late Workout workout;
  final WorkoutRepository repo = WorkoutRepository();
  _WorkoutProfileState({required this.workout});

  Future<void> exitWorkoutAlert() {
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

  Widget executeWorkoutCard() {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bool cardCompleted = false;
    TextEditingController weightController = TextEditingController();
    TextEditingController timerController = TextEditingController(text: Duration().toString().substring(0, Duration().toString().indexOf('.')));
    TextEditingController setController = TextEditingController();
    TextEditingController repController = TextEditingController();
    TextEditingController distanceController = TextEditingController();
    TextEditingController caloriesController = TextEditingController();
    TextEditingController heartRateController = TextEditingController();

    bool setDefault = true;
    //use similar logic to workout history page to validate the card and display the fields
    Future<WorkoutHistory?> recentHistory =
    repo.mostRecentWorkoutHistoryByWorkout(workout.id);
    return WillPopScope(
      onWillPop: () async {
        if(cardCompleted){
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
            workout.name,
            textAlign: TextAlign.center,
          ),
        ),
        body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return FutureBuilder<WorkoutHistory?>(
                future: recentHistory,
                builder: (context, snapshot) {
                  if (snapshot.hasData && setDefault) {
                    log("reset default ${timerController.text}");
                    weightController = TextEditingController(
                        text: snapshot.data!.weight == 0 ? null : snapshot.data!
                            .weight.toString());
                    timerController = TextEditingController(
                        text: snapshot.data!.duration == Duration().toString()
                            ? null
                            : snapshot.data!.duration);
                    distanceController = TextEditingController(
                        text: snapshot.data!.distance == 0 ? null : snapshot
                            .data!.distance.toString());
                    caloriesController = TextEditingController(
                        text: snapshot.data!.calories == 0 ? null : snapshot
                            .data!.calories.toString());
                    heartRateController = TextEditingController(
                        text: snapshot.data!.heartRate == 0 ? null : snapshot
                            .data!.heartRate.toString());
                    setController = TextEditingController(
                        text: snapshot.data!.sets == 0 ? null : snapshot.data!
                            .sets.toString());
                    repController = TextEditingController(
                        text: snapshot.data!.reps == 0 ? null : snapshot.data!
                            .reps.toString());
                    setDefault = false;
                  }
                  // } else if(setDefault) {
                  //   weightController.text = "";
                  //   timerController.text = Duration().toString();
                  //   setController.text = "";
                  //   repController.text = "";
                  //   distanceController.text = "";
                  //   caloriesController.text = "";
                  //   heartRateController.text = "";
                  //   setDefault = false;
                  // }
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Card(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                if (cardCompleted)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: const [
                                      Text("Completed",
                                          textAlign: TextAlign.center),
                                    ],
                                  )
                                else
                                  const SizedBox.shrink(),
                                Visibility(
                                  visible: (workout.type == WorkoutType.strength.index ||
                                      workout.type == WorkoutType.both.index) &&
                                      !cardCompleted,
                                  child: TextFormField(
                                    controller: weightController,
                                    validator: (value) {
                                      if(value != null){
                                        if(value.isNotEmpty){
                                          return null;
                                        }
                                      }
                                      if(workout.type == WorkoutType.both.index){
                                        if(timerController.text == "0:00:00" &&
                                            setController.text.isEmpty &&
                                            repController.text.isEmpty &&
                                            distanceController.text.isEmpty &&
                                            caloriesController.text.isEmpty &&
                                            heartRateController.text.isEmpty){
                                          return "Must Fill Out a Field";
                                        }

                                      } else if(workout.type == WorkoutType.strength.index){
                                        if(setController.text.isEmpty &&
                                            repController.text.isEmpty){
                                          return "Must Fill Out a Field";
                                        }

                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                        hintText: "LBS", labelText: "Weight"),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: (workout.type == WorkoutType.strength.index ||
                                      workout.type == WorkoutType.both.index) &&
                                      !cardCompleted,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 50,
                                        child: TextFormField(
                                          controller: setController,
                                          validator: (value) {
                                            if(value != null){
                                              if(value.isNotEmpty){
                                                return null;
                                              }
                                            }

                                            if(workout.type == WorkoutType.both.index){
                                              if(timerController.text == "0:00:00" &&
                                                  weightController.text.isEmpty &&
                                                  repController.text.isEmpty &&
                                                  distanceController.text.isEmpty &&
                                                  caloriesController.text.isEmpty &&
                                                  heartRateController.text.isEmpty){
                                                return "Must Fill Out a Field";
                                              }

                                            } else if(workout.type == WorkoutType.strength.index){
                                              if(weightController.text.isEmpty &&
                                                  repController.text.isEmpty){
                                                return "Must Fill Out a Field";
                                              }

                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                              hintText: "Sets", labelText: "Sets"),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 50,
                                        child: TextFormField(
                                          controller: repController,
                                          validator: (value) {
                                            if(value != null){
                                              if(value.isNotEmpty){
                                                return null;
                                              }
                                            }

                                            if(workout.type == WorkoutType.both.index){
                                              if(timerController.text == "0:00:00" &&
                                                  weightController.text.isEmpty &&
                                                  setController.text.isEmpty &&
                                                  distanceController.text.isEmpty &&
                                                  caloriesController.text.isEmpty &&
                                                  heartRateController.text.isEmpty){
                                                return "Must Fill Out a Field";
                                              }

                                            } else if(workout.type == WorkoutType.strength.index){
                                              if(weightController.text.isEmpty &&
                                                  setController.text.isEmpty){
                                                return "Must Fill Out a Field";
                                              }

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
                                ),
                                Visibility(
                                  visible: (workout.type == WorkoutType.cardio.index ||
                                      workout.type == WorkoutType.both.index) &&
                                      !cardCompleted,
                                  child: TextFormField(
                                    controller: timerController,
                                    validator: (value) {
                                      if(value != null){
                                        if(value.isNotEmpty && value != "0:00:00"){
                                          return null;
                                        }
                                      }
                                      if(workout.type == WorkoutType.both.index){
                                        if(weightController.text.isEmpty &&
                                            setController.text.isEmpty &&
                                            repController.text.isEmpty &&
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
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        hintText: "Duration", labelText: "Duration"),
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
                                        timerController.text = duration.toString().substring(0, duration.toString().indexOf('.'));
                                      });
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible: (workout.type == WorkoutType.cardio.index ||
                                      workout.type == WorkoutType.both.index) &&
                                      !cardCompleted,
                                  child: TextFormField(
                                    controller: distanceController,
                                    validator: (value) {
                                      if(value != null){
                                        if(value.isNotEmpty){
                                          return null;
                                        }
                                      }

                                      if(workout.type == WorkoutType.both.index){
                                        if(timerController.text == "0:00:00" &&
                                            weightController.text.isEmpty &&
                                            setController.text.isEmpty &&
                                            repController.text.isEmpty &&
                                            caloriesController.text.isEmpty &&
                                            heartRateController.text.isEmpty){
                                          return "Must Fill Out a Field";
                                        }

                                      } else if(workout.type == WorkoutType.cardio.index){
                                        if(timerController.text == "0:00:00" &&
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
                                      !cardCompleted,
                                  child: TextFormField(
                                    controller: caloriesController,
                                    validator: (value) {
                                      if(value != null){
                                        if(value.isNotEmpty){
                                          return null;
                                        }
                                      }

                                      if(workout.type == WorkoutType.both.index){
                                        if(timerController.text == "0:00:00" &&
                                            weightController.text.isEmpty &&
                                            setController.text.isEmpty &&
                                            repController.text.isEmpty &&
                                            distanceController.text.isEmpty &&
                                            heartRateController.text.isEmpty){
                                          return "Must Fill Out a Field";
                                        }

                                      } else if(workout.type == WorkoutType.cardio.index){
                                        if(distanceController.text.isEmpty &&
                                            timerController.text == "0:00:00" &&
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
                                      !cardCompleted,
                                  child: TextFormField(
                                    controller: heartRateController,
                                    validator: (value) {
                                      if(value != null){
                                        if(value.isNotEmpty){
                                          return null;
                                        }
                                      }

                                      if(workout.type == WorkoutType.both.index){
                                        if(timerController.text == "0:00:00" &&
                                            weightController.text.isEmpty &&
                                            setController.text.isEmpty &&
                                            repController.text.isEmpty &&
                                            distanceController.text.isEmpty &&
                                            caloriesController.text.isEmpty){
                                          return "Must Fill Out a Field";
                                        }

                                      } else if(workout.type == WorkoutType.cardio.index){
                                        if(distanceController.text.isEmpty &&
                                            caloriesController.text.isEmpty &&
                                            timerController.text == "0:00:00"){
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
                                  visible: !cardCompleted,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          if (_formKey.currentState!.validate()) {
                                            WorkoutHistory history = WorkoutHistory();
                                            history.workoutName =workout.name;
                                            history.workoutType = workout.type;
                                            history.date = DateTime.now().toString();
                                            history.sets =int.parse(setController.text.isEmpty
                                            ? "0"
                                                : setController.text);
                                            history.reps = int.parse(repController.text.isEmpty
                                            ? "0"
                                                : repController.text);
                                            history.weight = double.parse(weightController.text.isEmpty
                                            ? "0"
                                                : weightController.text);
                                            history.duration = timerController.text;
                                            history.distance = double.parse(distanceController.text.isEmpty
                                            ? "0"
                                                : distanceController.text);
                                            history.calories = double.parse(caloriesController.text.isEmpty
                                            ? "0"
                                                : caloriesController.text);
                                            history.heartRate =double.parse(heartRateController.text.isEmpty
                                            ? "0"
                                                : heartRateController.text);
                                            history.workoutId = workout.id;
                                            repo.saveWorkoutHistory(history);


                                            setState(() {
                                              cardCompleted= true;
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
                        )),
                  );
                },
              );
            }),
      ),
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
                          builder: (context) => executeWorkoutCard()));
                  setState(() {

                  });
                },
                icon: const Icon(UniconsLine.play))
          ],
          centerTitle: true,
          title: Text(
            workout.name,
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
            WorkoutHistoryPage(workout: workout),
            WorkoutHistoryPage(workout: workout),
            //WorkoutGraphs(workout: workout)
          ],
        ),
      ),
    );
  }
}