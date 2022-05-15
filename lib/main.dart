import 'package:unicons/unicons.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'database_helper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:draw_graph/draw_graph.dart';
import 'package:draw_graph/models/feature.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Log',
      theme: ThemeData.dark(),

      // experimenting with custom pallets. For now, Dark Only.
      // darkTheme: ThemeData.from(colorScheme: ColorScheme.fromSwatch(primarySwatch:
      // MaterialColor(CustomColors.darkBrown[800]!.value, CustomColors.darkBrown))
      //     .copyWith(secondary: CustomColors.beige[100],)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
                await weightAlert();
              },
            ),
          ],
          title: const Text(
            "Fitness Log",
            textAlign: TextAlign.center,
          ),
          bottom: const TabBar(tabs: <Widget>[
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
        body: const TabBarView(
          children: <Widget>[
            //Null workout object because we are viewing history for all workouts
            WorkoutHistoryPage(workout: null),
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

  //Used for validating fields when adding workout history
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //value for date range picker
  DateTimeRange? _selectedDateRange = weekRange();

  //separate list is needed for filter
  Future<List<WorkoutHistory>?> _workoutHistory =
      _workoutHistoryByDates(weekRange());

  //list of all saved workouts
  final Future<List<Workout>?> _workouts = _readAllWorkouts();

  //list for populating Routine Dropdown Filter
  final Future<List<Routine>?> _routineDropdown = _readAllRoutinesDropdown();

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
      saveText: 'Done',
    );

    if (result != null) {
      var dropdownList = await _routineDropdown;
      setState(() {
        _selectedDateRange = result;
        // -1 is the ID for all, so do not filter if that is the case
        if (dropdownList![filterIndex].id == -1) {
          _workoutHistory = _workoutHistoryByDates(result);
        } else {
          _workoutHistory = _workoutHistoryByRoutineAndDates(
              dropdownList[filterIndex].id, result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //if you navigated from the profile, pre filter the history by the id and range
    if (workout != null) {
      _workoutHistory =
          _workoutHistoryByWorkoutAndDates(workout!.id, _selectedDateRange!);
    }

    //update the filtered list and the filtered index from the dropdown selection
    void dropdownFilter(int routineId) async {
      var routines = await _routineDropdown;
      setState(() {
        if (routineId == -1) {
          _workoutHistory = _workoutHistoryByDates(_selectedDateRange!);
        } else {
          _workoutHistory =
              _workoutHistoryByRoutineAndDates(routineId, _selectedDateRange!);
        }

        for (int i = 0; i < routines!.length; i++) {
          if (routineId == routines[i].id) {
            filterIndex = i;
          }
        }
      });
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

  Future<void> addWorkoutForm(BuildContext context, bool add,
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
    TextEditingController routineController = TextEditingController(
        text: workout != null ? workout!.name : workoutStrings[0]);
    TextEditingController weightController = TextEditingController(
        text: workoutHistory.weight == 0
            ? null
            : workoutHistory.weight.toString());
    TextEditingController timerController = TextEditingController(
        text:
            workoutHistory.timer == 0 ? null : workoutHistory.timer.toString());
    TextEditingController setController = TextEditingController(
        text: workoutHistory.sets == 0 ? null : workoutHistory.sets.toString());
    TextEditingController repController = TextEditingController(
        text: workoutHistory.reps == 0 ? null : workoutHistory.reps.toString());
    DateTime myDateTime =
        add ? DateTime.now() : DateTime.parse(workoutHistory.date);
    TextEditingController dateController = TextEditingController(
        text: DateFormat('yyyy/MM/dd').format(myDateTime));

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
                                          mostRecentWorkoutHistory.timer
                                              .toString();
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
                                    routineController.text = newValue!;
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
                          return value!.isNotEmpty ? null : "Empty";
                        },
                        decoration: const InputDecoration(
                            hintText: "Weight", labelText: "Weight *"),
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
                        controller: timerController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : "Empty";
                        },
                        decoration: const InputDecoration(
                            hintText: "Duration", labelText: "Duration *"),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: curWorkout.type == WorkoutType.strength.index,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 50,
                              child: TextFormField(
                                controller: setController,
                                validator: (value) {
                                  return value!.isNotEmpty ? null : "Empty";
                                },
                                decoration: const InputDecoration(
                                    hintText: "Sets", labelText: "Sets *"),
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
                                  return value!.isNotEmpty ? null : "Empty";
                                },
                                decoration: const InputDecoration(
                                    hintText: "Reps", labelText: "Reps *"),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                ],
                              ),
                            ),
                          ]),
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
                      workoutHistory.workoutName = routineController.text;
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
                      workoutHistory.timer = double.parse(
                          timerController.text.isEmpty
                              ? "0"
                              : timerController.text);
                      _updateWorkoutHistory(workoutHistory);
                    } else {
                      //on add, get relevant info from the dropdown selection
                      int workoutId = -1;
                      int workoutType = -1;
                      for (var i = 0; i < workouts.length; i++) {
                        if (workouts[i].name == routineController.text) {
                          workoutId = workouts[i].id;
                          workoutType = workouts[i].type;
                        }
                      }
                      _saveWorkoutHistory(
                          routineController.text,
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
                          double.parse(timerController.text.isEmpty
                              ? "0"
                              : timerController.text),
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

  Widget buildWorkoutCard(BuildContext context, workoutHistory, workout) {
    WorkoutType? type;
    for (var i = 0; i < workout.length; i++) {
      if (workoutHistory.workoutId == workout[i].id) {
        type = WorkoutType.values[workout[i].type];
        log(workoutTypeString(type));
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
            child: ListTile(
              onTap: () async {
                await addWorkoutForm(context, false, workoutHistory, true);
              },
              onLongPress: () async {
                await _deleteWorkoutHistory(workoutHistory.id);
                setState(() {
                  _workoutHistory = _readAllWorkoutHistory();
                });
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
                          DateFormat('yyyy/MM/dd')
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
                        Text('${workoutHistory.weight.toString()} LBS'),
                        const Spacer(),
                        Text('${workoutHistory.sets.toString()} Sets '),
                        const Spacer(),
                        Text('${workoutHistory.reps.toString()} Reps'),
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
                await addWorkoutForm(context, false, workoutHistory, true);
              },
              onLongPress: () async {
                await _deleteWorkoutHistory(workoutHistory.id);
                setState(() {
                  _workoutHistory = _readAllWorkoutHistory();
                });
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
                          DateFormat('yyyy/MM/dd')
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Duration: ${workoutHistory.timer.toString()}'),
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
                await addWorkoutForm(context, false, workoutHistory, true);
              },
              onLongPress: () async {
                await _deleteWorkoutHistory(workoutHistory.id);
                setState(() {
                  _workoutHistory = _readAllWorkoutHistory();
                });
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
                          DateFormat('yyyy/MM/dd')
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
                        Text('Duration: ${workoutHistory.timer.toString()}'),
                        const Spacer(),
                        Text('${workoutHistory.weight.toString()} LBS'),
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

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key}) : super(key: key);
  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<List<Workout>?> workouts = _readAllWorkouts();

  //needed for name duplicate validation
  bool inAsyncCall = false;
  bool isInvalidName = false;

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FutureBuilder<List<Workout>?>(
              future: workouts,
              builder: (context, projectSnap) {
                if (projectSnap.hasData) {
                  return Column(children: [
                    //search bar to filter list by name
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: "Search",
                        hintText: "Workout Name",
                        prefixIcon: Icon(UniconsLine.search),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (value) async {
                        setState(() {
                            workouts = _readAllWorkoutsNameSearch(value.toLowerCase());
                        });
                      },
                    ),

                    //list of workouts
                    Expanded(
                      child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: projectSnap.data?.length,
                          itemBuilder: (BuildContext context, int index) =>
                              buildWorkoutCard(
                                  context, index, projectSnap.data)),
                    ),
                  ]);
                } else {
                  return const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'No Workouts',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Workout workout = Workout();
          workout.name = "";
          workout.type = 1;
          await addWorkoutForm(
              context, true, false, WorkoutType.strength.index, workout);
        },
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }

  //get string for validation message
  String? nameValidator(String? name) {
    if (name!.isEmpty) {
      return "Empty";
    }

    if (isInvalidName) {
      isInvalidName = false;
      return "duplicate name $name";
    }

    return null;
  }

  Future<void> addWorkoutForm(BuildContext context, bool add, bool lock,
      int typeIndex, Workout type) async {
    //default the name
    TextEditingController typeController =
        TextEditingController(text: type.name);

    //default a workout type
    int? typeIndexController = typeIndex;

    return await showDialog(
      context: context,
      builder: (context) {
        //widget for name duplicate validation
        return ModalProgressHUD(
          opacity: .5,
          progressIndicator: const CircularProgressIndicator(),
          inAsyncCall: inAsyncCall,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: StatefulBuilder(builder: (context, setNewState) {
              _formKey.currentState?.validate();
              return AlertDialog(
                scrollable: true,
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //name field with validations
                      TextFormField(
                        controller: typeController,
                        validator: nameValidator,
                        decoration: const InputDecoration(hintText: "Workout"),
                      ),

                      //radio buttons to set workout type. Locked if updating
                      RadioListTile<int>(
                        value: WorkoutType.strength.index,
                        groupValue: typeIndexController,
                        title: const Text("Strength"),
                        onChanged: lock
                            ? null
                            : (value) {
                                setNewState(() {
                                  typeIndexController =
                                      WorkoutType.strength.index;
                                  log(typeIndexController.toString());
                                });
                              },
                        activeColor: Colors.green,
                        toggleable: true,
                      ),
                      RadioListTile<int>(
                        value: WorkoutType.cardio.index,
                        groupValue: typeIndexController,
                        title: const Text("Cardio"),
                        onChanged: lock
                            ? null
                            : (value) {
                                setNewState(() {
                                  typeIndexController =
                                      WorkoutType.cardio.index;
                                  log(typeIndexController.toString());
                                });
                              },
                        activeColor: Colors.green,
                        toggleable: true,
                      ),
                      RadioListTile<int>(
                        value: WorkoutType.both.index,
                        groupValue: typeIndexController,
                        title: const Text("Both"),
                        onChanged: lock
                            ? null
                            : (value) {
                                setNewState(() {
                                  typeIndexController = WorkoutType.both.index;
                                  log(typeIndexController.toString());
                                });
                              },
                        activeColor: Colors.green,
                        toggleable: true,
                      ),
                    ],
                  ),
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
                      //verify and commit the validation changes on save
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        //when this is true, we wait for name duplicate validation
                        setNewState(() {
                          inAsyncCall = true;
                        });

                        // dismiss keyboard during async call
                        FocusScope.of(context).requestFocus(new FocusNode());

                        bool isDupe =
                            await _workoutNameExists(typeController.text);

                        //finish validation and exit async call
                        setNewState(() {
                          if (isDupe) {
                            isInvalidName = true;
                          } else {
                            isInvalidName = false;
                          }
                          inAsyncCall = false;
                        });
                        if (!isInvalidName) {
                          if (!add) {
                            type.name = typeController.text;
                            type.type = typeIndexController!;
                            _updateWorkout(type);
                            _updateWorkoutHistoryByWorkout(
                                type.id, typeController.text);
                          } else {
                            _saveWorkout(
                              typeController.text,
                              typeIndexController!,
                            );
                          }
                          setState(() {
                            workouts = _readAllWorkouts();
                          });

                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: const Text("Save"),
                  )
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Future<void> cantDeleteAlert() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Can Not Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This workout has history.'),
                Text('Please delete all history and remove from all routines before deleting workouts.'),
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

  //update and delete are both on long press
  Future<void> updateOptions(Workout workout) {
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
                    List<WorkoutHistory>? workoutsForType =
                        await _workoutHistoryByWorkout(workout.id);
                    if (workoutsForType == null) {
                      await addWorkoutForm(
                          context, false, false, workout.type, workout);
                    } else {
                      await addWorkoutForm(
                          context, false, true, workout.type, workout);
                    }
                  },
                ),
                const Divider(),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    List<WorkoutHistory>? historyForWorkout =
                        await _workoutHistoryByWorkout(workout.id);

                    List<RoutineEntry>? routineEntriesForWorkout =
                        await _routineEntryByWorkout(workout.id);
                    if (historyForWorkout == null && routineEntriesForWorkout == null) {
                      await _deleteWorkout(workout.id);
                    } else {
                      return cantDeleteAlert();
                    }
                    setState(() {
                      workouts = _readAllWorkouts();
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

  Widget buildWorkoutCard(BuildContext context, int index, workouts) {
    return Container(
      margin: const EdgeInsets.all(0),
      //height: 42,
      child: Card(
        child: ListTile(
          //navigate to profile on tap
          onTap: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        WorkoutProfile(workout: workouts![index])));
          },
          onLongPress: () async {
            return updateOptions(workouts[index]);
          },
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('${workouts![index].name} '),
                    const Spacer(),
                    Text(workoutTypeString(
                        WorkoutType.values[workouts![index].type]))
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

class WorkoutProfile extends StatefulWidget {
  final Workout workout;
  const WorkoutProfile({Key? key, required this.workout}) : super(key: key);

  @override
  State<WorkoutProfile> createState() =>
      _WorkoutProfileState(workout: this.workout);
}

class _WorkoutProfileState extends State<WorkoutProfile> {
  late Workout workout;
  _WorkoutProfileState({required this.workout});

  DateTimeRange dateTimeRange = weekRange();
  @override
  Widget build(BuildContext context) {
    log("current workout is ${workout.name}");
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            workout.name,
            textAlign: TextAlign.center,
          ),
          bottom: const TabBar(tabs: <Widget>[
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
            WorkoutGraphs(workout: workout)
          ],
        ),
      ),
    );
  }
}

class RoutinePage extends StatefulWidget {
  const RoutinePage({Key? key}) : super(key: key);

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //also need a duplicate name validation for routines
  Future<List<Routine>?> routines = _readAllRoutines();
  bool inAsyncCall = false;
  bool isInvalidName = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FutureBuilder<List<Routine>?>(
              future: routines,
              builder: (context, projectSnap) {
                if (projectSnap.hasData) {
                  return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: projectSnap.data?.length,
                      itemBuilder: (BuildContext context, int index) =>
                          buildRoutineCard(context, index, projectSnap.data));
                } else {
                  return const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'No Routines',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Navigator.push( context, MaterialPageRoute( builder: (context) => Workout()), ).then((value) => setState(() {}));
          Routine routine = Routine();
          routine.name = "";
          routine.date = DateTime.now().toString();
          await addRoutineForm(context, true, routine);
        },
        tooltip: 'Add Routine',
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }

  //get string for name validation text
  String? nameValidator(String? name) {
    if (name!.isEmpty) {
      return "Empty";
    }

    if (isInvalidName) {
      isInvalidName = false;
      return "duplicate name $name";
    }

    return null;
  }

  Future<void> addRoutineForm(
      BuildContext context, bool add, Routine routine) async {
    TextEditingController routineController =
        TextEditingController(text: routine.name);
    return await showDialog(
      context: context,
      builder: (context) {
        return ModalProgressHUD(
          opacity: .5,
          progressIndicator: const CircularProgressIndicator(),
          inAsyncCall: inAsyncCall,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: StatefulBuilder(builder: (context, setNewState) {
              _formKey.currentState?.validate();
              return AlertDialog(
                scrollable: true,
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: routineController,
                        validator: nameValidator,
                        decoration: const InputDecoration(hintText: "Routine"),
                      ),
                    ],
                  ),
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
                      //set the async flag to check for duplicate names
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        setNewState(() {
                          inAsyncCall = true;
                        });
                        // dismiss keyboard during async call
                        FocusScope.of(context).requestFocus(new FocusNode());

                        bool isDupe =
                            await _routineNameExists(routineController.text);

                        //finish duplicate check and end the async call
                        setNewState(() {
                          if (isDupe) {
                            isInvalidName = true;
                          } else {
                            isInvalidName = false;
                          }
                          inAsyncCall = false;
                        });
                        if (!isInvalidName) {
                          if (!add) {
                            routine.name = routineController.text;
                            routine.date = DateTime.now().toString();
                            _updateRoutine(routine);
                          } else {
                            //set datetime of routine to 0 if it has never been used
                            _saveRoutine(
                              routineController.text,
                              DateTime(0),
                            );
                          }
                          setState(() {
                            routines = _readAllRoutines();
                          });
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: const Text("Save"),
                  )
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Future<void> updateOptions(Routine routine) {
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
                    addRoutineForm(context, false, routine);
                  },
                ),
                const Divider(),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () async {
                    Navigator.of(context).pop();

                    //delete routine and all entries
                    var allEntries = await _routineEntryByRoutine(routine.id);
                    for (var element in allEntries!) {
                      _deleteRoutineEntry(element.id);
                    }
                    _deleteRoutine(routine.id);
                    setState(() {
                      routines = _readAllRoutines();
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

  Widget buildRoutineCard(BuildContext context, int index, curRoutines) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Card(
        child: ListTile(
          //on tap open the routine profile
          onTap: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        RoutineProfile(routine: curRoutines![index])));
          },
          onLongPress: () async {
            return updateOptions(curRoutines[index]);
          },
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('${curRoutines![index].name} '),
                    const Spacer(),
                    Text(
                      DateTime.parse(curRoutines![index].date) == DateTime(0)
                          ? 'Never Ran'
                          : 'last completed on ${DateFormat('yyyy/MM/dd') // hh:mm a
                              .format(DateTime.parse(curRoutines![index].date))} ',
                      style: const TextStyle(fontSize: 10),
                    )
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

  //need multiple forms to validate each workout separately
  List<GlobalKey<FormState>> formKeys = [];

  //used to hide the fields when each card is done
  List<bool> cardsCompleted = [];

  late Future<List<Workout>?> workouts;

  Widget orderedWorkoutList() {
    Future<List<RoutineEntry>?> routineEntries =
        _routineEntryByRoutine(routine.id);
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
                          _deleteRoutineEntry(item.id);
                          for (var element in snapshot.data!) {
                            element.order = snapshot.data!.indexOf(element);
                            _updateRoutineEntry(element);
                          }
                          routineEntries = _routineEntryByRoutine(routine.id);
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
                      _updateRoutineEntry(element);
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
    List<Workout>? workouts = await _readAllWorkouts();
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
                    var temp = await _routineEntryByRoutine(routine.id);
                    if (temp == null) {
                      _saveRoutineEntry(
                          workout.name, workout.id, routine.id, 0);
                    } else {
                      _saveRoutineEntry(
                          workout.name, workout.id, routine.id, temp.length);
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

  Widget executeWorkoutEntries(BuildContext context) {
    workouts = _workoutsByRoutine(routine.id);
    formKeys = [];
    cardsCompleted = [];

    //get the workouts from the entries in order, then construct a list of execute workout cards
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          routine.name,
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FutureBuilder<List<Workout>?>(
              future: workouts,
              builder: (context, projectSnap) {
                if (projectSnap.hasData) {
                  for (int i = 0; i < projectSnap.data!.length; i++) {
                    formKeys.add(GlobalKey<FormState>());
                    cardsCompleted.add(false);
                  }
                  return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 10, top: 10),
                      itemCount: projectSnap.data?.length,
                      itemBuilder: (BuildContext context, int index) =>
                          executeWorkoutCard(projectSnap.data![index], index));
                } else {
                  return const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'No Workouts for this Routine',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget executeWorkoutCard(Workout workout, int index) {
    TextEditingController weightController = TextEditingController();
    TextEditingController timerController = TextEditingController();
    TextEditingController setController = TextEditingController();
    TextEditingController repController = TextEditingController();

    //use similar logic to workout history page to validate the card and display the fields
    Future<WorkoutHistory?> recentHistory =
        _mostRecentWorkoutHistoryByWorkout(workout.id);
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return FutureBuilder<WorkoutHistory?>(
        future: recentHistory,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            weightController.text = snapshot.data!.weight.toString();
            timerController.text = snapshot.data!.timer.toString();
            setController.text = snapshot.data!.sets.toString();
            repController.text = snapshot.data!.reps.toString();
          } else {
            weightController.text = "";
            timerController.text = "";
            setController.text = "";
            repController.text = "";
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
                        return value!.isNotEmpty ? null : "Empty";
                      },
                      decoration: const InputDecoration(
                          hintText: "Weight", labelText: "Weight *"),
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
                      controller: timerController,
                      validator: (value) {
                        return value!.isNotEmpty ? null : "Empty";
                      },
                      decoration: const InputDecoration(
                          hintText: "Duration", labelText: "Duration *"),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: workout.type == WorkoutType.strength.index &&
                        !cardsCompleted[index],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 50,
                          child: TextFormField(
                            controller: setController,
                            validator: (value) {
                              return value!.isNotEmpty ? null : "Empty";
                            },
                            decoration: const InputDecoration(
                                hintText: "Sets", labelText: "Sets *"),
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
                              return value!.isNotEmpty ? null : "Empty";
                            },
                            decoration: const InputDecoration(
                                hintText: "Reps", labelText: "Reps *"),
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
                    visible: !cardsCompleted[index],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (formKeys[index].currentState!.validate()) {
                              _saveWorkoutHistory(
                                  workout.name,
                                  workout.type,
                                  DateTime.now(),
                                  int.parse(setController.text.isEmpty
                                      ? "0"
                                      : setController.text),
                                  int.parse(repController.text.isEmpty
                                      ? "0"
                                      : repController.text),
                                  double.parse(weightController.text.isEmpty
                                      ? "0"
                                      : weightController.text),
                                  double.parse(timerController.text.isEmpty
                                      ? "0"
                                      : timerController.text),
                                  workout.id);

                              var newRoutine = routine;
                              newRoutine.date = DateTime.now().toString();
                              _updateRoutine(newRoutine);
                              setState(() {
                                cardsCompleted[index] = true;
                                workouts = _workoutsByRoutine(routine.id);
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => executeWorkoutEntries(context)));
              },
              icon: const Icon(UniconsLine.play))
        ],
      ),
      body: orderedWorkoutList(),
    );
  }
}

class WorkoutGraphs extends StatefulWidget {
  final Workout workout;
  const WorkoutGraphs({Key? key, required this.workout}) : super(key: key);

  @override
  State<WorkoutGraphs> createState() =>
      _WorkoutGraphsState(workout: this.workout);
}

class _WorkoutGraphsState extends State<WorkoutGraphs> {
  late Workout workout;
  late Future<List<WorkoutHistory>?> workoutHistory;
  DateTimeRange _selectedDateRange = weekRange();
  _WorkoutGraphsState({required this.workout});

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

        workoutHistory =
            _workoutHistoryByWorkoutAndDates(workout.id, _selectedDateRange);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (workout != null) {
      workoutHistory =
          _workoutHistoryByWorkoutAndDates(workout.id, _selectedDateRange);
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
              if (projectSnap.hasData && graphs != null) {
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
}

Widget? _graphFeaturesByWorkoutAndDate(
    List<WorkoutHistory>? workoutHistory, BuildContext context) {

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

    //same process for each workout type, using different workout history attributes
    switch (type) {
      case WorkoutType.strength:

        //values for each attribute to graph
        List<double> dataWeight = [];
        List<double> dataSet = [];
        List<double> dataRep = [];

        //graph only goes fromm 0-1 so we need to use fractions with the max values
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
        }

        features
            .add(Feature(title: "Weight", color: Colors.red, data: dataWeight));
        features
            .add(Feature(title: "Sets", color: Colors.green, data: dataSet));
        features
            .add(Feature(title: "Reps", color: Colors.purple, data: dataRep));

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
                    size: Size(graphWidth, 400),
                    labelX: dates,
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
            workoutHistory.reduce((a, b) => a.timer > b.timer ? a : b).timer;
        for (var history in workoutHistory) {
          dataDuration.add(history.timer / highestDuration);

          dates.add(DateFormat("MM/dd").format(DateTime.parse(history.date)));
        }
        features.add(
            Feature(title: "Duration", color: Colors.blue, data: dataDuration));
        return SingleChildScrollView(
          child: Column(children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Max Duration $highestDuration "),
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
                      (highestDuration / 2).round().toString(),
                      highestDuration.round().toString()
                    ],
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
        List<double> dataDuration = [];
        double highestWeight =
            workoutHistory.reduce((a, b) => a.weight > b.weight ? a : b).weight;
        double highestDuration =
            workoutHistory.reduce((a, b) => a.timer > b.timer ? a : b).timer;
        for (var history in workoutHistory) {
          dataWeight.add(history.weight / highestWeight);
          dataDuration.add(history.timer / highestDuration);

          dates.add(DateFormat("MM/dd").format(DateTime.parse(history.date)));
        }
        features
            .add(Feature(title: "Weight", color: Colors.red, data: dataWeight));
        features.add(
            Feature(title: "Duration", color: Colors.blue, data: dataDuration));
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
                child: Text("Max Duration $highestDuration"),
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
                      (highestDuration / 2).round().toString(),
                      highestDuration.round().toString()
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
                    size: Size(graphWidth, 400),
                    labelX: dates,
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

_saveWorkout(String workout, int wRequired) async {
  Workout wType = Workout();
  wType.name = workout;
  wType.type = wRequired;
  DatabaseHelper helper = DatabaseHelper.instance;
  int id = await helper.insertWorkout(wType);
  wType.id = id;

  log('inserted row: $id');
}

_deleteWorkout(int _id) async {
  DatabaseHelper helper = DatabaseHelper.instance;

  int id = await helper.deleteWorkout(_id);

  log('deleted row: $id');
}

_updateWorkout(Workout workout) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  log('updating row: ${workout.id.toString()}');
  int id = await helper.updateWorkout(workout);

  log('updated row: $id');
}

Future<bool> _workoutNameExists(String name) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<Workout>? workouts = await helper.queryAllWorkouts();
  if (workouts != null) {
    for (var workout in workouts) {
      if (workout.name.toLowerCase() == name.toLowerCase()) {
        return true;
      }
    }
    return false;
  } else {
    return false;
  }
}

Future<bool> _routineNameExists(String name) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<Routine>? routines = await helper.queryAllRoutines();
  if (routines != null) {
    for (var routine in routines) {
      if (routine.name.toLowerCase() == name.toLowerCase()) {
        return true;
      }
    }
    return false;
  } else {
    return false;
  }
}

Future<Workout?> _readWorkout(int rowId) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  Workout? workout = await helper.queryWorkout(rowId);
  if (workout == null) {
    log('read row $rowId: empty');
    return null;
  } else {
    log('read row $rowId: ${workout.name}');
    return workout;
  }
}

Future<List<Workout>?> _readAllWorkouts() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<Workout>? workouts = await helper.queryAllWorkouts();
  if (workouts == null) {
    log('read row empty');
    return null;
  } else {
    log('read row: $workouts');
    workouts.sort((a, b) => a.name.compareTo(b.name));
    return workouts;
  }
}

Future<List<Workout>?> _readAllWorkoutsNameSearch(String search) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<Workout>? workouts = await helper.queryAllWorkouts();
  if (workouts == null) {
    log('read row empty');
    return null;
  } else {
    log('read row: $workouts');
    List<Workout> filteredWorkouts =
        workouts.where((element) => element.name.toLowerCase().contains(search)).toList();
    filteredWorkouts.sort((a, b) => a.name.compareTo(b.name));
    return filteredWorkouts;
  }
}

_saveRoutine(String name, DateTime date) async {
  Routine routine = Routine();
  routine.name = name;
  routine.date = date.toString();
  DatabaseHelper helper = DatabaseHelper.instance;
  int id = await helper.insertRoutine(routine);
  routine.id = id;

  log('inserted row: $id');
}

_deleteRoutine(int _id) async {
  DatabaseHelper helper = DatabaseHelper.instance;

  int id = await helper.deleteRoutine(_id);

  log('deleted row: $id');
}

_updateRoutine(Routine routine) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  log('updating row: ${routine.id.toString()}');
  int id = await helper.updateRoutine(routine);

  log('updated row: $id');
}

Future<List<Routine>?> _readAllRoutines() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<Routine>? routines = await helper.queryAllRoutines();
  if (routines == null) {
    log('read row empty');
    return null;
  } else {
    log('read row: $routines');
    routines.sort((a, b) => a.name.compareTo(b.name));
    return routines;
  }
}

_saveRoutineEntry(
    String workoutName, int workoutId, int routineId, int order) async {
  RoutineEntry routineEntry = RoutineEntry();
  routineEntry.workoutName = workoutName;
  routineEntry.workoutId = workoutId;
  routineEntry.routineId = routineId;
  routineEntry.order = order;
  DatabaseHelper helper = DatabaseHelper.instance;
  int id = await helper.insertRoutineEntry(routineEntry);
  routineEntry.id = id;

  log('inserted row: $id');
}

_deleteRoutineEntry(int _id) async {
  DatabaseHelper helper = DatabaseHelper.instance;

  int id = await helper.deleteRoutineEntry(_id);

  log('deleted row: $id');
}

_updateRoutineEntry(RoutineEntry routineEntry) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  log('updating row: ${routineEntry.id.toString()}');
  int id = await helper.updateRoutineEntry(routineEntry);

  log('updated row: $id');
}

Future<List<RoutineEntry>?> _routineEntryByRoutine(int id) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<RoutineEntry>? workouts = await helper.queryRoutineEntriesByRoutine(id);
  if (workouts == null) {
    log('read row $id: empty');
    return null;
  } else {
    log('read row $id: $workouts');
    workouts.sort((a, b) => a.order.compareTo(b.order));
    return workouts;
  }
}

Future<List<RoutineEntry>?> _routineEntryByWorkout(int id) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<RoutineEntry>? workouts = await helper.queryRoutineEntriesByWorkout(id);
  if (workouts == null) {
    log('read row $id: empty');
    return null;
  } else {
    log('read row $id: $workouts');
    workouts.sort((a, b) => a.order.compareTo(b.order));
    return workouts;
  }
}

Future<List<Workout>?> _workoutsByRoutine(int id) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<RoutineEntry>? entries = await helper.queryRoutineEntriesByRoutine(id);
  if (entries == null) {
    log('read row $id: empty');
    return null;
  } else {
    log('read row $id: $entries');
    entries.sort((a, b) => a.order.compareTo(b.order));
    List<Workout>? workouts = [];
    for (var element in entries) {
      workouts.add((await _readWorkout(element.workoutId))!);
    }
    return workouts;
  }
}

Future<List<Workout>?> _readAllWorkoutsDropdown() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  int rowId = 1;
  List<Workout>? workouts = await helper.queryAllWorkouts();
  if (workouts == null) {
    log('read row $rowId: empty');
    return null;
  } else {
    log('read row $rowId: $workouts');
    Workout add = Workout();
    add.id = -1;
    add.name = "All";
    add.type = 1;
    workouts.sort((a, b) => a.name.compareTo(b.name));
    workouts.insert(0, add);
    return workouts;
  }
}

Future<List<Routine>?> _readAllRoutinesDropdown() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  int rowId = 1;
  List<Routine>? routines = await helper.queryAllRoutines();
  if (routines == null) {
    log('read row $rowId: empty');
    return null;
  } else {
    log('read row $rowId: $routines');
    Routine add = Routine();
    add.id = -1;
    add.name = "All";
    add.date = DateTime.now().toString();
    routines.sort((a, b) => a.name.compareTo(b.name));
    routines.insert(0, add);
    return routines;
  }
}

_saveWorkoutHistory(String workoutName, int type, DateTime date, int sets,
    int reps, double weight, double timer, int workoutId) async {
  WorkoutHistory workout = WorkoutHistory();
  workout.workoutName = workoutName;
  workout.workoutType = type;
  workout.date = date.toString();
  workout.sets = sets;
  workout.reps = reps;
  workout.weight = weight;
  workout.timer = timer;
  workout.workoutId = workoutId;

  DatabaseHelper helper = DatabaseHelper.instance;

  int id = await helper.insertWorkoutHistory(workout);
  workout.id = id;

  log('inserted row: $id');
}

_deleteWorkoutHistory(int _id) async {
  DatabaseHelper helper = DatabaseHelper.instance;

  int id = await helper.deleteWorkoutHistory(_id);

  log('deleted row: $id');
}

_updateWorkoutHistory(WorkoutHistory workout) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  log('updating row: ${workout.id.toString()}');
  int id = await helper.updateWorkoutHistory(workout);

  log('updated row: $id');
}

Future<List<WorkoutHistory>?> _readAllWorkoutHistory() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  int rowId = 1;
  List<WorkoutHistory>? workouts = await helper.queryAllWorkoutHistory();
  if (workouts == null) {
    log('read row $rowId: empty');
    return null;
  } else {
    log('read row $rowId: $workouts');
    workouts.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    return workouts;
  }
}

Future<List<WorkoutHistory>?> _workoutHistoryByWorkout(int id) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<WorkoutHistory>? workouts =
      await helper.queryWorkoutHistoryByWorkout(id);
  if (workouts == null) {
    log('read row $id: empty');
    return null;
  } else {
    log('read row $id: $workouts');
    workouts.sort((a, b) {
      return a.date.compareTo(b.date);
    });
    return workouts;
  }
}

Future<WorkoutHistory?> _mostRecentWorkoutHistoryByWorkout(int id) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<WorkoutHistory>? workouts =
      await helper.queryWorkoutHistoryByWorkout(id);
  if (workouts == null) {
    log('read row $id: empty');
    return null;
  } else {
    log('read row $id: $workouts');
    workouts.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    return workouts[0];
  }
}

Future<List<WorkoutHistory>?> _workoutHistoryByWorkoutAndDates(
    int id, DateTimeRange range) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<WorkoutHistory>? workouts =
      await helper.queryWorkoutHistoryByWorkout(id);
  if (workouts == null) {
    log('read row $id: empty');
    return null;
  } else {
    log('read row $id: $workouts');
    List<WorkoutHistory>? workoutsInRange = [];
    log(workouts.length.toString());
    for (var value in workouts) {
      DateTime curDay = DateTime.parse(value.date);
      if (range.start.isBefore(curDay) && range.end.isAfter(curDay) ||
          datesEqual(range.start, curDay) ||
          datesEqual(range.end, curDay)) {
        workoutsInRange.add(value);
        log("added ${value.workoutName} from ${value.date}");
      } else {
        log("skipped ${value.workoutName} from ${value.date}");
      }
    }
    workoutsInRange.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    return workoutsInRange;
  }
}

Future<List<WorkoutHistory>?> _workoutHistoryByDates(
    DateTimeRange range) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<WorkoutHistory>? workouts = await helper.queryAllWorkoutHistory();
  if (workouts == null) {
    return null;
  } else {
    List<WorkoutHistory>? workoutsInRange = [];
    for (var value in workouts) {
      DateTime curDay = DateTime.parse(value.date);
      if (range.start.isBefore(curDay) && range.end.isAfter(curDay) ||
          datesEqual(range.start, curDay) ||
          datesEqual(range.end, curDay)) {
        workoutsInRange.add(value);
      }
    }
    workoutsInRange.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    return workoutsInRange;
  }
}

Future<List<WorkoutHistory>?> _workoutHistoryByRoutineAndDates(
    int id, DateTimeRange range) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<Workout>? workouts = await _workoutsByRoutine(id);

  List<WorkoutHistory>? allWorkoutHistory = [];

  if (workouts == null) {
    log('read row $id: empty');
    return null;
  } else {
    for (var workout in workouts) {
      List<WorkoutHistory>? tempHistory =
          await _workoutHistoryByWorkoutAndDates(workout.id, range);
      if (tempHistory != null) {
        allWorkoutHistory.addAll(tempHistory);
      }
    }
  }

  if (allWorkoutHistory.isEmpty) {
    log('read row $id: empty');
    return null;
  } else {
    log('read row $id: $allWorkoutHistory');
    List<WorkoutHistory>? workoutsInRange = [];
    log(allWorkoutHistory.length.toString());
    for (var value in allWorkoutHistory) {
      DateTime curDay = DateTime.parse(value.date);
      if (range.start.isBefore(curDay) && range.end.isAfter(curDay) ||
          datesEqual(range.start, curDay) ||
          datesEqual(range.end, curDay)) {
        workoutsInRange.add(value);
        log("added ${value.workoutName} from ${value.date}");
      } else {
        log("skipped ${value.workoutName} from ${value.date}");
      }
    }
    workoutsInRange.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    return workoutsInRange;
  }
}

Future<List<WorkoutHistory>?> _updateWorkoutHistoryByWorkout(
    int id, String workoutName) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<WorkoutHistory>? workouts =
      await helper.queryWorkoutHistoryByWorkout(id);
  if (workouts == null) {
    log('read row $id: empty');
    return null;
  } else {
    log('read row $id: $workouts');
    for (var element in workouts) {
      var tempWorkout = element;
      tempWorkout.workoutName = workoutName;
      int id = await helper.updateWorkoutHistory(tempWorkout);
      log('update row $id');
    }
    return workouts;
  }
}

DateTimeRange todayRange() {
  DateTime now = DateTime.now();
  DateTime dateStart = DateTime(now.year, now.month, now.day);
  DateTime dateEnd = DateTime(now.year, now.month, now.day);
  return DateTimeRange(start: dateStart, end: dateEnd);
}

DateTimeRange weekRange() {
  DateTime now = DateTime.now();
  DateTime dateStart = DateTime(now.year, now.month, now.day - 7);
  DateTime dateEnd = DateTime(now.year, now.month, now.day);
  return DateTimeRange(start: dateStart, end: dateEnd);
}

bool datesEqual(DateTime one, DateTime two) {
  return one.year == two.year && one.month == two.month && one.day == two.day;
}
