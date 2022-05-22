import 'package:flutter/material.dart';
import 'package:hey_workout/bloc/workout_history_bloc.dart';
import 'package:hey_workout/repository/workout_repository.dart';
import 'package:intl/intl.dart';
import 'package:unicons/unicons.dart';
import '../model/routine.dart';
import '../model/workout.dart';
import '../model/workout_history.dart';
import '../utils/utils.dart';

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
  final repo = WorkoutRepository();
  //Used for validating fields when adding workout history
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  //value for date range picker
  DateTimeRange? _selectedDateRange = Utils().weekRange();

  //list of all saved workouts
  late Future<List<Workout>?> _workouts;

  //list for populating Routine Dropdown Filter
  late Future<List<Routine>?> _routineDropdown;

  @override
  void initState() {
    super.initState();
    _workouts = repo.readAllWorkouts();
    _routineDropdown = repo.readAllRoutinesDropdown();
  }

  //index for position in their lists, useful with future builders
  int filterIndex = 0;
  int workoutIndex = 0;



  //function to update the workout index for the dropdown
  Future<int> updateWorkoutIndex(newValue) async {
    var workoutsList = await _workouts;
    for (var i = 0; i < workoutsList!.length; i++) {
      if (newValue == workoutsList[i].name) {
        workoutIndex = i;
        return i;
      }
    }
    return -1;
  }

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
      var dropdownList = await _routineDropdown;
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
      _selectedDateRange = result;
      // -1 is the ID for all, so do not filter if that is the case
      if (dropdownList![filterIndex].id == -1) {
        workoutHistoryBloc.getWorkoutHistoryConditional(range: result);
      } else {
        workoutHistoryBloc.getWorkoutHistoryConditional(
            range: result,
            routine: dropdownList[filterIndex]
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //if you navigated from the profile, pre filter the history by the id and range
    if (workout != null) {
      workoutHistoryBloc.getWorkoutHistoryByWorkoutAndDates(workout!, _selectedDateRange!);
    }

    //update the filtered list and the filtered index from the dropdown selection
    void dropdownFilter(int routineId) async {
      var routines = await _routineDropdown;
      setState(() {
        for (int i = 0; i < routines!.length; i++) {
          if (routineId == routines[i].id) {
            filterIndex = i;
          }
        }
      });

      if (routineId == -1) {
        workoutHistoryBloc.getWorkoutHistoryByDates(_selectedDateRange!);
      } else {
        workoutHistoryBloc.getWorkoutHistoryByRoutineAndDates(routines![filterIndex], _selectedDateRange!);
      }
    }

    //Dropdown Widget that updates the results
    Widget dropdownWidget() {
      return FutureBuilder<List<Routine>?>(
        future: _routineDropdown,
        builder: (context, projectSnap) {
          if (projectSnap.hasData) {
            return DropdownButton<String>(
              isExpanded: true,
              value: projectSnap.data![filterIndex].name,
              icon: const Icon(UniconsLine.angle_down),
              elevation: 16,
              style: const TextStyle(color: Colors.white),
              underline: Container(
                height: 2,
                color: Colors.white,
              ),
              onChanged: (String? newValue) => dropdownFilter(projectSnap.data!
                  .firstWhere((element) => element.name == newValue)
                  .id),
              items: projectSnap.data!
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
        },
      );
    }

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
              child: FutureBuilder<List<dynamic>?>(
                future: Future.wait([_workoutHistory, _workouts]),
                builder: (context, projectSnap) {
                  if (projectSnap.hasData &&
                      projectSnap.data![0] != null &&
                      projectSnap.data![0].length > 0) {
                    return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: projectSnap.data![0]?.length,
                        itemBuilder: (BuildContext context, int index) =>
                            buildWorkoutCard(
                                context,
                                projectSnap.data![0][index],
                                projectSnap.data![1]));
                  } else {
                    return const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'No History',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //verify that Workouts exist before adding history
          List<Workout>? workouts = await _workouts;

          if (workouts != null) {
            //when opening the add workout modal, an object is always needed
            WorkoutHistory workoutHistory = WorkoutHistory();
            workoutHistory.workoutName = "";
            workoutHistory.date = DateTime.now().toString();
            workoutHistory.sets = 0;
            workoutHistory.reps = 0;
            workoutHistory.weight = 0;
            workoutHistory.timer = 0;
            workoutHistory.distance = 0;
            workoutHistory.calories = 0;
            workoutHistory.heartRate = 0;
            workoutHistory.workoutId = 0;
            workoutIndex = 0;

            //if we are not on the Workout Profile, just use the first workout in the dropdown
            if (workout == null) {
              WorkoutHistory? mostRecentWorkoutHistory =
                  await _mostRecentWorkoutHistoryByWorkout(workouts[0].id);

              //this logic is for pre-populating the history fields
              if (mostRecentWorkoutHistory == null) {
                await addWorkoutForm(context, true, workoutHistory, false);
              } else {
                await addWorkoutForm(
                    context, true, mostRecentWorkoutHistory, false);
              }
            }

            //if we are on the Workout Profile, just use that workout
            else {
              WorkoutHistory? mostRecentWorkoutHistory =
                  await _mostRecentWorkoutHistoryByWorkout(workout!.id);
              if (mostRecentWorkoutHistory == null) {
                await addWorkoutForm(context, true, workoutHistory, true);
              } else {
                await addWorkoutForm(
                    context, true, mostRecentWorkoutHistory, true);
              }
            }
          }

          //show a pop-up if there are no Workouts
          else {
            await noWorkoutsAlert();
          }
        },
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }

  update and delete are both on long press
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
                    await _deleteWorkoutHistory(workoutHistory.id);
                    setState(() {
                      _workoutHistory = _workoutHistoryByDates(_selectedDateRange!);
                    });
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
    List<Workout>? workouts = await _readAllWorkouts();

    //names of all the workouts
    List<String> workoutStrings = [];

    //set to the active workout in the dropdown
    Workout curWorkout = workouts![0];

    if (workout != null) {
      for (var i = 0; i < workouts.length; i++) {
        workoutStrings.add(workouts[i].name);
        if (workout!.id == workouts[i].id) {
          workoutIndex = i;
        }
      }
      curWorkout = workout!;
    } else {
      for (var i = 0; i < workouts.length; i++) {
        workoutStrings.add(workouts[i].name);
        if (workoutHistory.workoutId == workouts[i].id) {
          workoutIndex = i;
          curWorkout = workouts[i];
        }
      }
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
          child: AlertDialog(
            scrollable: true,
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //grab the list of workouts for the dropdown
                        FutureBuilder<List<Workout>?>(
                            future: _workouts,
                            builder: (context, projectSnap) {
                              if (projectSnap.hasData) {
                                //if we are updating the record the dropdown should not be clickable
                                return IgnorePointer(
                                  ignoring: !add || hasContext,
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: projectSnap.data![workoutIndex].name,
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
                                      //need to save the index for the new dropdown selection
                                      int i = await updateWorkoutIndex(newValue);

                                      //gwe the most recent workout history for the new value
                                      WorkoutHistory? mostRecentWorkoutHistory =
                                      await _mostRecentWorkoutHistoryByWorkout(
                                          projectSnap.data![i].id);

                                      setState(() {
                                        //if there is history, update all of controller values
                                        if (mostRecentWorkoutHistory != null) {
                                          weightController.text =
                                              mostRecentWorkoutHistory.weight
                                                  .toString();
                                          timerController.text =
                                              mostRecentWorkoutHistory.duration;
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
                                        workoutNameController.text = newValue!;
                                        curWorkout = projectSnap.data![i];
                                      });
                                    },
                                    items: projectSnap.data!
                                        .map<DropdownMenuItem<String>>(
                                            (Workout value) {
                                          return DropdownMenuItem<String>(
                                            value: value.name,
                                            child: Text(value.name),
                                          );
                                        }).toList(),
                                  ),
                                );
                              } else {
                                return const Text(
                                  'No History',
                                  textAlign: TextAlign.center,
                                );
                              }
                            }),

                        //display each history based on the workout type with empty validations
                        Visibility(
                          visible: curWorkout.type == WorkoutType.strength.index ||
                              curWorkout.type == WorkoutType.both.index,
                          child: TextFormField(
                            controller: weightController,
                            validator: (value) {
                              if(value != null){
                                if(value.isNotEmpty){
                                  return null;
                                }
                              }
                              if(curWorkout.type == WorkoutType.both.index){
                                if(timerController.text == "0:00:00" &&
                                    setController.text.isEmpty &&
                                    repController.text.isEmpty &&
                                    distanceController.text.isEmpty &&
                                    caloriesController.text.isEmpty &&
                                    heartRateController.text.isEmpty){
                                  return "Must Fill Out a Field";
                                }

                              } else if(curWorkout.type == WorkoutType.strength.index){
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
                          visible: curWorkout.type == WorkoutType.strength.index ||
                              curWorkout.type == WorkoutType.both.index,
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

                                      if(curWorkout.type == WorkoutType.both.index){
                                        if(timerController.text == "0:00:00" &&
                                            weightController.text.isEmpty &&
                                            repController.text.isEmpty &&
                                            distanceController.text.isEmpty &&
                                            caloriesController.text.isEmpty &&
                                            heartRateController.text.isEmpty){
                                          return "Must Fill Out a Field";
                                        }

                                      } else if(curWorkout.type == WorkoutType.strength.index){
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
                                Container(
                                  width: 50,
                                  child: TextFormField(
                                    controller: repController,
                                    validator: (value) {
                                      if(value != null){
                                        if(value.isNotEmpty){
                                          return null;
                                        }
                                      }

                                      if(curWorkout.type == WorkoutType.both.index){
                                        if(timerController.text == "0:00:00" &&
                                            weightController.text.isEmpty &&
                                            setController.text.isEmpty &&
                                            distanceController.text.isEmpty &&
                                            caloriesController.text.isEmpty &&
                                            heartRateController.text.isEmpty){
                                          return "Must Fill Out a Field";
                                        }

                                      } else if(curWorkout.type == WorkoutType.strength.index){
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
                              ]),
                        ),
                        Visibility(
                          visible: curWorkout.type == WorkoutType.cardio.index ||
                              curWorkout.type == WorkoutType.both.index,
                          child: TextFormField(
                            controller: timerController,
                            readOnly: true,
                            validator: (value) {
                              if(value != null){
                                if(value.isNotEmpty && value != "0:00:00"){
                                  return null;
                                }
                              }
                              if(curWorkout.type == WorkoutType.both.index){
                                if(weightController.text.isEmpty &&
                                    setController.text.isEmpty &&
                                    repController.text.isEmpty &&
                                    distanceController.text.isEmpty &&
                                    caloriesController.text.isEmpty &&
                                    heartRateController.text.isEmpty){
                                  return "Must Fill Out a Field";
                                }

                              } else if(curWorkout.type == WorkoutType.cardio.index){
                                if(distanceController.text.isEmpty &&
                                    caloriesController.text.isEmpty &&
                                    heartRateController.text.isEmpty){
                                  return "Must Fill Out a Field";
                                }

                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                hintText: "Duration", labelText: "Duration"),
                            onTap: () async{
                              log("current timer${timerController.text}");
                              Duration? curTimer = parseDuration(timerController.text); //double.tryParse(timerController.text);

                              Duration? duration;
                              if(curTimer != null){
                                // duration = await showDurationPicker(context: context,
                                //     initialDuration: Duration(microseconds: curTimer.toInt()),
                                //     durationPickerMode: DurationPickerMode.Hour
                                //);
                                log("current timer${timerController.text}");
                                duration = await selectDuration(context, curTimer);
                              } else {
                                // duration = await showDurationPicker(context: context,
                                //     initialDuration: const Duration(microseconds: 0),
                                //     durationPickerMode: DurationPickerMode.Hour
                                //);
                                log("current timer is null");
                                duration = await selectDuration(context,const Duration(microseconds: 0));
                              }
                              log("saved duration ${duration.inSeconds.toString()}");

                              setState(() {
                                timerController.text = duration.toString().substring(0, duration.toString().indexOf('.'));
                              });
                            },
                            // keyboardType: TextInputType.number,
                            // inputFormatters: <TextInputFormatter>[
                            //   FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                            //],
                          ),
                        ),
                        Visibility(
                          visible: curWorkout.type == WorkoutType.cardio.index ||
                              curWorkout.type == WorkoutType.both.index,
                          child: TextFormField(
                            controller: distanceController,
                            validator: (value) {
                              if(value != null){
                                if(value.isNotEmpty){
                                  return null;
                                }
                              }

                              if(curWorkout.type == WorkoutType.both.index){
                                if(timerController.text == "0:00:00" &&
                                    weightController.text.isEmpty &&
                                    setController.text.isEmpty &&
                                    repController.text.isEmpty &&
                                    caloriesController.text.isEmpty &&
                                    heartRateController.text.isEmpty){
                                  return "Must Fill Out a Field";
                                }

                              } else if(curWorkout.type == WorkoutType.cardio.index){
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
                          visible: curWorkout.type == WorkoutType.cardio.index ||
                              curWorkout.type == WorkoutType.both.index,
                          child: TextFormField(
                            controller: caloriesController,
                            validator: (value) {
                              if(value != null){
                                if(value.isNotEmpty){
                                  return null;
                                }
                              }

                              if(curWorkout.type == WorkoutType.both.index){
                                if(timerController.text == "0:00:00" &&
                                    weightController.text.isEmpty &&
                                    setController.text.isEmpty &&
                                    repController.text.isEmpty &&
                                    distanceController.text.isEmpty &&
                                    heartRateController.text.isEmpty){
                                  return "Must Fill Out a Field";
                                }

                              } else if(curWorkout.type == WorkoutType.cardio.index){
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
                          visible: curWorkout.type == WorkoutType.cardio.index ||
                              curWorkout.type == WorkoutType.both.index,
                          child: TextFormField(
                            controller: heartRateController,
                            validator: (value) {
                              if(value != null){
                                if(value.isNotEmpty){
                                  return null;
                                }
                              }

                              if(curWorkout.type == WorkoutType.both.index){
                                if(timerController.text == "0:00:00" &&
                                    weightController.text.isEmpty &&
                                    setController.text.isEmpty &&
                                    repController.text.isEmpty &&
                                    distanceController.text.isEmpty &&
                                    caloriesController.text.isEmpty){
                                  return "Must Fill Out a Field";
                                }

                              } else if(curWorkout.type == WorkoutType.cardio.index){
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
                        TextField(
                          controller: dateController,
                          readOnly: true,
                          onTap: () async {
                            DateTime now = DateTime.now();
                            var dateTemp = (await showDatePicker(
                              context: context,
                              initialDate: DateTime.parse(workoutHistory.date),
                              firstDate: DateTime(now.year - 5, now.month, now.day),
                              lastDate: DateTime(now.year, now.month, now.day),
                            ));
                            myDateTime = dateTemp ?? myDateTime;
                            dateController.text =
                                DateFormat('yyyy/MM/dd').format(myDateTime);
                            setState(() {});
                          },
                        ),
                        TextField(
                          controller: timeController,
                          readOnly: true,
                          onTap: () async {
                            var timeTemp = (await showTimePicker(
                                context: context,
                                initialTime:TimeOfDay.fromDateTime(DateTime.parse(workoutHistory.date))
                            ));
                            if(timeTemp != null){
                              myDateTime = DateTime(myDateTime.year, myDateTime.month, myDateTime.day, timeTemp.hour, timeTemp.minute);
                              timeController.text =
                                  DateFormat('hh:mm a').format(myDateTime);
                              setState(() {});
                            }
                          },
                        )
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
                  //verify form validations
                  if (_formKey.currentState!.validate()) {
                    if (!add) {
                      //for updating existing workout history records
                      workoutHistory.workoutName = workoutNameController.text;
                      workoutHistory.date = myDateTime.toString();
                      workoutHistory.sets = int.parse(setController.text.isEmpty
                          ? "0"
                          : setController.text);
                      workoutHistory.reps = int.parse(repController.text.isEmpty
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
                      _updateWorkoutHistory(workoutHistory);
                    } else {
                      //on add, get relevant info from the dropdown selection
                      int workoutId = -1;
                      int workoutType = -1;
                      for (var i = 0; i < workouts.length; i++) {
                        if (workouts[i].name == workoutNameController.text) {
                          workoutId = workouts[i].id;
                          workoutType = workouts[i].type;
                        }
                      }
                      _saveWorkoutHistory(
                          workoutNameController.text,
                          workoutType,
                          myDateTime,
                          int.parse(setController.text.isEmpty
                              ? "0"
                              : setController.text),
                          int.parse(repController.text.isEmpty
                              ? "0"
                              : repController.text),
                          double.parse(weightController.text.isEmpty
                              ? "0"
                              : weightController.text),
                          timerController.text,
                          double.parse(distanceController.text.isEmpty
                              ? "0"
                              : distanceController.text),
                          double.parse(caloriesController.text.isEmpty
                              ? "0"
                              : caloriesController.text),
                          double.parse(heartRateController.text.isEmpty
                              ? "0"
                              : heartRateController.text),
                          workoutId);
                    }

                    //update the workout history list, and reset the index
                    setState(() {
                      _workoutHistory =
                          _workoutHistoryByDates(_selectedDateRange!);
                      filterIndex = 0;
                    });
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
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: myRed, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              onTap: () async {
                //await addWorkoutHistoryForm(context, false, workoutHistory, true);
                if(workout == null){
                  Workout? tempWorkout = await _readWorkout(workoutHistory.workoutId);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              WorkoutProfile(workout: tempWorkout!)));
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
                        Text('${getWorkoutHistoryString(workoutHistory.weight)} LBS'),
                        const Spacer(),
                        Text('${getWorkoutHistoryString(workoutHistory.sets)} Sets'),
                        const Spacer(),
                        Text('${getWorkoutHistoryString(workoutHistory.reps)} Reps'),
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
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: myBlue, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              onTap: () async {
                //await addWorkoutHistoryForm(context, false, workoutHistory, true);
                if(workout == null){
                  Workout? tempWorkout = await _readWorkout(workoutHistory.workoutId);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              WorkoutProfile(workout: tempWorkout!)));
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
                        Text('${getWorkoutHistoryString(workoutHistory.distance)} Mi'),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Heart Rate: ${getWorkoutHistoryString(workoutHistory.heartRate)}'),
                        const Spacer(),
                        Text('${getWorkoutHistoryString(workoutHistory.calories)} Cal'),
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
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: myPurple, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              onTap: () async {
                //await addWorkoutHistoryForm(context, false, workoutHistory, true);
                if(workout == null){
                  Workout? tempWorkout = await _readWorkout(workoutHistory.workoutId);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              WorkoutProfile(workout: tempWorkout!)));
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
                        Text('${getWorkoutHistoryString(workoutHistory.weight)} LBS'),
                        const Spacer(),
                        Text('${getWorkoutHistoryString(workoutHistory.sets)} Sets'),
                        const Spacer(),
                        Text('${getWorkoutHistoryString(workoutHistory.reps)} Reps'),
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
                        Text('${getWorkoutHistoryString(workoutHistory.distance)} Mi'),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Heart Rate: ${getWorkoutHistoryString(workoutHistory.heartRate)}'),
                        const Spacer(),
                        Text('${getWorkoutHistoryString(workoutHistory.calories)} Cal'),
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
