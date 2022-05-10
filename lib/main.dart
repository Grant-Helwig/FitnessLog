//import 'dart:html';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'database_helper.dart';
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
      theme: ThemeData.dark(),
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
              WorkoutPage(workout:null),
              WorkoutTemplate(),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Routines Coming Soon',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class WorkoutPage extends StatefulWidget {
  final Workout? workout;
  const WorkoutPage({Key? key, required this.workout}) : super(key: key);
  @override
  State<WorkoutPage> createState() => _WorkoutPageState(workout: this.workout);
}

class _WorkoutPageState extends State<WorkoutPage> {
  late Workout? workout;
  _WorkoutPageState({required this.workout});

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //value for date range picker
  DateTimeRange? _selectedDateRange = todayRange();

  //list of all saved workout history
  Future<List<WorkoutHistory>?> workout_history_list = _readAll();

  //separate list is needed for filter
  Future<List<WorkoutHistory>?> workout_history_list_filtered = _workoutsByDates(todayRange());

  //list of all saved workout types
  Future<List<Workout>?> workouts = _readAllTypes();

  //dropdown list is needed, adds an option for all
  Future<List<Workout>?> workout_dropdown =_readAllTypesDropdown();


  //index for position in their lists
  int filter_index = 0;
  int types_index = 0;

  //function to update the type index for the dropdown
  Future<int> UpdateIndex(newValue) async {
    var types = await workouts;
    for (var i = 0; i < types!.length; i++) {
      if (newValue == types[i].name) {
        types_index = i;
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
        if(dropdown_list![filter_index].id == -1){
          workout_history_list_filtered = _workoutsByDates(result);
        } else {
          workout_history_list_filtered = _workoutsByTypeAndDates(dropdown_list[filter_index].id ,result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    //if you navigated from the profile, pre filter the history by the id and range
    if(workout != null){
      workout_history_list_filtered = _workoutsByTypeAndDates(workout!.id, _selectedDateRange!);
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
      Future<List<WorkoutHistory>?> filtered_history;
      if (workoutId == -1) {
        filtered_history = _workoutsByDates(_selectedDateRange!);
      } else {
        if(workout == null){

        } else {
          filtered_history =  _workoutsByTypeAndDates(workout!.id, _selectedDateRange!);
        }
      }
      //Future<List<WorkoutHistory>?> filtered_history =  _workoutsByTypeAndDates(workout!.id, _selectedDateRange!);
      //var new_list = await _workoutsByTypeAndDates(type!.id, _selectedDateRange!);
      // Refresh the UI
      setState(() {
        //workout_history_list_filtered = results;
        //workout_history_list_filtered = filtered_history;

        if (workoutId == -1) {
          workout_history_list_filtered = _workoutsByDates(_selectedDateRange!);
        } else  {
          workout_history_list_filtered = _workoutsByTypeAndDates(workoutId, _selectedDateRange!);
        }

        for (int i = 0; i < types!.length; i++) {
          if (workoutId == types[i].id) {
            filter_index = i;
          }
        }
      });
    }

    Widget dropdownWidget () {
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
                onChanged: (String? newValue) =>
                    dropdownFilter(projectSnap
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
              child: Text("${DateFormat('yyyy/MM/dd').format(_selectedDateRange!.start)} - "
                  "${DateFormat('yyyy/MM/dd').format(_selectedDateRange!.end)}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18
                  ),
              )
          ),
          Divider(),
          if(workout == null) dropdownWidget(),
          Expanded(
              child: FutureBuilder <List<dynamic>?>( //<List<WorkoutRoutine>?>
                  future: Future.wait([
                    workout_history_list_filtered,
                    workouts
                  ]) ,
                  builder: (context, projectSnap) {
                    if (projectSnap.hasData && projectSnap.data![0] != null && projectSnap.data![0].length > 0 ) {
                      return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: projectSnap.data![0]?.length,
                          itemBuilder: (BuildContext context, int index) =>
                              buildWorkoutCard(
                                  context, projectSnap.data![0][index],projectSnap.data![1])
                      );
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
          if(types != null){

            WorkoutHistory workoutHistory = WorkoutHistory();
            workoutHistory.workoutName = "";
            workoutHistory.date = DateTime.now().toString();
            workoutHistory.sets = 0;
            workoutHistory.reps = 0;
            workoutHistory.weight = 0;
            workoutHistory.typeId = 0;
            types_index = 0;
            if(workout == null){
              await AddWorkoutForm(context, true, workoutHistory, false);
            } else {
              await AddWorkoutForm(context, true, workoutHistory, true);
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

  Future<void> AddWorkoutForm(
      BuildContext context, bool add, WorkoutHistory workoutHistory, bool hasContext) async {
    List<Workout>? types = await _readAllTypes();
    List<String> typesString = [];
    Workout curType = types![0];
    // for (var i = 0; i < types.length; i++) {
    //   typesString.add(types[i].type);
    //   if (workout.typeId == types[i].id) {
    //     types_index = i;
    //     curType = types[i];
    //   }
    // }

    if(workout != null){
      for (var i = 0; i < types.length; i++) {
        typesString.add(types[i].name);
        if (workout!.id == types[i].id) {
          types_index = i;
        }
      }
      curType = workout!;
    } else {
      for (var i = 0; i < types.length; i++) {
        typesString.add(types[i].name);
        if (workoutHistory.typeId == types[i].id) {
          types_index = i;
          curType = types[i];
        }
      }
    }

    TextEditingController routineController =
        TextEditingController(text: workout != null ? workout!.name : typesString[0]);
    TextEditingController weightController =
        TextEditingController(text: add ? null : workoutHistory.weight.toString());
    TextEditingController timerController =
    TextEditingController(text: add ? null : workoutHistory.timer.toString());
    TextEditingController setController =
        TextEditingController(text: add ? null : workoutHistory.sets.toString());
    TextEditingController repController =
        TextEditingController(text: add ? null : workoutHistory.reps.toString());
    DateTime myDateTime = DateTime.parse(workoutHistory.date);
    TextEditingController dateController = TextEditingController(
        text: DateFormat('yyyy/MM/dd').format(DateTime.parse(workoutHistory.date)));
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
                                value: projectSnap.data![types_index].name,
                                icon: add ? Icon(Icons.arrow_drop_down) : Icon(null),
                                elevation: 16,
                                style: add ? TextStyle(color: Colors.white) : TextStyle(color: Colors.grey),
                                underline: Container(
                                  height: 2,
                                  color: Colors.white,
                                ),
                                onChanged: (String? newValue) async {
                                  int i = await UpdateIndex(newValue);
                                  setState(() {
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
                            hintText: "Weight",
                            labelText: "Weight *"
                        ),
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
                            hintText: "Duration",
                            labelText: "Duration *"
                        ),
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
                                decoration:
                                    const InputDecoration(
                                        hintText: "Sets",
                                        labelText: "Sets *"
                                    ),
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
                                decoration:
                                    const InputDecoration(
                                        hintText: "Reps",
                                        labelText: "Reps *"
                                    ),
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
                      workoutHistory.sets = int.parse(setController.text.isEmpty ? "0" : setController.text);
                      workoutHistory.reps = int.parse(repController.text.isEmpty ? "0" : repController.text);
                      workoutHistory.weight = double.parse(weightController.text.isEmpty ? "0" : weightController.text);
                      workoutHistory.timer = double.parse(timerController.text.isEmpty ? "0" : timerController.text);
                      _update(workoutHistory);
                    } else {
                      int typeId = -1;
                      int workoutType = -1;
                      for (var i = 0; i < types.length; i++) {
                        if (types[i].name == routineController.text) {
                          typeId = types[i].id;
                          workoutType = types[i].type;
                        }
                      }
                      _save(
                          routineController.text,
                          workoutType,
                          myDateTime,
                          int.parse(setController.text.isEmpty ? "0" : setController.text),
                          int.parse(repController.text.isEmpty ? "0" : repController.text),
                          double.parse(weightController.text.isEmpty ? "0" : weightController.text),
                          double.parse(timerController.text.isEmpty ? "0" : timerController.text) ,
                          typeId);
                    }
                    setState(() {
                      workout_history_list_filtered = _readAll();
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
      if (workoutHistory.typeId == types[i].id) {
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
                await _delete(workoutHistory.id);
                setState(() {
                  workout_history_list_filtered = _readAll();
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
                await _delete(workoutHistory.id);
                setState(() {
                  workout_history_list_filtered = _readAll();
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
                await _delete(workoutHistory.id);
                setState(() {
                  workout_history_list_filtered = _readAll();
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
                          Text('Duration: ${workoutHistory.cardio.toString()}'),
                          const Spacer(),
                          Text('${workoutHistory.strength.toString()} LBS'),
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

class WorkoutTemplate extends StatefulWidget {
  const WorkoutTemplate({Key? key}) : super(key: key);
  //Workout(key) : super(key: key);
  @override
  State<WorkoutTemplate> createState() => _WorkoutTemplateState();
}

class _WorkoutTemplateState extends State<WorkoutTemplate> {
  //List<WorkoutRoutine>? workouts =  _getAll();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<List<Workout>?> workout_type = _readAllTypes();

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
              future: workout_type,
              builder: (context, projectSnap) {
                if (projectSnap.hasData) {
                  return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: projectSnap.data?.length,
                      itemBuilder: (BuildContext context, int index) =>
                          buildTypeCard(context, index, projectSnap.data));
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
          await AddTypeForm(context, true, false, WorkoutType.strength.index, workout);
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

  Future<void> AddTypeForm(
      BuildContext context, bool add, bool lock, int category, Workout type) async {
    TextEditingController typeController =
        TextEditingController(text: type.name);
    // TextEditingController categoryController = TextEditingController(
    //     text: add ? "Yes" : (type.workoutEnum == 1 ? "Yes" : "No"));
    int? categoryController = category;
    return await showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: AlertDialog(
            scrollable: true,
            content: StatefulBuilder(
              builder: (context, setState) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: typeController,
                        validator: (value) {
                          return value!.isNotEmpty ? null : "Empty";
                        },
                        decoration: const InputDecoration(hintText: "Workout"),
                      ),
                      RadioListTile<int>(
                        value: WorkoutType.strength.index,
                        groupValue: categoryController,
                        title: Text("Strength"),
                        onChanged: lock ? null : (value) {

                          setState(() {
                            categoryController = WorkoutType.strength.index;
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
                        onChanged: lock ? null : (value) {
                          setState(() {
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
                        onChanged: lock ? null :  (value) {
                          setState(() {
                            categoryController = WorkoutType.both.index;
                            log(categoryController.toString());
                          });
                        },
                        activeColor: Colors.green,
                        toggleable: true,
                      ),
                    ],
                  ),
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
                  if (_formKey.currentState!.validate()) {
                    if (!add) {
                      type.name = typeController.text;
                      type.type = categoryController!;
                      _updateType(type);
                      _updateWorkoutsByType(type.id, typeController.text);
                    } else {
                      _saveType(
                        typeController.text,
                        categoryController!,
                      );
                    }
                    setState(() {
                      workout_type = _readAllTypes();
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
                    List<WorkoutHistory>? workoutsForType =  await _workoutsByType(type.id);
                    if(workoutsForType == null){
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
                    List<WorkoutHistory>? workoutsForType =  await _workoutsByType(type.id);
                    if(workoutsForType == null){
                      await _deleteType(type.id);
                    } else {
                      return cantDeleteAlert();
                    }
                    setState(() {
                      workout_type = _readAllTypes();
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => WorkoutProfile( type: types![index])));
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
                    Text(workoutTypeString(WorkoutType.values[types![index].type]))
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
              WorkoutPage(workout: type,),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Metrics Coming Soon',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
    );
  }
}

_saveType(String type, int wRequired) async {
  Workout wType = Workout();
  wType.name = type;
  wType.type = wRequired;
  DatabaseHelper helper = DatabaseHelper.instance;
  int id = await helper.insertWorkout(wType);
  wType.id = id;

  log('inserted row: $id');
}

_deleteType(int _id) async {
  DatabaseHelper helper = DatabaseHelper.instance;

  int id = await helper.deleteWorkout(_id);

  log('deleted row: $id');
}

_updateType(Workout type) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  log('updating row: ${type.id.toString()}');
  int id = await helper.updateWorkout(type);

  log('updated row: $id');
}

Future<Workout?> _readType(int rowId) async {
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

Future<List<Workout>?> _readAllTypes() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  int rowId = 1;
  List<Workout>? workouts = await helper.queryAllWorkouts();
  if (workouts == null) {
    log('read row $rowId: empty');
    return null;
  } else {
    log('read row $rowId: $workouts');
    return workouts;
  }
}

Future<List<Workout>?> _readAllTypesDropdown() async {
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
    workouts.insert(0, add);
    return workouts;
  }
}

_save(String routine, int type, DateTime date, int sets, int reps, double weight,
    double timer, int typeId) async {
  WorkoutHistory workout = WorkoutHistory();
  workout.workoutName = routine;
  workout.workoutType = type;
  workout.date = date.toString();
  workout.sets = sets;
  workout.reps = reps;
  workout.weight = weight;
  workout.timer = timer;
  workout.typeId = typeId;

  DatabaseHelper helper = DatabaseHelper.instance;

  int id = await helper.insertWorkoutHistory(workout);
  workout.id = id;

  log('inserted row: $id');
}

_delete(int _id) async {
  DatabaseHelper helper = DatabaseHelper.instance;

  int id = await helper.deleteWorkoutHistory(_id);

  log('deleted row: $id');
}

_update(WorkoutHistory workout) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  log('updating row: ${workout.id.toString()}');
  int id = await helper.updateWorkoutHistory(workout);

  log('updated row: $id');
}

Future<List<WorkoutHistory>?> _readAll() async {
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

Future<List<WorkoutHistory>?> _workoutsByType(int id) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<WorkoutHistory>? workouts = await helper.queryWorkoutHistoryByType(id);
  if (workouts == null) {
    log('read row $id: empty');
    return null;
  } else {
    log('read row $id: $workouts');
    return workouts;
  }
}

Future<List<WorkoutHistory>?> _workoutsByTypeAndDates(int id, DateTimeRange range) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<WorkoutHistory>? workouts = await helper.queryWorkoutHistoryByType(id);
  if (workouts == null) {
    log('read row $id: empty');
    return null;
  } else {
    log('read row $id: $workouts');
    List<WorkoutHistory>? workoutsInRange = [];
    log(workouts.length.toString());
    for (var value in workouts) {
      DateTime curDay = DateTime.parse(value.date);
      if(range.start.isBefore(curDay) && range.end.isAfter(curDay) ||
          datesEqual(range.start, curDay) ||
          datesEqual(range.end, curDay)){
        workoutsInRange.add(value);
        log("added ${value.workoutName} from ${value.date}");
      } else {
        log("skipped ${value.workoutName} from ${value.date}");
      }
    }
    return workoutsInRange;
  }
}

Future<List<WorkoutHistory>?> _workoutsByDates(DateTimeRange range) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<WorkoutHistory>? workouts = await helper.queryAllWorkoutHistory();
  if (workouts == null) {
    return null;
  } else {
    List<WorkoutHistory>? workoutsInRange = [];
    for (var value in workouts) {
      DateTime curDay = DateTime.parse(value.date);
      if(range.start.isBefore(curDay) && range.end.isAfter(curDay) ||
      datesEqual(range.start, curDay) ||
          datesEqual(range.end, curDay)){
        workoutsInRange.add(value);
      }
    }
    return workoutsInRange;
  }
}

Future<List<WorkoutHistory>?> _updateWorkoutsByType(int id, String workoutName) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<WorkoutHistory>? workouts = await helper.queryWorkoutHistoryByType(id);
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

DateTimeRange todayRange(){
  DateTime now = DateTime.now();
  DateTime dateStart = DateTime(now.year, now.month, now.day);
  DateTime dateEnd = DateTime(now.year, now.month, now.day);
  return DateTimeRange(start: dateStart, end: dateEnd);
}

bool datesEqual(DateTime one, DateTime two){
  return one.year == two.year && one.month == two.month && one.day == two.day;
}