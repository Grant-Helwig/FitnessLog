//import 'dart:html';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'WorkoutRoutine.dart';
import 'package:mdi/mdi.dart';

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
                    'Metrics',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              )
            ]),
          ),
          body: const TabBarView(
            children: <Widget>[
              Workout(),
              WorkoutTemplate(),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Metrics Coming Soon',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ));
  }
}

class Workout extends StatefulWidget {
  const Workout({Key? key}) : super(key: key);
  @override
  State<Workout> createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //list of all saved workout history
  Future<List<WorkoutRoutine>?> workout_list = _readAll();

  //separate list is needed for filter
  Future<List<WorkoutRoutine>?> workout_list_filtered = _readAll();

  //list of all saved workout types
  Future<List<WorkoutType>?> workout_type = _readAllTypes();

  //dropdown list is needed, adds an option for all
  Future<List<WorkoutType>?> workout_type_dropdown = _readAllTypesDropdown();

  //index for position in their lists
  int filter_index = 0;
  int types_index = 0;

  //function to update the type index for the dropdown
  Future<int> UpdateIndex(newValue) async {
    var types = await workout_type;
    for (var i = 0; i < types!.length; i++) {
      if (newValue == types[i].type) {
        types_index = i;
        log(i.toString());
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<WorkoutRoutine>?> getList(List<WorkoutRoutine>? temp) async {
      return temp;
    }

    void dropdownFilter(int filter) async {
      log(filter.toString());
      Future<List<WorkoutRoutine>?> results;
      if (filter == -1) {
        // if the search field is empty or only contains white-space, we'll display all users
        results = workout_list;
      } else {
        //construct a list to display with the matching keys
        results = Future<List<WorkoutRoutine>?>.value();
        List<WorkoutRoutine>? temp = [];
        await workout_list.then((value) {
          if (value != null) {
            for (var item in value) {
              if (item.typeId == filter) {
                temp.add(item);
              }
            }
          }
        });
        temp.forEach((element) {
          log(element.routine);
        });
        results = getList(temp);
      }
      var types = await workout_type_dropdown;

      // Refresh the UI
      setState(() {
        workout_list_filtered = results;

        for (int i = 0; i < types!.length; i++) {
          if (filter == types[i].id) {
            filter_index = i;
          }
        }
      });
    }

    return Scaffold(
      drawer: const Drawer(),
      body: Container(
          child: Column(
        children: [
          FutureBuilder<List<WorkoutType>?>(
              future: workout_type_dropdown,
              builder: (context, projectSnap) {
                if (projectSnap.hasData) {
                  return DropdownButton<String>(
                    isExpanded: true,
                    value: projectSnap.data![filter_index].type,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: const TextStyle(color: Colors.white),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                    onChanged: (String? newValue) => dropdownFilter(projectSnap
                        .data!
                        .firstWhere((element) => element.type == newValue)
                        .id),
                    items: projectSnap.data!
                        .map<DropdownMenuItem<String>>((WorkoutType value) {
                      return DropdownMenuItem<String>(
                        value: value.type,
                        child: Text(value.type),
                      );
                    }).toList(),
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),
          Expanded(
              child: FutureBuilder <List<dynamic>?>( //<List<WorkoutRoutine>?>
                  future: Future.wait([
                    workout_list_filtered,
                    workout_type
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
          List<WorkoutType>? types = await workout_type;
          if(types != null){
            WorkoutRoutine workout = WorkoutRoutine();
            workout.routine = "";
            workout.date = DateTime.now().toString();
            workout.sets = 0;
            workout.reps = 0;
            workout.weight = 0;
            workout.typeId = 0;
            types_index = 0;
            await AddWorkoutForm(context, true, workout);
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
      BuildContext context, bool add, WorkoutRoutine workout) async {
    List<WorkoutType>? types = await _readAllTypes();
    List<String> typesString = [];

    WorkoutType curType = types![0];
    for (var i = 0; i < types.length; i++) {
      typesString.add(types[i].type);
      if (workout.typeId == types[i].id) {
        types_index = i;
        curType = types[i];
      }
    }

    TextEditingController routineController =
        TextEditingController(text: typesString[0]);
    TextEditingController weightController =
        TextEditingController(text: add ? null : workout.weight.toString());
    TextEditingController timerController =
    TextEditingController(text: add ? null : workout.timer.toString());
    TextEditingController setController =
        TextEditingController(text: add ? null : workout.sets.toString());
    TextEditingController repController =
        TextEditingController(text: add ? null : workout.reps.toString());
    DateTime myDateTime = DateTime.parse(workout.date);
    TextEditingController dateController = TextEditingController(
        text: DateFormat('yyyy/MM/dd').format(DateTime.parse(workout.date)));
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
                    FutureBuilder<List<WorkoutType>?>(
                        future: workout_type,
                        builder: (context, projectSnap) {
                          if (projectSnap.hasData) {
                            return IgnorePointer(
                              ignoring: !add,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: projectSnap.data![types_index].type,
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
                                    log(curType.type);
                                  });
                                },
                                items: projectSnap.data!
                                    .map<DropdownMenuItem<String>>(
                                        (WorkoutType value) {
                                  return DropdownMenuItem<String>(
                                    value: value.type,
                                    child: Text(value.type),
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
                      visible: curType.workoutEnum == WorkoutCategories.weight.index ||
                          curType.workoutEnum == WorkoutCategories.both.index,
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
                      visible: curType.workoutEnum == WorkoutCategories.timer.index ||
                          curType.workoutEnum == WorkoutCategories.both.index,
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
                      visible: curType.workoutEnum == WorkoutCategories.weight.index,
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
                        var dateTemp = (await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(workout.date),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(3000),
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
                      workout.routine = routineController.text;
                      workout.date = myDateTime.toString();
                      workout.sets = int.parse(setController.text.isEmpty ? "0" : setController.text);
                      workout.reps = int.parse(repController.text.isEmpty ? "0" : repController.text);
                      workout.weight = double.parse(weightController.text.isEmpty ? "0" : weightController.text);
                      workout.timer = double.parse(timerController.text.isEmpty ? "0" : timerController.text);
                      _update(workout);
                    } else {
                      int typeId = -1;
                      for (var i = 0; i < types.length; i++) {
                        if (types[i].type == routineController.text) {
                          typeId = types[i].id;
                        }
                      }
                      _save(
                          routineController.text,
                          myDateTime,
                          int.parse(setController.text.isEmpty ? "0" : setController.text),
                          int.parse(repController.text.isEmpty ? "0" : repController.text),
                          double.parse(weightController.text.isEmpty ? "0" : weightController.text),
                          double.parse(timerController.text.isEmpty ? "0" : timerController.text) ,
                          typeId);
                    }
                    setState(() {
                      workout_list_filtered = _readAll();
                      workout_list = workout_list_filtered;
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

  Widget buildWorkoutCard(BuildContext context, workout, types) {
    WorkoutCategories? cat = null;
    for (var i = 0; i < types.length; i++) {
      if (workout.typeId == types[i].id) {
        cat = WorkoutCategories.values[types[i].workoutEnum];
        log(CategoryString(cat));
      }
    }
    switch (cat) {
      case WorkoutCategories.weight:
        return Container(
          margin: const EdgeInsets.all(0),
          //height: 42,
          child: Card(
            child: ListTile(
              onTap: () async {
                await AddWorkoutForm(context, false, workout);
              },
              onLongPress: () async {
                await _delete(workout.id);
                setState(() {
                  workout_list_filtered = _readAll();
                  workout_list = workout_list_filtered;
                });
              },
              title: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text('${workout.routine} '),
                        const Spacer(),
                        Text(
                          DateFormat('yyyy/MM/dd') // hh:mm a
                              .format(DateTime.parse(workout.date)),
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
                          Text('${workout.weight.toString()} LBS'),
                          const Spacer(),
                          Text('${workout.sets.toString()} Sets '),
                          const Spacer(),
                          Text('${workout.reps.toString()} Reps'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case WorkoutCategories.timer:
        return Container(
          margin: const EdgeInsets.all(0),
          //height: 42,
          child: Card(
            child: ListTile(
              onTap: () async {
                await AddWorkoutForm(context, false, workout);
              },
              onLongPress: () async {
                await _delete(workout.id);
                setState(() {
                  workout_list_filtered = _readAll();
                  workout_list = workout_list_filtered;
                });
              },
              title: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text('${workout.routine} '),
                        const Spacer(),
                        Text(
                          DateFormat('yyyy/MM/dd') // hh:mm a
                              .format(DateTime.parse(workout.date)),
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
                          Text('Duration: ${workout.timer.toString()}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case WorkoutCategories.both:
        return Container(
          margin: const EdgeInsets.all(0),
          //height: 42,
          child: Card(
            child: ListTile(
              onTap: () async {
                await AddWorkoutForm(context, false, workout);
              },
              onLongPress: () async {
                await _delete(workout.id);
                setState(() {
                  workout_list_filtered = _readAll();
                  workout_list = workout_list_filtered;
                });
              },
              title: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text('${workout.routine} '),
                        const Spacer(),
                        Text(
                          DateFormat('yyyy/MM/dd') // hh:mm a
                              .format(DateTime.parse(workout.date)),
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
                          Text('Duration: ${workout.timer.toString()}'),
                          const Spacer(),
                          Text('${workout.weight.toString()} LBS'),
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

  Future<List<WorkoutType>?> workout_type = _readAllTypes();

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
            child: FutureBuilder<List<WorkoutType>?>(
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
          WorkoutType workout = WorkoutType();
          workout.type = "";
          workout.workoutEnum = 1;
          await AddTypeForm(context, true, false, WorkoutCategories.weight.index, workout);
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
      BuildContext context, bool add, bool lock, int category, WorkoutType type) async {
    TextEditingController typeController =
        TextEditingController(text: type.type);
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
                        value: WorkoutCategories.weight.index,
                        groupValue: categoryController,
                        title: Text("Weights"),
                        onChanged: lock ? null : (value) {

                          setState(() {
                            categoryController = WorkoutCategories.weight.index;
                            log(categoryController.toString());
                          });
                        },
                        activeColor: Colors.green,
                        toggleable: true,
                      ),
                      RadioListTile<int>(
                        value: WorkoutCategories.timer.index,
                        groupValue: categoryController,
                        title: Text("Timer"),
                        onChanged: lock ? null : (value) {
                          setState(() {
                            categoryController = WorkoutCategories.timer.index;
                            log(categoryController.toString());
                          });
                        },
                        activeColor: Colors.green,
                        toggleable: true,
                      ),
                      RadioListTile<int>(
                        value: WorkoutCategories.both.index,
                        groupValue: categoryController,
                        title: Text("Both"),
                        onChanged: lock ? null :  (value) {
                          setState(() {
                            categoryController = WorkoutCategories.both.index;
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
                      type.type = typeController.text;
                      type.workoutEnum = categoryController!;
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

  Widget buildTypeCard(BuildContext context, int index, types) {
    return Container(
      margin: const EdgeInsets.all(0),
      //height: 42,
      child: Card(
        child: ListTile(
          onTap: () async {
            List<WorkoutRoutine>? workoutsForType =  await _workoutsByType(types[index].id);
            if(workoutsForType == null){
              await AddTypeForm(context, false, false, types[index].workoutEnum, types[index]);
            } else {
              await AddTypeForm(context, false, true, types[index].workoutEnum, types[index]);
            }

          },
          onLongPress: () async {
            List<WorkoutRoutine>? workoutsForType =  await _workoutsByType(types[index].id);
            if(workoutsForType == null){
              await _deleteType(types[index].id);
            } else {
              return cantDeleteAlert();
            }
            setState(() {
              workout_type = _readAllTypes();
            });
          },
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('${types![index].type} '),
                    const Spacer(),
                    Text(CategoryString(WorkoutCategories.values[types![index].workoutEnum]))
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

_saveType(String type, int wRequired) async {
  WorkoutType wType = WorkoutType();
  wType.type = type;
  wType.workoutEnum = wRequired;
  DatabaseHelper helper = DatabaseHelper.instance;
  int id = await helper.insertType(wType);
  wType.id = id;

  log('inserted row: $id');
}

_deleteType(int _id) async {
  DatabaseHelper helper = DatabaseHelper.instance;

  int id = await helper.deleteType(_id);

  log('deleted row: $id');
}

_updateType(WorkoutType type) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  log('updating row: ${type.id.toString()}');
  int id = await helper.updateType(type);

  log('updated row: $id');
}

Future<WorkoutType?> _readType(int rowId) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  WorkoutType? workout = await helper.queryType(rowId);
  if (workout == null) {
    log('read row $rowId: empty');
    return null;
  } else {
    log('read row $rowId: ${workout.type}');
    return workout;
  }
}

Future<List<WorkoutType>?> _readAllTypes() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  int rowId = 1;
  List<WorkoutType>? workouts = await helper.queryAllTypes();
  if (workouts == null) {
    log('read row $rowId: empty');
    return null;
  } else {
    log('read row $rowId: $workouts');
    return workouts;
  }
}

Future<List<WorkoutType>?> _readAllTypesDropdown() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  int rowId = 1;
  List<WorkoutType>? workouts = await helper.queryAllTypes();
  if (workouts == null) {
    log('read row $rowId: empty');
    return null;
  } else {
    log('read row $rowId: $workouts');
    WorkoutType add = WorkoutType();
    add.id = -1;
    add.type = "All";
    add.workoutEnum = 1;
    workouts.insert(0, add);
    return workouts;
  }
}

_save(String routine, DateTime date, int sets, int reps, double weight,
    double timer, int typeId) async {
  WorkoutRoutine workout = WorkoutRoutine();
  workout.routine = routine;
  workout.date = date.toString();
  workout.sets = sets;
  workout.reps = reps;
  workout.weight = weight;
  workout.timer = timer;
  workout.typeId = typeId;

  DatabaseHelper helper = DatabaseHelper.instance;

  int id = await helper.insertWorkout(workout);
  workout.id = id;

  log('inserted row: $id');
}

_delete(int _id) async {
  DatabaseHelper helper = DatabaseHelper.instance;

  int id = await helper.deleteWorkout(_id);

  log('deleted row: $id');
}

_update(WorkoutRoutine workout) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  log('updating row: ${workout.id.toString()}');
  int id = await helper.updateWorkout(workout);

  log('updated row: $id');
}

_read() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  int rowId = 1;
  WorkoutRoutine? workout = await helper.queryWorkout(rowId);
  if (workout == null) {
    log('read row $rowId: empty');
    return null;
  } else {
    log('read row $rowId: ${workout.routine}');
    return workout;
  }
}

Future<List<WorkoutRoutine>?> _readAll() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  int rowId = 1;
  List<WorkoutRoutine>? workouts = await helper.queryAllWorkouts();
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

Future<List<WorkoutRoutine>?> _workoutsByType(int id) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<WorkoutRoutine>? workouts = await helper.queryWorkoutsByType(id);
  if (workouts == null) {
    log('read row $id: empty');
    return null;
  } else {
    log('read row $id: $workouts');
    return workouts;
  }
}

Future<List<WorkoutRoutine>?> _updateWorkoutsByType(int id, String workoutName) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<WorkoutRoutine>? workouts = await helper.queryWorkoutsByType(id);
  if (workouts == null) {
    log('read row $id: empty');
    return null;
  } else {
    log('read row $id: $workouts');
    for (var element in workouts) {
      var temp_workout = element;
      temp_workout.routine = workoutName;
      int id = await helper.updateWorkout(temp_workout);
      log('update row $id');
    }
    return workouts;
  }
}