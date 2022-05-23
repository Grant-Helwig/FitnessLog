import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hey_workout/ui/workout_profile_page.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:unicons/unicons.dart';

import '../bloc/workout_bloc.dart';
import '../model/routine_entry.dart';
import '../model/workout.dart';
import '../model/workout_history.dart';
import '../repository/workout_repository.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({Key? key}) : super(key: key);
  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final WorkoutBloc workoutBloc = WorkoutBloc();

  final repo = WorkoutRepository();

  //Future<List<Workout>?> workouts = _readAllWorkouts();

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
            child: getWorkoutsWidget()
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

  Widget getWorkoutsWidget(){
    return StreamBuilder(
        stream: workoutBloc.workouts,
        builder:  (BuildContext context, AsyncSnapshot<List<Workout>?> snapshot) {
          return getWorkoutCardWidget(snapshot);
        },
    );
  }

  Widget getWorkoutCardWidget(AsyncSnapshot<List<Workout>?> snapshot){
    if (snapshot.hasData) {
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
            workoutBloc.getWorkoutsByName(value.toLowerCase());
          },
        ),

        //list of workouts
        Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) =>
                  buildWorkoutCard(
                      context, index, snapshot.data)),
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
      int typeIndex, Workout workout) async {
    //default the name
    TextEditingController workoutController =
    TextEditingController(text: workout.name);

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
                        controller: workoutController,
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

                        bool isDupe = await repo.workoutNameExists(workoutController.text);


                        //finish validation and exit async call
                        setNewState(() {
                          if (isDupe && workoutController.text.toLowerCase() != workout.name.toLowerCase()) {
                            isInvalidName = true;
                          } else {
                            isInvalidName = false;
                          }
                          inAsyncCall = false;
                        });
                        if (!isInvalidName) {
                          workout.name = workoutController.text;
                          workout.type = typeIndexController!;
                          if (!add) {
                            //await repo.updateWorkout(workout);
                            await workoutBloc.updateWorkout(workout: workout, workoutName: searchController.text.isEmpty ? null : searchController.text);
                            await repo.updateWorkoutHistoryByWorkout(
                                workout.id, workoutController.text);
                            await repo.updateRoutineEntryByWorkout(
                                workout.id, workout.type, workoutController.text);
                          } else {
                            //repo.saveWorkout(workout);
                            workoutBloc.addWorkout(workout: workout, workoutName: searchController.text.isEmpty ? null : searchController.text);
                          }
                          // if(searchController.text.isNotEmpty){
                          //   workoutBloc.getWorkoutsByName(searchController.text.toLowerCase());
                          // } else {
                          //   workoutBloc.getWorkouts();
                          // }
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
                    await repo.workoutHistoryByWorkout(workout.id);
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
                    await repo.workoutHistoryByWorkout(workout.id);

                    List<RoutineEntry>? routineEntriesForWorkout =
                    await repo.routineEntryByWorkout(workout.id);
                    if (historyForWorkout == null && routineEntriesForWorkout == null) {
                      await workoutBloc.deleteWorkout(workout: workout);
                    } else {
                      return cantDeleteAlert();
                    }
                    // setState(() {
                    //   workouts = _readAllWorkouts();
                    // });
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
                    Text(Workout().workoutTypeString(
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