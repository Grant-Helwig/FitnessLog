import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hey_workout/repository/workout_repository.dart';

import '../model/routine.dart';
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
  _ExecuteWorkoutState({required this.workouts, this.routine, this.history});

  @override
  Widget build(BuildContext context) {
    return executeWorkout(context);
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
      ),
    );
  }

  Widget executeWorkoutCard(Workout workout, int index) {
    TextEditingController weightController = TextEditingController();
    TextEditingController timerController = TextEditingController(text: Duration().toString().substring(0, Duration().toString().indexOf('.')));
    TextEditingController setController = TextEditingController();
    TextEditingController repController = TextEditingController();
    TextEditingController distanceController = TextEditingController();
    TextEditingController caloriesController = TextEditingController();
    TextEditingController heartRateController = TextEditingController();
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
              if (snapshot.hasData && hasDefault) {
                weightController = TextEditingController(text: snapshot.data!.weight == 0 ? null : snapshot.data!.weight.toString());
                timerController = TextEditingController(
                    text: snapshot.data!.duration == Duration().toString()
                        ? null
                        : snapshot.data!.duration);
                distanceController = TextEditingController(text: snapshot.data!.distance == 0 ? null :snapshot.data!.distance.toString());
                caloriesController = TextEditingController(text: snapshot.data!.calories == 0 ? null : snapshot.data!.calories.toString());
                heartRateController = TextEditingController(text: snapshot.data!.heartRate == 0 ? null : snapshot.data!.heartRate.toString());
                setController = TextEditingController(text: snapshot.data!.sets == 0 ? null : snapshot.data!.sets.toString());
                repController = TextEditingController(text: snapshot.data!.reps == 0 ? null : snapshot.data!.reps.toString());
                hasDefault = false;
              }
              return Card(
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
                                !cardsCompleted[index],
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
                                !cardsCompleted[index],
                            child: TextFormField(
                              controller: timerController,
                              validator: (value) {
                                if(value != null){
                                  if(value.isNotEmpty && value != "0:00:00"){
                                    return null;
                                  }
                                }
                                if(workout.type == WorkoutType.both.index){
                                  if(timerController.text == "0:00:00" &&
                                      weightController.text.isEmpty &&
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
                                  if(timerController.text == "0:00:00"&&
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
                            visible: !cardsCompleted[index],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    if (formKeys[index].currentState!.validate()) {
                                      WorkoutHistory tempWorkoutHistory = WorkoutHistory();
                                      tempWorkoutHistory.workoutName = workout.name;
                                      tempWorkoutHistory.workoutType = workout.type;
                                      tempWorkoutHistory.workoutId = workout.id;
                                      tempWorkoutHistory.date = DateTime.now().toString();
                                      tempWorkoutHistory.sets = int.parse(setController.text.isEmpty
                                          ? "0"
                                          : setController.text);
                                      tempWorkoutHistory.reps = int.parse(repController.text.isEmpty
                                          ? "0"
                                          : repController.text);
                                      tempWorkoutHistory.weight = double.parse(weightController.text.isEmpty
                                          ? "0"
                                          : weightController.text);
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
                                      if(history != null){
                                        repo.updateWorkoutHistory(tempWorkoutHistory);
                                      } else {
                                        repo.saveWorkoutHistory(tempWorkoutHistory);
                                      }

                                      if(routine != null){
                                        var newRoutine = routine!;
                                        newRoutine.date = DateTime.now().toString();
                                        repo.updateRoutine(newRoutine);
                                      }

                                      setState(() {
                                        cardsCompleted[index] = true;
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
