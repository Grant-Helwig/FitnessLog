//import 'dart:html';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'WorkoutRoutine.dart';
//import 'WorkoutTemplate.dart';

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
              // Align(
              //   alignment: Alignment.center,
              //   child: Text(
              //     'Templates Coming Soon',
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Metrics Coming Soon',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () async {
          //     //Navigator.push( context, MaterialPageRoute( builder: (context) => Workout()), ).then((value) => setState(() {}));
          //     await ShowWorkoutForm(context);
          //   },
          //   tooltip: 'Add Workout',
          //   child: const Icon(Icons.add),
          //   backgroundColor: Colors.white,
          // ),
        ));
  }
}

class Workout extends StatefulWidget {
  const Workout({Key? key}) : super(key: key);
  //Workout(key) : super(key: key);
  @override
  State<Workout> createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  //List<WorkoutRoutine>? workouts =  _getAll();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<List<WorkoutRoutine>?> workout_list = _readAll();

  Future<List<WorkoutRoutine>?> workout_list_filtered = _readAll();

  Future<List<WorkoutType>?> workout_type = _readAllTypes();

  Future<List<WorkoutType>?> workout_type_dropdown = _readAllTypesDropdown();

  int filter_index = 0;
  int types_index = 0;
  var curValue;

  UpdateIndex(newValue) async{
    var types = await workout_type;
    for(var i=0;i<types!.length;i++){
      if(newValue == types[i].type){
        types_index = i;
        log(i.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //log(workouts!.length.toString());


    Future<List<WorkoutRoutine>?> getList (List<WorkoutRoutine>? temp) async {
      return temp;
    }
    void dropdownFilter(int filter) async {
      log(filter.toString());
      Future<List<WorkoutRoutine>?> results;
      if (filter == -1) {
        // if the search field is empty or only contains white-space, we'll display all users
        results = workout_list;
      } else {
        //results = workout_type_dropdown
        //    .then((value) => value.forEach((item) => strings!.add(item.type))
        //    .toList();
        results = Future<List<WorkoutRoutine>?>.value();
        List<WorkoutRoutine>? temp = [];
        await workout_list.then((value) {
          if (value != null) {
            for (var item in value) {

              if(item.typeId == filter){
                //log(item.routine.toString());
                temp.add(item);

              }
            }
          }
        });
        temp.forEach((element) {log(element.routine);});
        results = getList(temp);
        // we use the toLowerCase() method to make it case-insensitive
      }
      var types = await workout_type_dropdown;
      // Refresh the UI
      setState(() {
         workout_list_filtered = results;

         for(int i = 0; i < types!.length; i++){
           if(filter == types[i].id){
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
          // Padding(
          //   padding: const EdgeInsets.only(top:10, bottom: 10),
          //   child: Text("test",
          //   textAlign: TextAlign.center,
          //   ),
          // ),
            FutureBuilder<List<WorkoutType>?>(
                future: workout_type_dropdown,
                builder: (context, projectSnap) {
                  if(projectSnap.hasData){
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
                      onChanged: (String? newValue) => dropdownFilter(projectSnap.data!.firstWhere((element) => element.type == newValue).id),
                      items:
                      projectSnap.data!.map<DropdownMenuItem<String>>((WorkoutType value)  {
                        return DropdownMenuItem<String>(
                          value: value.type,
                          child: Text(value.type),
                        );
                      }).toList(),
                    );
                  } else {
                    return  SizedBox.shrink();
                  }


                }),

          Expanded(
              child: FutureBuilder<List<WorkoutRoutine>?>(
                  future: workout_list_filtered,
                  builder: (context, projectSnap) {
                    if (projectSnap.hasData) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                          itemCount: projectSnap.data?.length,
                          itemBuilder: (BuildContext context, int index) =>
                              buildWorkoutCard(context, index, projectSnap.data)

                          // Text(
                          //   '${projectSnap.data![index].routine} - ${DateFormat('yyyy/MM/dd  kk:mm').format(DateTime.parse(projectSnap.data![index].date))} \n${projectSnap.data![index].weight.toString()} LBS '
                          //       '\n ${projectSnap.data![index].sets.toString()} sets ${projectSnap.data![index].reps.toString()} reps',
                          //   textAlign: TextAlign.center,
                          // ),

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
      )
      ),
      floatingActionButton:  FloatingActionButton(
        onPressed: () async {
          //Navigator.push( context, MaterialPageRoute( builder: (context) => Workout()), ).then((value) => setState(() {}));
          WorkoutRoutine workout = WorkoutRoutine();
          workout.routine = "";
          workout.date = DateTime.now().toString();
          workout.sets = 0;
          workout.reps = 0;
          workout.weight = 0;
          workout.typeId = 0;
          await AddWorkoutForm(context, true, workout);
        },
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }

  Future<void> AddWorkoutForm(BuildContext context, bool add, WorkoutRoutine workout) async {
    List<WorkoutType>? types = await _readAllTypes();
    List<String> typesString = [];


    for(var i=0;i<types!.length;i++){
      typesString.add(types[i].type);
      if(workout.typeId == types[i].id){
        types_index = i;
      }
    }

    TextEditingController routineController =
        TextEditingController(text: typesString[0]);
    TextEditingController weightController =
        TextEditingController(text: add ? null : workout.weight.toString());
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
          return  Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TextFormField(
                          //   controller: routineController,
                          //   validator: (value) {
                          //     return value!.isNotEmpty ? null : "Empty";
                          //   },
                          //   decoration: const InputDecoration(hintText: "Routine"),
                          // ),
                          FutureBuilder<List<WorkoutType>?>(
                              future: workout_type,
                              builder: (context, projectSnap) {
                                if (projectSnap.hasData) {
                                  return DropdownButton<String>(
                                    isExpanded: true,
                                    value: projectSnap.data![types_index].type,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    elevation: 16,
                                    style: const TextStyle(color: Colors.white),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.white,
                                    ),
                                    onChanged: (String? newValue) async {
                                      //await UpdateIndex(newValue);
                                      setState(() {
                                        routineController.text = newValue!;
                                        //log(types[types_index].type);
                                        UpdateIndex(newValue);
                                        //dropdownValue = newValue!;
                                      });
                                    },
                                    items:
                                    projectSnap.data!.map<
                                        DropdownMenuItem<String>>((
                                        WorkoutType value) {
                                      return DropdownMenuItem<String>(
                                        value: value.type,
                                        child: Text(value.type),
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return Text(
                                    'No History',
                                    textAlign: TextAlign.center,
                                  );
                                }
                              }
                          ),
                          TextFormField(
                            controller: weightController,
                            validator: (value) {
                              return value!.isNotEmpty ? null : "Empty";
                            },
                            decoration: const InputDecoration(
                                hintText: "Weight"),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]')),
                            ],
                          ),
                          Row(
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
                                        hintText: "Sets"),
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
                                        hintText: "Reps"),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                    ],
                                  ),
                                ),
                              ]),
                          TextField(
                            //DateFormat('yyyy/MM/dd').format(myDateTime),
                            controller: dateController,
                            readOnly: true,
                            onTap: () async {
                              myDateTime = (await showDatePicker(
                                context: context,
                                initialDate: DateTime.parse(workout.date),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(3000),
                              ))!;
                              dateController.text =
                                  DateFormat('yyyy/MM/dd').format(myDateTime);
                              setState(() {});
                            },
                          )
                        ],
                      ),
                    );}),
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
                              _delete(workout.id);
                            }
                            int typeId = -1;
                            for (var i = 0; i < types.length; i++) {
                              if (types[i].type == routineController.text) {
                                typeId = types[i].id;
                              }
                            }
                            _save(
                                routineController.text,
                                myDateTime,
                                int.parse(setController.text),
                                int.parse(repController.text),
                                double.parse(weightController.text),
                                typeId);
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

                  )
          );
        });
  }

  Widget buildWorkoutCard(BuildContext context, int index, workouts) {
    return Container(
        margin: const EdgeInsets.all(0),
        //height: 42,
        child: Card(
            child: ListTile(
          onTap: () async {
            //await ShowWorkoutForm(context);
            await AddWorkoutForm(context, false, workouts[index]);
          },
          onLongPress: () async {
            await _delete(workouts[index].id);
            setState(() {
              workout_list = _readAll();
            });
          },
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('${workouts![index].routine} '),
                    const Spacer(),
                    Text(
                      DateFormat('yyyy/MM/dd') // hh:mm a
                          .format(DateTime.parse(workouts![index].date)),
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
                      Text('${workouts![index].weight.toString()} LBS'),
                      const Spacer(),
                      Text('${workouts![index].sets.toString()} Sets '),
                      const Spacer(),
                      Text('${workouts![index].reps.toString()} Reps'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )));
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
              // Padding(
              //   padding: const EdgeInsets.only(top:10, bottom: 10),
              //   child: Text("test",
              //   textAlign: TextAlign.center,
              //   ),
              // ),
              Expanded(
                  child: FutureBuilder<List<WorkoutType>?>(
                      future: workout_type,
                      builder: (context, projectSnap) {
                        if (projectSnap.hasData) {
                          return
                            ListView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: projectSnap.data?.length,
                              itemBuilder:
                                  (BuildContext context, int index) =>
                                  buildTypeCard(context, index, projectSnap.data)


                          );
                        } else {
                          return const Align(
                            alignment: Alignment.center,
                            child: Text(
                              'No Workouts',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                      }))
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Navigator.push( context, MaterialPageRoute( builder: (context) => Workout()), ).then((value) => setState(() {}));
          WorkoutType workout = WorkoutType();
          workout.type = "";
          workout.weightRequired = 1;
          await AddTypeForm(context, true, workout);
        },
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget myRadioButton(TextEditingController radioController ){
    return Radio(
        value: radioController.text,
        groupValue: radioController.text,
        onChanged: (value) {
          setState(() {
            radioController.text = value.toString();
          });
        }
    );
  }

  Future<void> AddTypeForm(BuildContext context, bool add, WorkoutType type) async {
    TextEditingController typeController =
    TextEditingController(text: type.type);
    TextEditingController weightRequiredController =
    TextEditingController(text: add ? "Yes" : (type.weightRequired == 1 ? "Yes" : "No" ));
    return await showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: AlertDialog(
                scrollable: true,
                content: Form(
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
                      // TextFormField(
                      //   controller: weightRequiredController,
                      //   validator: (value) {
                      //     return value!.isNotEmpty ? null : "Empty";
                      //   },
                      //   decoration: const InputDecoration(hintText: "Weight"),
                      //   keyboardType: TextInputType.number,
                      //   inputFormatters: <TextInputFormatter>[
                      //     FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      //   ],
                      // ),
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
                        if(!add){
                          _deleteType(type.id);
                        }

                        _saveType(
                            typeController.text,
                            1,
                        );
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
              ));
        });
  }

  Widget buildTypeCard(BuildContext context, int index, types) {
    return Container(
        margin: const EdgeInsets.all(0),
        //height: 42,
        child: Card(
            child: ListTile(
              onTap: () async {
                //await ShowWorkoutForm(context);
                await AddTypeForm(context, false, types[index]);
              },
              onLongPress: () async {
                await _deleteType(types[index].id);
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
                        //Spacer(),

                      ],
                    ),
                  ),
                  //Divider()
                ],
              ),
            )));
  }
}

_saveType(String type, int wRequired) async {
  WorkoutType wType = WorkoutType();
  wType.type = type;
  wType.weightRequired = wRequired;
  DatabaseHelper helper = DatabaseHelper.instance;
  //await helper.
  int id = await helper.insertType(wType);
  wType.id = id;

  log('inserted row: $id');
}

_deleteType(int _id) async {
  DatabaseHelper helper = DatabaseHelper.instance;

  int id = await helper.deleteType(_id);

  log('deleted row: $id');
}

_readType() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  int rowId = 1;
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
    // workouts.sort((a, b) {
    //   return b.date.compareTo(a.date);
    // });
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
    // workouts.sort((a, b) {
    //   return b.date.compareTo(a.date);
    // });
    WorkoutType add = WorkoutType();
    add.id = -1;
    add.type = "All";
    add.weightRequired = 1;
    workouts.insert(0, add);
    return workouts;
  }
}

List<WorkoutType>? _getAllTypes() {
  Future<List<WorkoutType>?> workoutsFuture = _readAllTypes();
  List<WorkoutType>? workouts;
  workoutsFuture.then((value) {
    if (value != null) value.forEach((item) => workouts!.add(item));
  });
  log(workouts!.length.toString());
  return workouts == null ? [] : workouts;
}

List<WorkoutType>? _getAllTypesDropdown() {
  Future<List<WorkoutType>?> workoutsFuture = _readAllTypes();
  List<WorkoutType>? workouts;
  workoutsFuture.then((value) {
    if (value != null) value.forEach((item) => workouts!.add(item));
  });
  log(workouts!.length.toString());
  WorkoutType add = WorkoutType();
  add.id = -1;
  add.type = "All";
  add.weightRequired = 1;
  workouts.insert(0, add);
  return workouts == null ? [] : workouts;
}

List<String>? _getAllTypeStrings() {
  Future<List<WorkoutType>?> workoutsFuture = _readAllTypes();
  List<String>? strings;
  workoutsFuture.then((value) {
    if (value != null) value.forEach((item) => strings!.add(item.type));
  });
  log(strings!.length.toString());
  return strings == null ? [] : strings;
}

_save(String routine, DateTime date, int sets, int reps, double weight, int typeId) async {
  WorkoutRoutine workout = WorkoutRoutine();
  workout.routine = routine;
  workout.date = date.toString();
  workout.sets = sets;
  workout.reps = reps;
  workout.weight = weight;
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

List<WorkoutRoutine>? _getAll() {
  Future<List<WorkoutRoutine>?> workoutsFuture = _readAll();
  List<WorkoutRoutine>? workouts;
  workoutsFuture.then((value) {
    if (value != null) value.forEach((item) => workouts!.add(item));
  });
  log(workouts!.length.toString());
  return workouts == null ? [] : workouts;
}
