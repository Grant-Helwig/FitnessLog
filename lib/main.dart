//import 'dart:html';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'color_themes.dart';
import 'database_helper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:draw_graph/draw_graph.dart';
import 'package:draw_graph/models/feature.dart';
//import 'package:mdi/mdi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Log',
      //themeMode: ThemeMode.dark,
      theme: ThemeData.dark(),
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
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _key = GlobalKey();

  //main page that has 3 tabs
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
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
            WorkoutHistoryPage(workout: null),
            WorkoutPage(),
            RoutinePage()
          ],
        ),
      ),
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
  late Workout? workout;
  _WorkoutHistoryPageState({required this.workout});

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //value for date range picker
  DateTimeRange? _selectedDateRange = todayRange();

  //list of all saved workout history
  Future<List<WorkoutHistory>?> workout_history_list = _readAllWorkoutHistory();

  //separate list is needed for filter
  Future<List<WorkoutHistory>?> workout_history_list_filtered =
      _workoutHistoryByDates(todayRange());

  //list of all saved workout types
  Future<List<Workout>?> workouts = _readAllWorkouts();

  //dropdown list is needed, adds an option for all
  Future<List<Workout>?> workout_dropdown = _readAllWorkoutsDropdown();

  //index for position in their lists
  int filter_index = 0;
  int workout_index = 0;

  //function to update the type index for the dropdown
  Future<int> updateWorkoutIndex(newValue) async {
    var workoutsList = await workouts;
    for (var i = 0; i < workoutsList!.length; i++) {
      if (newValue == workoutsList[i].name) {
        workout_index = i;
        log(i.toString());
        return i;
      }
    }
    return -1;
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
      // Rebuild the UI
      var dropdown_list = await workout_dropdown;
      setState(() {
        _selectedDateRange = result;
        if (dropdown_list![filter_index].id == -1) {
          workout_history_list_filtered = _workoutHistoryByDates(result);
        } else {
          workout_history_list_filtered = _workoutHistoryByWorkoutAndDates(
              dropdown_list[filter_index].id, result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //if you navigated from the profile, pre filter the history by the id and range
    if (workout != null) {
      workout_history_list_filtered =
          _workoutHistoryByWorkoutAndDates(workout!.id, _selectedDateRange!);
    }

    Future<List<WorkoutHistory>?> getList(List<WorkoutHistory>? temp) async {
      return temp;
    }

    //update the filtered list and the filtered index from the dropdown selection
    void dropdownFilter(int workoutId) async {
      // log(workoutId.toString());
      // Future<List<WorkoutHistory>?> results;
      // if (workoutId == -1) {
      //   results = _workoutsByDates(_selectedDateRange!);
      // } else {
      //   //construct a list to display with the matching keys
      //   results = Future<List<WorkoutHistory>?>.value();
      //   List<WorkoutHistory>? temp = [];
      //   await workout_history_list.then((value) {
      //     if (value != null) {
      //       for (var item in value) {
      //         if (item.typeId == workoutId) {
      //
      //           if(_selectedDateRange!.start.isBefore(DateTime.parse(item.date))
      //               && _selectedDateRange!.end.isAfter(DateTime.parse(item.date)) ||
      //               datesEqual(_selectedDateRange!.start, DateTime.parse(item.date)) ||
      //               datesEqual(_selectedDateRange!.end, DateTime.parse(item.date))){
      //             temp.add(item);
      //           }
      //         }
      //       }
      //     }
      //   });
      //   temp.forEach((element) {
      //     log(element.workoutName);
      //   });
      //   results = getList(temp);
      // }
      var types = await workout_dropdown;
      Future<List<WorkoutHistory>?> filteredHistory;
      if (workoutId == -1) {
        filteredHistory = _workoutHistoryByDates(_selectedDateRange!);
      } else {
        if (workout == null) {
        } else {
          filteredHistory = _workoutHistoryByWorkoutAndDates(
              workout!.id, _selectedDateRange!);
        }
      }
      //Future<List<WorkoutHistory>?> filtered_history =  _workoutsByTypeAndDates(workout!.id, _selectedDateRange!);
      //var new_list = await _workoutsByTypeAndDates(type!.id, _selectedDateRange!);
      // Refresh the UI
      setState(() {
        //workout_history_list_filtered = results;
        //workout_history_list_filtered = filtered_history;

        if (workoutId == -1) {
          workout_history_list_filtered =
              _workoutHistoryByDates(_selectedDateRange!);
        } else {
          workout_history_list_filtered =
              _workoutHistoryByWorkoutAndDates(workoutId, _selectedDateRange!);
        }

        for (int i = 0; i < types!.length; i++) {
          if (workoutId == types[i].id) {
            filter_index = i;
          }
        }
      });
    }

    Widget dropdownWidget() {
      return FutureBuilder<List<Workout>?>(
          future: workout_dropdown,
          builder: (context, projectSnap) {
            if (projectSnap.hasData) {
              return DropdownButton<String>(
                isExpanded: true,
                value: projectSnap.data![filter_index].name,
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 16,
                style: const TextStyle(color: Colors.white),
                underline: Container(
                  height: 2,
                  color: Colors.white,
                ),
                onChanged: (String? newValue) => dropdownFilter(projectSnap
                    .data!
                    .firstWhere((element) => element.name == newValue)
                    .id),
                items: projectSnap.data!
                    .map<DropdownMenuItem<String>>((Workout value) {
                  return DropdownMenuItem<String>(
                    value: value.name,
                    child: Text(value.name),
                  );
                }).toList(),
              );
            } else {
              return SizedBox.shrink();
            }
          });
    }

    return Scaffold(
      drawer: const Drawer(),
      body: Container(
          child: Column(
        children: [
          TextButton(
              onPressed: selectDates,
              child: Text(
                "${DateFormat('yyyy/MM/dd').format(_selectedDateRange!.start)} - "
                "${DateFormat('yyyy/MM/dd').format(_selectedDateRange!.end)}",
                style: TextStyle(color: Colors.grey, fontSize: 18),
              )),
          Divider(),
          if (workout == null) dropdownWidget(),
          Expanded(
              child: FutureBuilder<List<dynamic>?>(
                  //<List<WorkoutRoutine>?>
                  future:
                      Future.wait([workout_history_list_filtered, workouts]),
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
                  }))
        ],
      )),
      //when opening the add workout modal, an object is always needed
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<Workout>? types = await workouts;

          if (types != null) {
            WorkoutHistory workoutHistory = WorkoutHistory();
            workoutHistory.workoutName = "";
            workoutHistory.date = DateTime.now().toString();
            workoutHistory.sets = 0;
            workoutHistory.reps = 0;
            workoutHistory.weight = 0;
            workoutHistory.timer = 0;
            workoutHistory.workoutId = 0;
            workout_index = 0;
            if (workout == null) {
              WorkoutHistory? mostRecentWorkoutHistory =
                  await _mostRecentWorkoutHistoryByWorkout(types[0].id);
              if (mostRecentWorkoutHistory == null) {
                await AddWorkoutForm(context, true, workoutHistory, false);
              } else {
                await AddWorkoutForm(
                    context, true, mostRecentWorkoutHistory, false);
              }
            } else {
              WorkoutHistory? mostRecentWorkoutHistory =
                  await _mostRecentWorkoutHistoryByWorkout(workout!.id);
              if (mostRecentWorkoutHistory == null) {
                await AddWorkoutForm(context, true, workoutHistory, true);
              } else {
                await AddWorkoutForm(
                    context, true, mostRecentWorkoutHistory, true);
              }
            }
          } else {
            await noTypesAlert();
          }
        },
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }

  Future<void> noTypesAlert() {
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

  Future<void> AddWorkoutForm(BuildContext context, bool add,
      WorkoutHistory workoutHistory, bool hasContext) async {
    List<Workout>? types = await _readAllWorkouts();
    List<String> typesString = [];
    Workout curType = types![0];

    if (workout != null) {
      for (var i = 0; i < types.length; i++) {
        typesString.add(types[i].name);
        if (workout!.id == types[i].id) {
          workout_index = i;
        }
      }
      curType = workout!;
    } else {
      for (var i = 0; i < types.length; i++) {
        typesString.add(types[i].name);
        if (workoutHistory.workoutId == types[i].id) {
          workout_index = i;
          curType = types[i];
        }
      }
    }

    TextEditingController routineController = TextEditingController(
        text: workout != null ? workout!.name : typesString[0]);
    TextEditingController weightController =
        TextEditingController(text: workoutHistory.weight.toString());
    TextEditingController timerController =
        TextEditingController(text: workoutHistory.timer.toString());
    TextEditingController setController =
        TextEditingController(text: workoutHistory.sets.toString());
    TextEditingController repController =
        TextEditingController(text: workoutHistory.reps.toString());
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
                    FutureBuilder<List<Workout>?>(
                        future: workouts,
                        builder: (context, projectSnap) {
                          if (projectSnap.hasData) {
                            return IgnorePointer(
                              ignoring: !add || hasContext,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: projectSnap.data![workout_index].name,
                                icon: add
                                    ? Icon(Icons.arrow_drop_down)
                                    : Icon(null),
                                elevation: 16,
                                style: add
                                    ? TextStyle(color: Colors.white)
                                    : TextStyle(color: Colors.grey),
                                underline: Container(
                                  height: 2,
                                  color: Colors.white,
                                ),
                                onChanged: (String? newValue) async {
                                  int i = await updateWorkoutIndex(newValue);

                                  //gwt the most recent workout history for the new value
                                  WorkoutHistory? mostRecentWorkoutHistory =
                                      await _mostRecentWorkoutHistoryByWorkout(
                                          projectSnap.data![i].id);

                                  setState(() {
                                    //if there is history, update all of cnotroller values
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
                                    //UpdateIndex(newValue);
                                    curType = projectSnap.data![i];
                                    log(curType.name);
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
                    Visibility(
                      visible: curType.type == WorkoutType.strength.index ||
                          curType.type == WorkoutType.both.index,
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
                      visible: curType.type == WorkoutType.cardio.index ||
                          curType.type == WorkoutType.both.index,
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
                      visible: curType.type == WorkoutType.strength.index,
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
                  if (_formKey.currentState!.validate()) {
                    if (!add) {
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
                      int typeId = -1;
                      int workoutType = -1;
                      for (var i = 0; i < types.length; i++) {
                        if (types[i].name == routineController.text) {
                          typeId = types[i].id;
                          workoutType = types[i].type;
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
                          typeId);
                    }
                    setState(() {
                      workout_history_list_filtered = _workoutHistoryByDates(_selectedDateRange!);
                      workout_history_list = workout_history_list_filtered;
                      filter_index = 0;
                    });
                    Navigator.of(context).pop();
                    //(context as Element).reassemble();
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

  Widget buildWorkoutCard(BuildContext context, workoutHistory, types) {
    WorkoutType? cat = null;
    for (var i = 0; i < types.length; i++) {
      if (workoutHistory.workoutId == types[i].id) {
        cat = WorkoutType.values[types[i].type];
        log(workoutTypeString(cat));
      }
    }
    switch (cat) {
      case WorkoutType.strength:
        return Container(
          margin: const EdgeInsets.all(0),
          //height: 42,
          child: Card(
            child: ListTile(
              onTap: () async {
                await AddWorkoutForm(context, false, workoutHistory, true);
              },
              onLongPress: () async {
                await _deleteWorkoutHistory(workoutHistory.id);
                setState(() {
                  workout_history_list_filtered = _readAllWorkoutHistory();
                  workout_history_list = workout_history_list_filtered;
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
                          DateFormat('yyyy/MM/dd') // hh:mm a
                              .format(DateTime.parse(workoutHistory.date)),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Container(
                    child: Padding(
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
                  ),
                ],
              ),
            ),
          ),
        );
      case WorkoutType.cardio:
        return Container(
          margin: const EdgeInsets.all(0),
          //height: 42,
          child: Card(
            child: ListTile(
              onTap: () async {
                await AddWorkoutForm(context, false, workoutHistory, true);
              },
              onLongPress: () async {
                await _deleteWorkoutHistory(workoutHistory.id);
                setState(() {
                  workout_history_list_filtered = _readAllWorkoutHistory();
                  workout_history_list = workout_history_list_filtered;
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
                          DateFormat('yyyy/MM/dd') // hh:mm a
                              .format(DateTime.parse(workoutHistory.date)),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Duration: ${workoutHistory.timer.toString()}'),
                        ],
                      ),
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
          //height: 42,
          child: Card(
            child: ListTile(
              onTap: () async {
                await AddWorkoutForm(context, false, workoutHistory, true);
              },
              onLongPress: () async {
                await _deleteWorkoutHistory(workoutHistory.id);
                setState(() {
                  workout_history_list_filtered = _readAllWorkoutHistory();
                  workout_history_list = workout_history_list_filtered;
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
                          DateFormat('yyyy/MM/dd') // hh:mm a
                              .format(DateTime.parse(workoutHistory.date)),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text('Duration: ${workoutHistory.timer.toString()}'),
                          const Spacer(),
                          Text('${workoutHistory.weight.toString()} LBS'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
    return const SizedBox.shrink();
  }
}

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key}) : super(key: key);
  //Workout(key) : super(key: key);
  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  //List<WorkoutRoutine>? workouts =  _getAll();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<List<Workout>?> workouts = _readAllWorkouts();
  bool inAsyncCall = false;
  bool isInvalidName = false;

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //log(workouts!.length.toString());
    return Scaffold(
      drawer: const Drawer(),
      body: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FutureBuilder<List<Workout>?>(
              future: workouts,
              builder: (context, projectSnap) {
                if (projectSnap.hasData) {
                  return Column(children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: "Search",
                        hintText: "Workout Name",
                        prefixIcon: Icon(Icons.search),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (value) async {
                        var filteredWorkouts =
                            await _readAllWorkoutsNameSearch(value);
                        setState(() {
                          if (filteredWorkouts != null) {
                            workouts = _readAllWorkoutsNameSearch(value);
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: projectSnap.data?.length,
                          itemBuilder: (BuildContext context, int index) =>
                              buildTypeCard(context, index, projectSnap.data)),
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
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Navigator.push( context, MaterialPageRoute( builder: (context) => Workout()), ).then((value) => setState(() {}));
          Workout workout = Workout();
          workout.name = "";
          workout.type = 1;
          await AddTypeForm(
              context, true, false, WorkoutType.strength.index, workout);
        },
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget myRadioButton(TextEditingController radioController) {
    return Radio(
      value: radioController.text,
      groupValue: radioController.text,
      onChanged: (value) {
        setState(
          () {
            radioController.text = value.toString();
          },
        );
      },
    );
  }

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

  Future<void> AddTypeForm(BuildContext context, bool add, bool lock,
      int category, Workout type) async {
    TextEditingController typeController =
        TextEditingController(text: type.name);

    //run validators on reload

    // TextEditingController categoryController = TextEditingController(
    //     text: add ? "Yes" : (type.workoutEnum == 1 ? "Yes" : "No"));
    int? categoryController = category;
    return await showDialog(
      context: context,
      builder: (context) {
        return ModalProgressHUD(
          opacity: .5,
          progressIndicator: CircularProgressIndicator(),
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
                        controller: typeController,
                        validator: nameValidator,
                        decoration: const InputDecoration(hintText: "Workout"),
                      ),
                      RadioListTile<int>(
                        value: WorkoutType.strength.index,
                        groupValue: categoryController,
                        title: Text("Strength"),
                        onChanged: lock
                            ? null
                            : (value) {
                                setNewState(() {
                                  categoryController =
                                      WorkoutType.strength.index;
                                  log(categoryController.toString());
                                });
                              },
                        activeColor: Colors.green,
                        toggleable: true,
                      ),
                      RadioListTile<int>(
                        value: WorkoutType.cardio.index,
                        groupValue: categoryController,
                        title: Text("Cardio"),
                        onChanged: lock
                            ? null
                            : (value) {
                                setNewState(() {
                                  categoryController = WorkoutType.cardio.index;
                                  log(categoryController.toString());
                                });
                              },
                        activeColor: Colors.green,
                        toggleable: true,
                      ),
                      RadioListTile<int>(
                        value: WorkoutType.both.index,
                        groupValue: categoryController,
                        title: Text("Both"),
                        onChanged: lock
                            ? null
                            : (value) {
                                setNewState(() {
                                  categoryController = WorkoutType.both.index;
                                  log(categoryController.toString());
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
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        setNewState(() {
                          inAsyncCall = true;
                        });
                        // dismiss keyboard during async call
                        FocusScope.of(context).requestFocus(new FocusNode());

                        bool isDupe =
                            await _workoutNameExists(typeController.text);

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
                            type.type = categoryController!;
                            _updateWorkout(type);
                            _updateWorkoutHistoryByWorkout(
                                type.id, typeController.text);
                          } else {
                            _saveWorkout(
                              typeController.text,
                              categoryController!,
                            );
                          }
                          setState(() {
                            workouts = _readAllWorkouts();
                          });

                          Navigator.of(context).pop();
                        }

                        //(context as Element).reassemble();
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
                Text('Please delete all history before deleting workouts.'),
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

  Future<void> updateOptions(Workout type) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: const Text('Can Not Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Divider(),
                TextButton(
                  child: Text('Update'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    List<WorkoutHistory>? workoutsForType =
                        await _workoutHistoryByWorkout(type.id);
                    if (workoutsForType == null) {
                      await AddTypeForm(context, false, false, type.type, type);
                    } else {
                      await AddTypeForm(context, false, true, type.type, type);
                    }
                  },
                ),
                const Divider(),
                TextButton(
                  child: Text('Delete'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    List<WorkoutHistory>? workoutsForType =
                        await _workoutHistoryByWorkout(type.id);
                    if (workoutsForType == null) {
                      await _deleteWorkout(type.id);
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

  Widget buildTypeCard(BuildContext context, int index, types) {
    return Container(
      margin: const EdgeInsets.all(0),
      //height: 42,
      child: Card(
        child: ListTile(
          onTap: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WorkoutProfile(type: types![index])));
          },
          onLongPress: () async {
            return updateOptions(types[index]);
          },
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('${types![index].name} '),
                    const Spacer(),
                    Text(workoutTypeString(
                        WorkoutType.values[types![index].type]))
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
  final Workout type;
  const WorkoutProfile({Key? key, required this.type}) : super(key: key);

  @override
  State<WorkoutProfile> createState() => _WorkoutProfileState(type: this.type);
}

class _WorkoutProfileState extends State<WorkoutProfile> {
  late Workout type;
  _WorkoutProfileState({required this.type});
  @override
  Widget build(BuildContext context) {
    log("current workout is ${type.name}");
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            type.name,
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
            WorkoutHistoryPage(
              workout: type,
            ),
            WorkoutGraphs(
                workout: type
            )
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
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<List<Routine>?> routines = _readAllRoutines();
  bool inAsyncCall = false;
  bool isInvalidName = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      body: Container(
          child: Column(
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
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Navigator.push( context, MaterialPageRoute( builder: (context) => Workout()), ).then((value) => setState(() {}));
          Routine routine = Routine();
          routine.name = "";
          routine.date = DateTime.now().toString();
          await AddRoutineForm(context, true, routine);
        },
        tooltip: 'Add Routine',
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }

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

  Future<void> AddRoutineForm(
      BuildContext context, bool add, Routine routine) async {
    TextEditingController routineController =
        TextEditingController(text: routine.name);
    return await showDialog(
      context: context,
      builder: (context) {
        return ModalProgressHUD(
          opacity: .5,
          progressIndicator: CircularProgressIndicator(),
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
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        setNewState(() {
                          inAsyncCall = true;
                        });
                        // dismiss keyboard during async call
                        FocusScope.of(context).requestFocus(new FocusNode());

                        bool isDupe =
                            await _routineNameExists(routineController.text);

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
                            //_updateWorkoutHistoryByWorkout(type.id, routineController.text);
                          } else {
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
                        //(context as Element).reassemble();
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
          //title: const Text('Can Not Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Divider(),
                TextButton(
                  child: Text('Update'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    AddRoutineForm(context, false, routine);
                  },
                ),
                const Divider(),
                TextButton(
                  child: Text('Delete'),
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
      //height: 42,
      child: Card(
        child: ListTile(
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
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Routine routine;
  _RoutineProfileState({required this.routine});

  List<GlobalKey<FormState>> formKeys = [];
  List<bool> cardsCompleted = [];
  late Future<List<Workout>?> workouts;

  Widget OrderedWorkoutList() {
    Future<List<RoutineEntry>?> routineEntries =
        _routineEntryByRoutine(routine.id);
    return Scaffold(
      body: FutureBuilder<List<RoutineEntry>?>(
          future: routineEntries,
          builder: (context, AsyncSnapshot<List<RoutineEntry>?> snapshot) {
            if (snapshot.hasData) {
              return ReorderableListView(
                //padding: const EdgeInsets.all(8.0),
                children: <Widget>[
                  for (int index = 0; index < snapshot.data!.length; index += 1)
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
                          trailing: Icon(Icons.drag_handle_outlined),
                          tileColor: Colors.black12,
                          title: Text('${snapshot.data![index].workoutName}'),
                        ),
                      ),
                    ),
                ],
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
              return SizedBox.shrink();
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Navigator.push( context, MaterialPageRoute( builder: (context) => Workout()), ).then((value) => setState(() {}));

          await AddWorkoutEntryForm(context);
        },
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }

  Future<void> AddWorkoutEntryForm(BuildContext context) async {
    List<Workout>? workouts = await _readAllWorkouts();
    Workout workout = workouts![0];
    TextEditingController workoutController =
        TextEditingController(text: workouts[0].name);

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
                      icon: Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      style: TextStyle(color: Colors.white),
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
                  if (_formKey.currentState!.validate()) {
                    var temp = await _routineEntryByRoutine(routine.id);
                    if (temp == null) {
                      _saveRoutineEntry(
                          workout.name, workout.id, routine.id, 0);
                    } else {
                      _saveRoutineEntry(
                          workout.name, workout.id, routine.id, temp.length);
                    }
                    setState(() {
                      //update routine entry list
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

  Widget ExecuteWorkoutEntries(BuildContext context) {
    //Future<List<RoutineEntry>?> routineEntries = _routineEntryByRoutine(routine.id);
    workouts = _workoutsByRoutine(routine.id);

    formKeys = [];
    cardsCompleted = [];
    //need to get the workouts from the entries in order, then construct a list of execute workout cards
    //no clue how to indicate that all of them are done

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          routine.name,
          textAlign: TextAlign.center,
        ),
        // actions: [
        //   IconButton(
        //       onPressed: () async {
        //         Navigator.push(context,
        //             MaterialPageRoute(builder: (context) => ExecuteWorkoutEntries(context)));
        //       },
        //       icon: Icon(Icons.save)
        //   )
        // ],
      ),
      body: Container(
        child: Column(
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
                    log(cardsCompleted.toString());
                    return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 10, top: 10),
                        itemCount: projectSnap.data?.length,
                        itemBuilder: (BuildContext context, int index) =>
                            ExecuteWorkoutCard(
                                projectSnap.data![index], index));
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
      ),
    );
  }

  Widget ExecuteWorkoutCard(Workout workout, int index) {
    TextEditingController weightController = TextEditingController();
    TextEditingController timerController = TextEditingController();
    TextEditingController setController = TextEditingController();
    TextEditingController repController = TextEditingController();

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
                    Divider(),
                    if (cardsCompleted[index])
                      Text("Completed")
                    else
                      SizedBox.shrink(),
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
                            child: Text("Save"),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
          });
    });
  }

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
                        builder: (context) => ExecuteWorkoutEntries(context)));
              },
              icon: Icon(Icons.play_arrow))
        ],
      ),
      body: OrderedWorkoutList(),
    );
  }
}

class WorkoutGraphs extends StatefulWidget {
  final Workout workout;
  const WorkoutGraphs({Key? key, required this.workout}) : super(key: key);

  @override
  State<WorkoutGraphs> createState() => _WorkoutGraphsState(workout: this.workout);
}

class _WorkoutGraphsState extends State<WorkoutGraphs> {
  late Workout workout;
  late Future<List<Feature>?> workoutFeatures; //= _graphFeaturesByWorkoutAndDate(workout.id, dateRange);
  DateTimeRange _selectedDateRange = weekRange();
  _WorkoutGraphsState({required this.workout});

  @override
  Widget build(BuildContext context) {
    if (workout != null) {
      workoutFeatures = _graphFeaturesByWorkoutAndDate(workout.id, _selectedDateRange);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: FutureBuilder<List<Feature>?>(
            future: workoutFeatures,
            builder: (context, projectSnap) {
              if (projectSnap.hasData) {
                return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 10, top: 10),
                    itemCount: projectSnap.data?.length,
                    itemBuilder: (BuildContext context, int index) =>
                        LineGraphCard(projectSnap.data![index]));
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
    );
  }

  Widget LineGraphCard(Feature feature) {
    
    return Card(
      child: LineGraph(
          features: [feature],
          size: Size(150, 150),
          labelX: ["test", "test"],
          labelY: ["test", "test"],
        showDescription: true,
        graphColor: Colors.blue,
      ),
    );
  }
}

Future<List<Feature>?> _graphFeaturesByWorkoutAndDate(int workoutId, DateTimeRange dateRange) async{
  var workoutHistory = await _workoutHistoryByWorkoutAndDates(workoutId, dateRange);
  
  if(workoutHistory == null){
    return null;
  } else {
    List<Feature> features = [];
    //match case with workout type
    //get the attributes that should be graphed, and construct a feature for each
    WorkoutType type = WorkoutType.values[workoutHistory[0].workoutType];
    log('type is ${workoutTypeString(type)}');
    switch (type) {
      case WorkoutType.strength:
        List<double> dataWeight = [];
        List<double> dataSet = [];
        List<double> dataRep = [];
        for(var history in workoutHistory){
          dataWeight.add(history.weight);
          dataSet.add(history.sets.toDouble());
          dataRep.add(history.reps.toDouble());
        }
        log(dataWeight.toString());
        log(dataSet.toString());
        log(dataRep.toString());
        features.add(Feature(
          title: "Weight",
          color: Colors.red,
          data: dataWeight
        ));
        features.add(Feature(
            title: "Sets",
            color: Colors.green,
            data: dataSet
        ));
        features.add(Feature(
            title: "Reps",
            color: Colors.purple,
            data: dataRep
        ));
        log("created ${features.length} features");
        return features;
      case WorkoutType.cardio:
        List<double> dataDuration = [];
        for(var history in workoutHistory){
          dataDuration.add(history.timer);
        }
        features.add(Feature(
            title: "Duration",
            color: Colors.red,
            data: dataDuration
        ));
        return features;
      case WorkoutType.both:
        List<double> dataWeight = [];
        List<double> dataDuration = [];
        for(var history in workoutHistory){
          dataWeight.add(history.weight);
          dataDuration.add(history.timer);
        }
        features.add(Feature(
            title: "Weight",
            color: Colors.red,
            data: dataWeight
        ));
        features.add(Feature(
            title: "Duration",
            color: Colors.red,
            data: dataDuration
        ));
        return features;
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
        workouts.where((element) => element.name.contains(search)).toList();
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
      var temp_workout = element;
      temp_workout.workoutName = workoutName;
      int id = await helper.updateWorkoutHistory(temp_workout);
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
