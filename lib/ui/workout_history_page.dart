import 'dart:developer';

import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hey_workout/bloc/workout_bloc.dart';
import 'package:hey_workout/bloc/workout_history_bloc.dart';
import 'package:hey_workout/repository/workout_repository.dart';
import 'package:intl/intl.dart';
import 'package:unicons/unicons.dart';
import '../bloc/routine_bloc.dart';
import '../model/routine.dart';
import '../model/workout.dart';
import '../model/workout_history.dart';
import '../utils/utils.dart';
import 'dart:async';

class WorkoutHistoryPage extends StatefulWidget {
  final Workout? workout;
  const WorkoutHistoryPage({Key? key, required this.workout}) : super(key: key);
  @override
  State<WorkoutHistoryPage> createState() =>
      _WorkoutHistoryPageState(workout: this.workout);
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  //used for when we are using the Workout History page from a Workout Profile
  late Workout? workout;

  _WorkoutHistoryPageState({required this.workout});

  final WorkoutHistoryBloc workoutHistoryBloc = WorkoutHistoryBloc();
  final WorkoutBloc workoutBloc = WorkoutBloc();
  final RoutineBloc routineBloc = RoutineBloc();
  final repo = WorkoutRepository();

  //Used for validating fields when adding workout history
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  //value for date range picker
  DateTimeRange? _selectedDateRange = Utils().weekRange();

  @override
  void initState() {
    super.initState();
    routineBloc.getRoutinesForDropdown();
  }

  //index for position in their lists, useful with future builders
  int filterIndex = 0;
  int workoutIndex = 0;



  //function to update the workout index for the dropdown
  // Future<int> updateWorkoutIndex(newValue) async {
  //   var workoutsList = await workoutBloc.getWorkouts();
  //   for (var i = 0; i < workoutsList!.length; i++) {
  //     if (newValue == workoutsList[i].name) {
  //       workoutIndex = i;
  //       return i;
  //     }
  //   }
  //   return -1;
  // }

  //open the Date Range Picker and save the results
  void selectDates() async {
    DateTime now = DateTime.now();
    DateTime dateStart = DateTime(now.year - 5, now.month, now.day);
    DateTime dateEnd = DateTime(now.year, now.month, now.day);
    final DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: dateStart,
        lastDate: dateEnd,
        currentDate: now,
        saveText: 'Done'
    );
    if (result != null) {
      //var dropdownList = await routineBloc.routines.toList();
      //var dropdownValue = await routineBloc.activeRoutine.toList()[0];
      // setState(() {
      //   _selectedDateRange = result;
      //   // -1 is the ID for all, so do not filter if that is the case
      //   if (dropdownList![filterIndex].id == -1) {
      //     _workoutHistory = _workoutHistoryByDates(result);
      //   } else {
      //     _workoutHistory = _workoutHistoryByRoutineAndDates(
      //         dropdownList[filterIndex].id, result);
      //   }
      // });
      //_selectedDateRange = result;

      filterWorkoutHistory(range: result);
      // -1 is the ID for all, so do not filter if that is the case
      // if (dropdownValue.id == -1) {
      //   workoutHistoryBloc.getWorkoutHistoryConditional(range: result);
      // } else {
      //   workoutHistoryBloc.getWorkoutHistoryConditional(
      //       range: result,
      //       routine: dropdownValue
      //   );
      // }
    }
  }

  void filterWorkoutHistory({DateTimeRange? range}) async{
    if(range != null){
      setState(() {
        _selectedDateRange = range;
      });
    }

    Routine? dropdownValue = await routineBloc.activeRoutine.first;
    if(dropdownValue != null){

      //if there is a dropdown value set it
      if (dropdownValue.id == -1) {
        workoutHistoryBloc.getWorkoutHistoryConditional(range: _selectedDateRange);
      } else {
        workoutHistoryBloc.getWorkoutHistoryConditional(
            range: _selectedDateRange,
            routine: dropdownValue
        );
      }
    }

    //if there is no dropdown on the page just use the date
    else {
      workoutHistoryBloc.getWorkoutHistoryConditional(range: _selectedDateRange);
    }
  }

  Widget dropdownWidget() {

    return StreamBuilder <Routine?> (
      stream: routineBloc.activeRoutine,
      builder: (context, activeRoutineSnap){
        return StreamBuilder <List<Routine>?>(
                stream: routineBloc.routines,
                builder: (context, routineDropdownSnap){
                  if (routineDropdownSnap.hasData && activeRoutineSnap.hasData) {
                    return DropdownButton<String>(
                      isExpanded: true,
                      value: activeRoutineSnap.data!.name,
                      icon: const Icon(UniconsLine.angle_down),
                      elevation: 16,
                      style: const TextStyle(color: Colors.white),
                      underline: Container(
                        height: 2,
                        color: Colors.white,
                      ),
                      onChanged: (String? newValue) => dropdownFilter(routineDropdownSnap.data!
                          .firstWhere((element) => element.name == newValue)
                          .id),
                      items: routineDropdownSnap.data!
                          .map<DropdownMenuItem<String>>((Routine value) {
                        return DropdownMenuItem<String>(
                          value: value.name,
                          child: Text(value.name),
                        );
                      }).toList(),
                    );
                  } else {
                    // way to return an empty widget until the routine dropdown populates
                    return const SizedBox.shrink();
                  }
            }
        );
      });
  }

  void dropdownFilter(int routineId) async {
    //should get all of the routines and set the active routine to the correct value
    var routines = await routineBloc.routines.first;
    if(routines != null){
      routineBloc.setActiveRoutine(routine: routines.firstWhere((element) => element.id == routineId));
    }

    filterWorkoutHistory();
  }

  @override
  Widget build(BuildContext context) {
    //if you navigated from the profile, pre filter the history by the id and range
    if (workout != null) {
      workoutHistoryBloc.getWorkoutHistoryByWorkoutAndDates(workout!, _selectedDateRange!);
    }

    //update the filtered list and the filtered index from the dropdown selection

    return Scaffold(
      drawer: const Drawer(),
      body: Container(
        child: Column(
          children: [
            //Date Range Button
            TextButton(
                onPressed: selectDates,
                child: Text(
                  "${DateFormat('yyyy/MM/dd').format(_selectedDateRange!.start)} - "
                      "${DateFormat('yyyy/MM/dd').format(_selectedDateRange!.end)}",
                  style: const TextStyle(color: Colors.grey, fontSize: 18),
                )),
            const Divider(),

            //do not show the routine dropdown on the Workout Profile
            if (workout == null) dropdownWidget(),

            //build a list of workout history cards
            Expanded(
              child: getWorkoutHistoryWidget()
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     //verify that Workouts exist before adding history
      //     List<Workout>? workouts = await workoutBloc.workouts;
      //
      //     if (workouts != null) {
      //       //when opening the add workout modal, an object is always needed
      //       WorkoutHistory workoutHistory = WorkoutHistory();
      //       workoutHistory.workoutName = "";
      //       workoutHistory.date = DateTime.now().toString();
      //       workoutHistory.sets = 0;
      //       workoutHistory.reps = 0;
      //       workoutHistory.weight = 0;
      //       workoutHistory.timer = 0;
      //       workoutHistory.distance = 0;
      //       workoutHistory.calories = 0;
      //       workoutHistory.heartRate = 0;
      //       workoutHistory.workoutId = 0;
      //       workoutIndex = 0;
      //
      //       //if we are not on the Workout Profile, just use the first workout in the dropdown
      //       if (workout == null) {
      //         WorkoutHistory? mostRecentWorkoutHistory =
      //             await _mostRecentWorkoutHistoryByWorkout(workouts[0].id);
      //
      //         //this logic is for pre-populating the history fields
      //         if (mostRecentWorkoutHistory == null) {
      //           await addWorkoutForm(context, true, workoutHistory, false);
      //         } else {
      //           await addWorkoutForm(
      //               context, true, mostRecentWorkoutHistory, false);
      //         }
      //       }
      //
      //       //if we are on the Workout Profile, just use that workout
      //       else {
      //         WorkoutHistory? mostRecentWorkoutHistory =
      //             await _mostRecentWorkoutHistoryByWorkout(workout!.id);
      //         if (mostRecentWorkoutHistory == null) {
      //           await addWorkoutForm(context, true, workoutHistory, true);
      //         } else {
      //           await addWorkoutForm(
      //               context, true, mostRecentWorkoutHistory, true);
      //         }
      //       }
      //     }
      //
      //     //show a pop-up if there are no Workouts
      //     else {
      //       await noWorkoutsAlert();
      //     }
      //   },
      //   tooltip: 'Add Workout',
      //   child: const Icon(Icons.add),
      //   backgroundColor: Colors.white,
      // ),
    );
  }

  Widget getWorkoutHistoryWidget(){
    return StreamBuilder(
      stream: workoutBloc.workouts,
      builder:(BuildContext context, AsyncSnapshot<List<Workout>?> workouts) {
        return StreamBuilder(
          stream: workoutHistoryBloc.workoutHistory,
          builder:(BuildContext context, AsyncSnapshot<List<WorkoutHistory>?> workoutHistory) {
            return getWorkoutHistoryCardWidget(workouts, workoutHistory);
          },
        );
      },
    );
  }
  Widget getWorkoutHistoryCardWidget(AsyncSnapshot<List<Workout>?> workouts,
      AsyncSnapshot<List<WorkoutHistory>?> workoutHistory){
    if ( workoutHistory.hasData &&
        workoutHistory.data != null &&
        workoutHistory.data!.isNotEmpty) {
      return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: workoutHistory.data!.length,
          itemBuilder: (BuildContext context, int index) =>
              buildWorkoutCard(
                  context,
                  workoutHistory.data![index],
                  workouts.data!));
    } else {
      return const Align(
        alignment: Alignment.center,
        child: Text(
          'No History',
          textAlign: TextAlign.center,
        ),
      );
    }
  }
  //update and delete are both on long press
  Future<void> updateOptions(WorkoutHistory workoutHistory) {
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
                    await addWorkoutHistoryForm(context, false, workoutHistory, true);
                  },
                ),
                const Divider(),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    workoutHistoryBloc.deleteWorkoutHistory(workoutHistory: workoutHistory, range: _selectedDateRange);
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

  Future<void> addWorkoutHistoryForm(BuildContext context, bool add,
      WorkoutHistory workoutHistory, bool hasContext) async {
    List<Workout>? workouts = await workoutBloc.workouts.first;

    //names of all the workouts
    List<String> workoutStrings = [];
    for (var i = 0; i < workouts!.length; i++) {
      workoutStrings.add(workouts[i].name);
    }

    //set to the active workout in the dropdown
    //Workout curWorkout = workouts[0];

    if (workout != null) {
      // for (var i = 0; i < workouts.length; i++) {
      //   workoutStrings.add(workouts[i].name);
      //   if (workout!.id == workouts[i].id) {
      //     workoutIndex = i;
      //   }
      // }
      // curWorkout = workout!;
      workoutBloc.setActiveWorkout(workout: workout);
    } else {
      workoutBloc.setActiveWorkout(workout: workouts[0]);
    }

    //default all of the form fields if there was history
    TextEditingController workoutNameController = TextEditingController(
        text: workout != null ? workout!.name : workoutStrings[0]);
    TextEditingController weightController = TextEditingController(
        text: workoutHistory.weight == 0 ? null : workoutHistory.weight.toString());
    TextEditingController timerController = TextEditingController(text: workoutHistory.duration);
    TextEditingController setController = TextEditingController(
        text: workoutHistory.sets == 0 ? null : workoutHistory.sets.toString());
    TextEditingController repController = TextEditingController(
        text: workoutHistory.reps == 0 ? null : workoutHistory.reps.toString());
    TextEditingController distanceController = TextEditingController(
        text: workoutHistory.distance == 0 ? null : workoutHistory.distance.toString());
    TextEditingController caloriesController = TextEditingController(
        text: workoutHistory.calories == 0 ? null : workoutHistory.calories.toString());
    TextEditingController heartRateController = TextEditingController(
        text: workoutHistory.heartRate == 0 ? null : workoutHistory.heartRate.toString());
    DateTime myDateTime =
    add ? DateTime.now() : DateTime.parse(workoutHistory.date);
    TextEditingController dateController = TextEditingController(
        text: DateFormat('yyyy/MM/dd').format(myDateTime));
    TextEditingController timeController = TextEditingController(
        text: DateFormat('hh:mm a').format(myDateTime));

    return await showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child:
          //grab the list of workouts for the dropdown
          StreamBuilder<Workout?>(
              stream: workoutBloc.activeWorkout,
              builder: (context, projectSnap) {
                if (projectSnap.hasData) {
                  return AlertDialog(
                    scrollable: true,
                    content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Form(
                            key: _formKey,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  //if we are updating the record the dropdown should not be clickable
                                  IgnorePointer(
                                    ignoring: !add || hasContext,
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: projectSnap.data!.name,
                                      icon: add
                                          ? const Icon(UniconsLine.angle_down)
                                          : const Icon(null),
                                      elevation: 16,
                                      style: add
                                          ? const TextStyle(color: Colors.white)
                                          : const TextStyle(color: Colors.grey),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.white,
                                      ),
                                      onChanged: (String? newValue) async {
                                        //get the most recent workout history for the new value
                                        WorkoutHistory? mostRecentWorkoutHistory =
                                        await repo
                                            .mostRecentWorkoutHistoryByWorkout(
                                            projectSnap.data!.id);

                                        setState(() {
                                          //if there is history, update all of controller values
                                          if (mostRecentWorkoutHistory !=
                                              null) {
                                            weightController.text =
                                                mostRecentWorkoutHistory.weight
                                                    .toString();
                                            timerController.text =
                                                mostRecentWorkoutHistory
                                                    .duration;
                                            setController.text =
                                                mostRecentWorkoutHistory.sets
                                                    .toString();
                                            repController.text =
                                                mostRecentWorkoutHistory.reps
                                                    .toString();
                                          } else {
                                            weightController.text = "";
                                            timerController.text = "";
                                            setController.text = "";
                                            repController.text = "";
                                          }
                                          workoutNameController.text =
                                          newValue!;
                                          workoutBloc.setActiveWorkout(
                                              workout: workouts.firstWhere((
                                                  element) =>
                                              element.name == newValue));
                                          //curWorkout = workouts[i];
                                        });
                                      },
                                      items: workouts
                                          .map<DropdownMenuItem<String>>(
                                              (Workout value) {
                                            return DropdownMenuItem<String>(
                                              value: value.name,
                                              child: Text(value.name),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                  Visibility(
                                    visible: projectSnap.data!.type ==
                                        WorkoutType.strength.index ||
                                        projectSnap.data!.type ==
                                            WorkoutType.both.index,
                                    child: TextFormField(
                                      controller: weightController,
                                      validator: (value) {
                                        if (value != null) {
                                          if (value.isNotEmpty) {
                                            return null;
                                          }
                                        }
                                        if (projectSnap.data!.type ==
                                            WorkoutType.both.index) {
                                          if (timerController.text ==
                                              "0:00:00" &&
                                              setController.text.isEmpty &&
                                              repController.text.isEmpty &&
                                              distanceController.text.isEmpty &&
                                              caloriesController.text.isEmpty &&
                                              heartRateController.text
                                                  .isEmpty) {
                                            return "Must Fill Out a Field";
                                          }
                                        } else if (projectSnap.data!.type ==
                                            WorkoutType.strength.index) {
                                          if (setController.text.isEmpty &&
                                              repController.text.isEmpty) {
                                            return "Must Fill Out a Field";
                                          }
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
                                  Visibility(
                                    visible: projectSnap.data!.type ==
                                        WorkoutType.strength.index ||
                                        projectSnap.data!.type ==
                                            WorkoutType.both.index,
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Container(
                                            width: 50,
                                            child: TextFormField(
                                              controller: setController,
                                              validator: (value) {
                                                if (value != null) {
                                                  if (value.isNotEmpty) {
                                                    return null;
                                                  }
                                                }

                                                if (projectSnap.data!.type ==
                                                    WorkoutType.both.index) {
                                                  if (timerController.text ==
                                                      "0:00:00" &&
                                                      weightController.text
                                                          .isEmpty &&
                                                      repController.text
                                                          .isEmpty &&
                                                      distanceController.text
                                                          .isEmpty &&
                                                      caloriesController.text
                                                          .isEmpty &&
                                                      heartRateController.text
                                                          .isEmpty) {
                                                    return "Must Fill Out a Field";
                                                  }
                                                } else
                                                if (projectSnap.data!.type ==
                                                    WorkoutType.strength
                                                        .index) {
                                                  if (weightController.text
                                                      .isEmpty &&
                                                      repController.text
                                                          .isEmpty) {
                                                    return "Must Fill Out a Field";
                                                  }
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                  hintText: "Sets",
                                                  labelText: "Sets"),
                                              keyboardType: TextInputType
                                                  .number,
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(
                                                    RegExp(r'[0-9]')),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 50,
                                            child: TextFormField(
                                              controller: repController,
                                              validator: (value) {
                                                if (value != null) {
                                                  if (value.isNotEmpty) {
                                                    return null;
                                                  }
                                                }

                                                if (projectSnap.data!.type ==
                                                    WorkoutType.both.index) {
                                                  if (timerController.text ==
                                                      "0:00:00" &&
                                                      weightController.text
                                                          .isEmpty &&
                                                      setController.text
                                                          .isEmpty &&
                                                      distanceController.text
                                                          .isEmpty &&
                                                      caloriesController.text
                                                          .isEmpty &&
                                                      heartRateController.text
                                                          .isEmpty) {
                                                    return "Must Fill Out a Field";
                                                  }
                                                } else
                                                if (projectSnap.data!.type ==
                                                    WorkoutType.strength
                                                        .index) {
                                                  if (weightController.text
                                                      .isEmpty &&
                                                      setController.text
                                                          .isEmpty) {
                                                    return "Must Fill Out a Field";
                                                  }
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                  hintText: "Reps",
                                                  labelText: "Reps"),
                                              keyboardType: TextInputType
                                                  .number,
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(
                                                    RegExp(r'[0-9]')),
                                              ],
                                            ),
                                          ),
                                        ]),
                                  ),
                                  Visibility(
                                    visible: projectSnap.data!.type ==
                                        WorkoutType.cardio.index ||
                                        projectSnap.data!.type ==
                                            WorkoutType.both.index,
                                    child: TextFormField(
                                      controller: timerController,
                                      readOnly: true,
                                      validator: (value) {
                                        if (value != null) {
                                          if (value.isNotEmpty &&
                                              value != "0:00:00") {
                                            return null;
                                          }
                                        }
                                        if (projectSnap.data!.type ==
                                            WorkoutType.both.index) {
                                          if (weightController.text.isEmpty &&
                                              setController.text.isEmpty &&
                                              repController.text.isEmpty &&
                                              distanceController.text.isEmpty &&
                                              caloriesController.text.isEmpty &&
                                              heartRateController.text
                                                  .isEmpty) {
                                            return "Must Fill Out a Field";
                                          }
                                        } else if (projectSnap.data!.type ==
                                            WorkoutType.cardio.index) {
                                          if (distanceController.text.isEmpty &&
                                              caloriesController.text.isEmpty &&
                                              heartRateController.text
                                                  .isEmpty) {
                                            return "Must Fill Out a Field";
                                          }
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                          hintText: "Duration",
                                          labelText: "Duration"),
                                      onTap: () async {
                                        log("current timer${timerController
                                            .text}");
                                        Duration? curTimer = parseDuration(
                                            timerController
                                                .text); //double.tryParse(timerController.text);

                                        Duration? duration;
                                        if (curTimer != null) {
                                          // duration = await showDurationPicker(context: context,
                                          //     initialDuration: Duration(microseconds: curTimer.toInt()),
                                          //     durationPickerMode: DurationPickerMode.Hour
                                          //);
                                          log("current timer${timerController
                                              .text}");
                                          duration =
                                          await Utils().selectDuration(
                                              context, curTimer);
                                        } else {
                                          // duration = await showDurationPicker(context: context,
                                          //     initialDuration: const Duration(microseconds: 0),
                                          //     durationPickerMode: DurationPickerMode.Hour
                                          //);
                                          log("current timer is null");
                                          duration =
                                          await Utils().selectDuration(context,
                                              const Duration(microseconds: 0));
                                        }
                                        log("saved duration ${duration.inSeconds
                                            .toString()}");

                                        setState(() {
                                          timerController.text =
                                              duration.toString().substring(0,
                                                  duration.toString().indexOf(
                                                      '.'));
                                        });
                                      },
                                      // keyboardType: TextInputType.number,
                                      // inputFormatters: <TextInputFormatter>[
                                      //   FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                      //],
                                    ),
                                  ),
                                  Visibility(
                                    visible: projectSnap.data!.type ==
                                        WorkoutType.cardio.index ||
                                        projectSnap.data!.type ==
                                            WorkoutType.both.index,
                                    child: TextFormField(
                                      controller: distanceController,
                                      validator: (value) {
                                        if (value != null) {
                                          if (value.isNotEmpty) {
                                            return null;
                                          }
                                        }

                                        if (projectSnap.data!.type ==
                                            WorkoutType.both.index) {
                                          if (timerController.text ==
                                              "0:00:00" &&
                                              weightController.text.isEmpty &&
                                              setController.text.isEmpty &&
                                              repController.text.isEmpty &&
                                              caloriesController.text.isEmpty &&
                                              heartRateController.text
                                                  .isEmpty) {
                                            return "Must Fill Out a Field";
                                          }
                                        } else if (projectSnap.data!.type ==
                                            WorkoutType.cardio.index) {
                                          if (timerController.text ==
                                              "0:00:00" &&
                                              caloriesController.text.isEmpty &&
                                              heartRateController.text
                                                  .isEmpty) {
                                            return "Must Fill Out a Field";
                                          }
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                          hintText: "Miles",
                                          labelText: "Distance"),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.]')),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: projectSnap.data!.type ==
                                        WorkoutType.cardio.index ||
                                        projectSnap.data!.type ==
                                            WorkoutType.both.index,
                                    child: TextFormField(
                                      controller: caloriesController,
                                      validator: (value) {
                                        if (value != null) {
                                          if (value.isNotEmpty) {
                                            return null;
                                          }
                                        }

                                        if (projectSnap.data!.type ==
                                            WorkoutType.both.index) {
                                          if (timerController.text ==
                                              "0:00:00" &&
                                              weightController.text.isEmpty &&
                                              setController.text.isEmpty &&
                                              repController.text.isEmpty &&
                                              distanceController.text.isEmpty &&
                                              heartRateController.text
                                                  .isEmpty) {
                                            return "Must Fill Out a Field";
                                          }
                                        } else if (projectSnap.data!.type ==
                                            WorkoutType.cardio.index) {
                                          if (distanceController.text.isEmpty &&
                                              timerController.text ==
                                                  "0:00:00" &&
                                              heartRateController.text
                                                  .isEmpty) {
                                            return "Must Fill Out a Field";
                                          }
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                          hintText: "Calories",
                                          labelText: "Calories"),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.]')),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: projectSnap.data!.type ==
                                        WorkoutType.cardio.index ||
                                        projectSnap.data!.type ==
                                            WorkoutType.both.index,
                                    child: TextFormField(
                                      controller: heartRateController,
                                      validator: (value) {
                                        if (value != null) {
                                          if (value.isNotEmpty) {
                                            return null;
                                          }
                                        }

                                        if (projectSnap.data!.type ==
                                            WorkoutType.both.index) {
                                          if (timerController.text ==
                                              "0:00:00" &&
                                              weightController.text.isEmpty &&
                                              setController.text.isEmpty &&
                                              repController.text.isEmpty &&
                                              distanceController.text.isEmpty &&
                                              caloriesController.text.isEmpty) {
                                            return "Must Fill Out a Field";
                                          }
                                        } else if (projectSnap.data!.type ==
                                            WorkoutType.cardio.index) {
                                          if (distanceController.text.isEmpty &&
                                              caloriesController.text.isEmpty &&
                                              timerController.text ==
                                                  "0:00:00") {
                                            return "Must Fill Out a Field";
                                          }
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                          hintText: "BPM",
                                          labelText: "Heart Rate"),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.]')),
                                      ],
                                    ),
                                  ),
                                  TextField(
                                    controller: dateController,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime now = DateTime.now();
                                      var dateTemp = (await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.parse(
                                            workoutHistory.date),
                                        firstDate: DateTime(
                                            now.year - 5, now.month, now.day),
                                        lastDate: DateTime(
                                            now.year, now.month, now.day),
                                      ));
                                      myDateTime = dateTemp ?? myDateTime;
                                      dateController.text =
                                          DateFormat('yyyy/MM/dd').format(
                                              myDateTime);
                                      setState(() {});
                                    },
                                  ),
                                  TextField(
                                    controller: timeController,
                                    readOnly: true,
                                    onTap: () async {
                                      var timeTemp = (await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                              DateTime.parse(
                                                  workoutHistory.date))
                                      ));
                                      if (timeTemp != null) {
                                        myDateTime = DateTime(
                                            myDateTime.year, myDateTime.month,
                                            myDateTime.day, timeTemp.hour,
                                            timeTemp.minute);
                                        timeController.text =
                                            DateFormat('hh:mm a').format(
                                                myDateTime);
                                        setState(() {});
                                      }
                                    },
                                  )
                                ]),
                          );
                        }
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          //verify form validations
                          if (_formKey.currentState!.validate()) {
                            //for updating existing workout history records
                            workoutHistory.workoutName =
                                workoutNameController.text;
                            workoutHistory.date = myDateTime.toString();
                            workoutHistory.sets =
                                int.parse(setController.text.isEmpty
                                    ? "0"
                                    : setController.text);
                            workoutHistory.reps =
                                int.parse(repController.text.isEmpty
                                    ? "0"
                                    : repController.text);
                            workoutHistory.weight = double.parse(
                                weightController.text.isEmpty
                                    ? "0"
                                    : weightController.text);
                            workoutHistory.duration = timerController.text;
                            workoutHistory.distance = double.parse(
                                distanceController.text.isEmpty
                                    ? "0"
                                    : distanceController.text);
                            workoutHistory.calories = double.parse(
                                caloriesController.text.isEmpty
                                    ? "0"
                                    : caloriesController.text);
                            workoutHistory.heartRate = double.parse(
                                heartRateController.text.isEmpty
                                    ? "0"
                                    : heartRateController.text);
                            if (!add) {
                              //_updateWorkoutHistory(workoutHistory);
                              workoutHistoryBloc.updateWorkoutHistory(
                                  workoutHistory: workoutHistory);
                            } else {
                              //on add, get relevant info from the dropdown selection
                              int workoutId = -1;
                              int workoutType = -1;
                              for (var i = 0; i < workouts.length; i++) {
                                if (workouts[i].name ==
                                    workoutNameController.text) {
                                  workoutId = workouts[i].id;
                                  workoutType = workouts[i].type;
                                }
                              }
                              workoutHistory.workoutName = projectSnap.data!.name;
                              workoutHistory.workoutType = projectSnap.data!.type;
                              workoutHistoryBloc.addWorkoutHistory(workoutHistory: workoutHistory);
                            }

                            //update the workout history list, and reset the index

                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Save"),
                      )
                    ],
                  );
                } else {
                  return const Text(
                    'No History',
                    textAlign: TextAlign.center,
                  );
                }
              }),

          //display each history based on the workout type with empty validation
        );
      }
    );
  }

  Widget buildWorkoutCard(BuildContext context, workoutHistory, workouts) {
    WorkoutType? type;
    for (var i = 0; i < workouts.length; i++) {
      if (workoutHistory.workoutId == workouts[i].id) {
        type = WorkoutType.values[workouts[i].type];
      }
    }

    //build a card depending on the type of workout
    switch (type) {
      case null:
        return const SizedBox.shrink();
      case WorkoutType.strength:
        return Container(
          margin: const EdgeInsets.all(0),
          child: Card(
            // shape: RoundedRectangleBorder(
            //   side: const BorderSide(color: myRed, width: 2),
            //   borderRadius: BorderRadius.circular(15),
            // ),
            child: ListTile(
              onTap: () async {
                //await addWorkoutHistoryForm(context, false, workoutHistory, true);
                if(workout == null){
                  Workout? tempWorkout = await repo.readWorkout(workoutHistory.workoutId);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //             WorkoutProfile(workout: tempWorkout!)));
                }
              },
              onLongPress: () async {
                await updateOptions(workoutHistory);
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
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text('${Utils().getWorkoutHistoryString(workoutHistory.weight)} LBS'),
                        const Spacer(),
                        Text('${Utils().getWorkoutHistoryString(workoutHistory.sets)} Sets'),
                        const Spacer(),
                        Text('${Utils().getWorkoutHistoryString(workoutHistory.reps)} Reps'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case WorkoutType.cardio:
        return Container(
          margin: const EdgeInsets.all(0),
          child: Card(
            child: ListTile(
              onTap: () async {
                //await addWorkoutHistoryForm(context, false, workoutHistory, true);
                if(workout == null){
                  Workout? tempWorkout = await repo.readWorkout(workoutHistory.workoutId);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //             WorkoutProfile(workout: tempWorkout!)));
                }
              },
              onLongPress: () async {
                await updateOptions(workoutHistory);
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
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Duration: ${workoutHistory.duration}'),
                        const Spacer(),
                        Text('${Utils().getWorkoutHistoryString(workoutHistory.distance)} Mi'),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Heart Rate: ${Utils().getWorkoutHistoryString(workoutHistory.heartRate)}'),
                        const Spacer(),
                        Text('${Utils().getWorkoutHistoryString(workoutHistory.calories)} Cal'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case WorkoutType.both:
        return Container(
          margin: const EdgeInsets.all(0),
          child: Card(
            child: ListTile(
              onTap: () async {
                //await addWorkoutHistoryForm(context, false, workoutHistory, true);
                if(workout == null){
                  Workout? tempWorkout = await repo.readWorkout(workoutHistory.workoutId);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //             WorkoutProfile(workout: tempWorkout!)));
                }
              },
              onLongPress: () async {
                await updateOptions(workoutHistory);
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
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text('${Utils().getWorkoutHistoryString(workoutHistory.weight)} LBS'),
                        const Spacer(),
                        Text('${Utils().getWorkoutHistoryString(workoutHistory.sets)} Sets'),
                        const Spacer(),
                        Text('${Utils().getWorkoutHistoryString(workoutHistory.reps)} Reps'),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Duration: ${workoutHistory.duration}'),
                        const Spacer(),
                        Text('${Utils().getWorkoutHistoryString(workoutHistory.distance)} Mi'),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Heart Rate: ${Utils().getWorkoutHistoryString(workoutHistory.heartRate)}'),
                        const Spacer(),
                        Text('${Utils().getWorkoutHistoryString(workoutHistory.calories)} Cal'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
