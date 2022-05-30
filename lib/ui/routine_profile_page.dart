

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hey_workout/repository/workout_repository.dart';
import 'package:hey_workout/ui/execute_workout_page.dart';
import 'package:unicons/unicons.dart';

import '../model/routine.dart';
import '../model/routine_entry.dart';
import '../model/workout.dart';
import '../model/workout_history.dart';
import '../utils/utils.dart';

class RoutineProfile extends StatefulWidget {
  final Routine routine;
  const RoutineProfile({Key? key, required this.routine}) : super(key: key);

  @override
  State<RoutineProfile> createState() =>
      _RoutineProfileState(routine: this.routine);
}

class _RoutineProfileState extends State<RoutineProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Routine routine;
  _RoutineProfileState({required this.routine});

  WorkoutRepository repo = WorkoutRepository();

  //need multiple forms to validate each workout separately
  List<GlobalKey<FormState>> formKeys = [];

  //used to hide the fields when each card is done
  List<bool> cardsCompleted = [];

  late Future<List<Workout>?> workouts;

  Widget orderedWorkoutList() {
    Future<List<RoutineEntry>?> routineEntries =
      repo.routineEntryByRoutine(routine.id);
    return Scaffold(
      body: FutureBuilder<List<RoutineEntry>?>(
          future: routineEntries,
          builder: (context, AsyncSnapshot<List<RoutineEntry>?> snapshot) {
            if (snapshot.hasData) {
              return ReorderableListView(
                children: <Widget>[
                  for (int index = 0; index < snapshot.data!.length; index += 1)
                  //swipe to delete routine entries
                    Dismissible(
                      key: UniqueKey(),
                      background: Container(color: Colors.redAccent),
                      onDismissed: (direction) {
                        setState(() {
                          final RoutineEntry item =
                          snapshot.data!.removeAt(index);
                          repo.deleteRoutineEntry(item.id);
                          for (var element in snapshot.data!) {
                            element.order = snapshot.data!.indexOf(element);
                            repo.updateRoutineEntry(element);
                          }
                          routineEntries = repo.routineEntryByRoutine(routine.id);
                        });
                      },
                      child: Card(
                        child: ListTile(
                          trailing: const Icon(UniconsLine.draggabledots),
                          tileColor: Colors.black12,
                          title: Text('${snapshot.data![index].workoutName}'),
                        ),
                      ),
                    ),
                ],

                //on reordering the list, save the index valiues and update the list view
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final RoutineEntry item = snapshot.data!.removeAt(oldIndex);
                    snapshot.data!.insert(newIndex, item);

                    for (var element in snapshot.data!) {
                      element.order = snapshot.data!.indexOf(element);
                        repo.updateRoutineEntry(element);
                    }
                  });
                },
              );
            } else {
              return const Align(
                alignment: Alignment.center,
                child: Text(
                  'No Workouts for this Routine',
                  textAlign: TextAlign.center,
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addWorkoutEntryForm(context);
        },
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }

  Future<void> noWorkoutsAlert() {
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
                Text('Please add workouts before building Routines.'),
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

  Future<void> addWorkoutEntryForm(BuildContext context) async {
    List<Workout>? workouts = await repo.readAllWorkouts();
    if (workouts == null) {
      return noWorkoutsAlert();
    }

    Workout workout = workouts[0];

    return await showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: AlertDialog(
            scrollable: true,
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<Workout>(
                          isExpanded: true,
                          value: workout,
                          icon: const Icon(UniconsLine.angle_down),
                          elevation: 16,
                          style: const TextStyle(color: Colors.white),
                          underline: Container(
                            height: 2,
                            color: Colors.white,
                          ),
                          onChanged: (Workout? newValue) async {
                            setState(() {
                              workout = newValue!;
                            });
                          },
                          items: workouts
                              .map<DropdownMenuItem<Workout>>((Workout value) {
                            return DropdownMenuItem<Workout>(
                              value: value,
                              child: Text(value.name),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  //when saving, need to set the order field correctly
                  if (_formKey.currentState!.validate()) {
                    var entries = await repo.routineEntryByRoutine(routine.id);
                    RoutineEntry entry = RoutineEntry();
                    entry.workoutType = workout.type;
                    entry.workoutName = workout.name;
                    entry.workoutId = workout.id;
                    entry.routineId = routine.id;
                    if (entries == null) {
                      entry.order = 0;
                      repo.saveRoutineEntry(entry);
                    } else {
                      entry.order = entries.length;
                      repo.saveRoutineEntry(entry);
                    }
                    setState(() {});
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Save"),
              )
            ],
          ),
        );
      },
    );
  }

  // Widget executeWorkoutEntries(BuildContext context) {
  //   workouts = repo.readAllWorkoutsByRoutine(routine.id);
  //   formKeys = [];
  //   cardsCompleted = [];
  //
  //   //get the workouts from the entries in order, then construct a list of execute workout cards
  //   return WillPopScope(
  //     onWillPop: () async {
  //       if(cardsCompleted.every((element) => element == true)){
  //         return true;
  //       }
  //       bool willLeave = false;
  //       // show the confirm dialog
  //       await showDialog(
  //           context: context,
  //           builder: (_) => AlertDialog(
  //             title: const Text('Quit Workout'),
  //             content: SingleChildScrollView(
  //               child: ListBody(
  //                 children: const <Widget>[
  //                   Text('You have not saved your workout.'),
  //                   Text('Are you sure you want to exit?'),
  //                   Text('All unsaved progress will be lost.'),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                   onPressed: () {
  //                     willLeave = true;
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: const Text('Yes')),
  //               TextButton(
  //                   onPressed: () => Navigator.of(context).pop(),
  //                   child: const Text('No'))
  //             ],
  //           ));
  //       return willLeave;
  //     },
  //     child: Scaffold(
  //       appBar: AppBar(
  //         centerTitle: true,
  //         title: Text(
  //           routine.name,
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //       body: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           Expanded(
  //             child: FutureBuilder<List<Workout>?>(
  //               future: workouts,
  //               builder: (context, projectSnap) {
  //                 if (projectSnap.hasData) {
  //                   for (int i = 0; i < projectSnap.data!.length; i++) {
  //                     formKeys.add(GlobalKey<FormState>());
  //                     cardsCompleted.add(false);
  //                   }
  //                   return ListView.builder(
  //                       padding: const EdgeInsets.only(bottom: 10, top: 10),
  //                       itemCount: projectSnap.data?.length,
  //                       itemBuilder: (BuildContext context, int index) =>
  //                           executeWorkoutCard(projectSnap.data![index], index));
  //                 } else {
  //                   return const Align(
  //                     alignment: Alignment.center,
  //                     child: Text(
  //                       'No Workouts for this Routine',
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   );
  //                 }
  //               },
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget executeWorkoutCard(Workout workout, int index) {
  //   TextEditingController weightController = TextEditingController();
  //   TextEditingController timerController = TextEditingController(text: Duration().toString().substring(0, Duration().toString().indexOf('.')));
  //   TextEditingController setController = TextEditingController();
  //   TextEditingController repController = TextEditingController();
  //   TextEditingController distanceController = TextEditingController();
  //   TextEditingController caloriesController = TextEditingController();
  //   TextEditingController heartRateController = TextEditingController();
  //   bool hasDefault = true;
  //   //use similar logic to workout history page to validate the card and display the fields
  //   Future<WorkoutHistory?> recentHistory =
  //     repo.mostRecentWorkoutHistoryByWorkout(workout.id);
  //   return StatefulBuilder(
  //       builder: (BuildContext context, StateSetter setState) {
  //         return FutureBuilder<WorkoutHistory?>(
  //           future: recentHistory,
  //           builder: (context, snapshot) {
  //             if (snapshot.hasData && hasDefault) {
  //               weightController = TextEditingController(text: snapshot.data!.weight == 0 ? null : snapshot.data!.weight.toString());
  //               timerController = TextEditingController(
  //                   text: snapshot.data!.duration == Duration().toString()
  //                       ? null
  //                       : snapshot.data!.duration);
  //               distanceController = TextEditingController(text: snapshot.data!.distance == 0 ? null :snapshot.data!.distance.toString());
  //               caloriesController = TextEditingController(text: snapshot.data!.calories == 0 ? null : snapshot.data!.calories.toString());
  //               heartRateController = TextEditingController(text: snapshot.data!.heartRate == 0 ? null : snapshot.data!.heartRate.toString());
  //               setController = TextEditingController(text: snapshot.data!.sets == 0 ? null : snapshot.data!.sets.toString());
  //               repController = TextEditingController(text: snapshot.data!.reps == 0 ? null : snapshot.data!.reps.toString());
  //               hasDefault = false;
  //             }
  //             return Card(
  //                 child: Container(
  //                   padding: const EdgeInsets.all(16),
  //                   child: Form(
  //                     key: formKeys[index],
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Text(
  //                           workout.name,
  //                           textAlign: TextAlign.center,
  //                         ),
  //                         const Divider(),
  //                         if (cardsCompleted[index])
  //                           const Text("Completed")
  //                         else
  //                           const SizedBox.shrink(),
  //                         Visibility(
  //                           visible: (workout.type == WorkoutType.strength.index ||
  //                               workout.type == WorkoutType.both.index) &&
  //                               !cardsCompleted[index],
  //                           child: TextFormField(
  //                             controller: weightController,
  //                             validator: (value) {
  //                               if(value != null){
  //                                 if(value.isNotEmpty){
  //                                   return null;
  //                                 }
  //                               }
  //                               if(workout.type == WorkoutType.both.index){
  //                                 if(timerController.text == "0:00:00" &&
  //                                     setController.text.isEmpty &&
  //                                     repController.text.isEmpty &&
  //                                     distanceController.text.isEmpty &&
  //                                     caloriesController.text.isEmpty &&
  //                                     heartRateController.text.isEmpty){
  //                                   return "Must Fill Out a Field";
  //                                 }
  //
  //                               } else if(workout.type == WorkoutType.strength.index){
  //                                 if(setController.text.isEmpty &&
  //                                     repController.text.isEmpty){
  //                                   return "Must Fill Out a Field";
  //                                 }
  //
  //                               }
  //                               return null;
  //                             },
  //                             decoration: const InputDecoration(
  //                                 hintText: "LBS", labelText: "Weight"),
  //                             keyboardType: TextInputType.number,
  //                             inputFormatters: <TextInputFormatter>[
  //                               FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  //                             ],
  //                           ),
  //                         ),
  //                         Visibility(
  //                           visible: (workout.type == WorkoutType.strength.index ||
  //                               workout.type == WorkoutType.both.index) &&
  //                               !cardsCompleted[index],
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Container(
  //                                 width: 50,
  //                                 child: TextFormField(
  //                                   controller: setController,
  //                                   validator: (value) {
  //                                     if(value != null){
  //                                       if(value.isNotEmpty){
  //                                         return null;
  //                                       }
  //                                     }
  //
  //                                     if(workout.type == WorkoutType.both.index){
  //                                       if(timerController.text == "0:00:00" &&
  //                                           weightController.text.isEmpty &&
  //                                           repController.text.isEmpty &&
  //                                           distanceController.text.isEmpty &&
  //                                           caloriesController.text.isEmpty &&
  //                                           heartRateController.text.isEmpty){
  //                                         return "Must Fill Out a Field";
  //                                       }
  //
  //                                     } else if(workout.type == WorkoutType.strength.index){
  //                                       if(weightController.text.isEmpty &&
  //                                           repController.text.isEmpty){
  //                                         return "Must Fill Out a Field";
  //                                       }
  //
  //                                     }
  //                                     return null;
  //                                   },
  //                                   decoration: const InputDecoration(
  //                                       hintText: "Sets", labelText: "Sets"),
  //                                   keyboardType: TextInputType.number,
  //                                   inputFormatters: <TextInputFormatter>[
  //                                     FilteringTextInputFormatter.allow(
  //                                         RegExp(r'[0-9]')),
  //                                   ],
  //                                 ),
  //                               ),
  //                               SizedBox(
  //                                 width: 50,
  //                                 child: TextFormField(
  //                                   controller: repController,
  //                                   validator: (value) {
  //                                     if(value != null){
  //                                       if(value.isNotEmpty){
  //                                         return null;
  //                                       }
  //                                     }
  //
  //                                     if(workout.type == WorkoutType.both.index){
  //                                       if(timerController.text == "0:00:00" &&
  //                                           weightController.text.isEmpty &&
  //                                           setController.text.isEmpty &&
  //                                           distanceController.text.isEmpty &&
  //                                           caloriesController.text.isEmpty &&
  //                                           heartRateController.text.isEmpty){
  //                                         return "Must Fill Out a Field";
  //                                       }
  //
  //                                     } else if(workout.type == WorkoutType.strength.index){
  //                                       if(weightController.text.isEmpty &&
  //                                           setController.text.isEmpty){
  //                                         return "Must Fill Out a Field";
  //                                       }
  //
  //                                     }
  //                                     return null;
  //                                   },
  //                                   decoration: const InputDecoration(
  //                                       hintText: "Reps", labelText: "Reps"),
  //                                   keyboardType: TextInputType.number,
  //                                   inputFormatters: <TextInputFormatter>[
  //                                     FilteringTextInputFormatter.allow(
  //                                         RegExp(r'[0-9]')),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         Visibility(
  //                           visible: (workout.type == WorkoutType.cardio.index ||
  //                               workout.type == WorkoutType.both.index) &&
  //                               !cardsCompleted[index],
  //                           child: TextFormField(
  //                             controller: timerController,
  //                             validator: (value) {
  //                               if(value != null){
  //                                 if(value.isNotEmpty && value != "0:00:00"){
  //                                   return null;
  //                                 }
  //                               }
  //                               if(workout.type == WorkoutType.both.index){
  //                                 if(timerController.text == "0:00:00" &&
  //                                     weightController.text.isEmpty &&
  //                                     setController.text.isEmpty &&
  //                                     repController.text.isEmpty &&
  //                                     distanceController.text.isEmpty &&
  //                                     caloriesController.text.isEmpty &&
  //                                     heartRateController.text.isEmpty){
  //                                   return "Must Fill Out a Field";
  //                                 }
  //
  //                               } else if(workout.type == WorkoutType.cardio.index){
  //                                 if(distanceController.text.isEmpty &&
  //                                     caloriesController.text.isEmpty &&
  //                                     heartRateController.text.isEmpty){
  //                                   return "Must Fill Out a Field";
  //                                 }
  //
  //                               }
  //                               return null;
  //                             },
  //                             onTap: () async{
  //                               log("current timer${timerController.text}");
  //                               Duration? curTimer = Utils().parseDuration(timerController.text); //double.tryParse(timerController.text);
  //
  //                               Duration? duration;
  //                               if(curTimer != null){
  //                                 // duration = await showDurationPicker(context: context,
  //                                 //     initialDuration: Duration(microseconds: curTimer.toInt()),
  //                                 //     durationPickerMode: DurationPickerMode.Hour
  //                                 //);
  //                                 log("current timer${timerController.text}");
  //                                 duration = await Utils().selectDuration(context, curTimer);
  //                               } else {
  //                                 // duration = await showDurationPicker(context: context,
  //                                 //     initialDuration: const Duration(microseconds: 0),
  //                                 //     durationPickerMode: DurationPickerMode.Hour
  //                                 //);
  //                                 log("current timer is null");
  //                                 duration = await Utils().selectDuration(context,const Duration(microseconds: 0));
  //                               }
  //                               log("saved duration ${duration.inSeconds.toString()}");
  //
  //                               setState(() {
  //                                 timerController.text = duration.toString().substring(0, duration.toString().indexOf('.'));
  //                               });
  //                             },
  //                           ),
  //                         ),
  //                         Visibility(
  //                           visible: (workout.type == WorkoutType.cardio.index ||
  //                               workout.type == WorkoutType.both.index) &&
  //                               !cardsCompleted[index],
  //                           child: TextFormField(
  //                             controller: distanceController,
  //                             validator: (value) {
  //                               if(value != null){
  //                                 if(value.isNotEmpty){
  //                                   return null;
  //                                 }
  //                               }
  //
  //                               if(workout.type == WorkoutType.both.index){
  //                                 if(timerController.text == "0:00:00" &&
  //                                     weightController.text.isEmpty &&
  //                                     setController.text.isEmpty &&
  //                                     repController.text.isEmpty &&
  //                                     caloriesController.text.isEmpty &&
  //                                     heartRateController.text.isEmpty){
  //                                   return "Must Fill Out a Field";
  //                                 }
  //
  //                               } else if(workout.type == WorkoutType.cardio.index){
  //                                 if(timerController.text == "0:00:00" &&
  //                                     caloriesController.text.isEmpty &&
  //                                     heartRateController.text.isEmpty){
  //                                   return "Must Fill Out a Field";
  //                                 }
  //
  //                               }
  //                               return null;
  //                             },
  //                             decoration: const InputDecoration(
  //                                 hintText: "Miles", labelText: "Distance"),
  //                             keyboardType: TextInputType.number,
  //                             inputFormatters: <TextInputFormatter>[
  //                               FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  //                             ],
  //                           ),
  //                         ),
  //                         Visibility(
  //                           visible: (workout.type == WorkoutType.cardio.index ||
  //                               workout.type == WorkoutType.both.index) &&
  //                               !cardsCompleted[index],
  //                           child: TextFormField(
  //                             controller: caloriesController,
  //                             validator: (value) {
  //                               if(value != null){
  //                                 if(value.isNotEmpty){
  //                                   return null;
  //                                 }
  //                               }
  //
  //                               if(workout.type == WorkoutType.both.index){
  //                                 if(timerController.text == "0:00:00" &&
  //                                     weightController.text.isEmpty &&
  //                                     setController.text.isEmpty &&
  //                                     repController.text.isEmpty &&
  //                                     distanceController.text.isEmpty &&
  //                                     heartRateController.text.isEmpty){
  //                                   return "Must Fill Out a Field";
  //                                 }
  //
  //                               } else if(workout.type == WorkoutType.cardio.index){
  //                                 if(distanceController.text.isEmpty &&
  //                                     timerController.text == "0:00:00" &&
  //                                     heartRateController.text.isEmpty){
  //                                   return "Must Fill Out a Field";
  //                                 }
  //
  //                               }
  //                               return null;
  //                             },
  //                             decoration: const InputDecoration(
  //                                 hintText: "Calories", labelText: "Calories"),
  //                             keyboardType: TextInputType.number,
  //                             inputFormatters: <TextInputFormatter>[
  //                               FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  //                             ],
  //                           ),
  //                         ),
  //                         Visibility(
  //                           visible: (workout.type == WorkoutType.cardio.index ||
  //                               workout.type == WorkoutType.both.index) &&
  //                               !cardsCompleted[index],
  //                           child: TextFormField(
  //                             controller: heartRateController,
  //                             validator: (value) {
  //                               if(value != null){
  //                                 if(value.isNotEmpty){
  //                                   return null;
  //                                 }
  //                               }
  //
  //                               if(workout.type == WorkoutType.both.index){
  //                                 if(timerController.text == "0:00:00"&&
  //                                     weightController.text.isEmpty &&
  //                                     setController.text.isEmpty &&
  //                                     repController.text.isEmpty &&
  //                                     distanceController.text.isEmpty &&
  //                                     caloriesController.text.isEmpty){
  //                                   return "Must Fill Out a Field";
  //                                 }
  //
  //                               } else if(workout.type == WorkoutType.cardio.index){
  //                                 if(distanceController.text.isEmpty &&
  //                                     caloriesController.text.isEmpty &&
  //                                     timerController.text == "0:00:00"){
  //                                   return "Must Fill Out a Field";
  //                                 }
  //
  //                               }
  //                               return null;
  //                             },
  //                             decoration: const InputDecoration(
  //                                 hintText: "BPM", labelText: "Heart Rate"),
  //                             keyboardType: TextInputType.number,
  //                             inputFormatters: <TextInputFormatter>[
  //                               FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  //                             ],
  //                           ),
  //                         ),
  //                         Visibility(
  //                           visible: !cardsCompleted[index],
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               TextButton(
  //                                 onPressed: () {
  //                                   if (formKeys[index].currentState!.validate()) {
  //                                     WorkoutHistory tempWorkoutHistory = WorkoutHistory();
  //                                     tempWorkoutHistory.workoutName = workout.name;
  //                                     tempWorkoutHistory.workoutType = workout.type;
  //                                     tempWorkoutHistory.date = DateTime.now().toString();
  //                                     tempWorkoutHistory.sets = int.parse(setController.text.isEmpty
  //                                         ? "0"
  //                                             : setController.text);
  //                                     tempWorkoutHistory.reps = int.parse(repController.text.isEmpty
  //                                         ? "0"
  //                                             : repController.text);
  //                                     tempWorkoutHistory.weight = double.parse(weightController.text.isEmpty
  //                                         ? "0"
  //                                             : weightController.text);
  //                                     tempWorkoutHistory.duration = timerController.text;
  //                                     tempWorkoutHistory.distance = double.parse(distanceController.text.isEmpty
  //                                         ? "0"
  //                                             : distanceController.text);
  //                                     tempWorkoutHistory.calories = double.parse(caloriesController.text.isEmpty
  //                                         ? "0"
  //                                             : caloriesController.text);
  //                                     tempWorkoutHistory.heartRate = double.parse(heartRateController.text.isEmpty
  //                                         ? "0"
  //                                             : heartRateController.text);
  //                                     repo.saveWorkoutHistory(tempWorkoutHistory);
  //
  //                                     var newRoutine = routine;
  //                                     newRoutine.date = DateTime.now().toString();
  //                                     repo.updateRoutine(newRoutine);
  //                                     setState(() {
  //                                       cardsCompleted[index] = true;
  //                                       workouts = repo.readAllWorkoutsByRoutine(routine.id);
  //                                     });
  //                                   }
  //                                 },
  //                                 child: const Text("Save"),
  //                               ),
  //                             ],
  //                           ),
  //                         )
  //                       ],
  //                     ),
  //                   ),
  //                 ));
  //           },
  //         );
  //       });
  // }

  //wrap it with an appbar
  @override
  Widget build(BuildContext context) {
    log("current routine is ${routine.name}");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          routine.name,
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
              onPressed: () async {
                var workouts_now = await repo.readAllWorkouts();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExecuteWorkout(workouts: workouts_now, routine: routine,)));
              },
              icon: const Icon(UniconsLine.play))
        ],
      ),
      body: orderedWorkoutList(),
    );
  }
}