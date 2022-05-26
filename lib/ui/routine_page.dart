

import 'package:flutter/material.dart';
import 'package:hey_workout/repository/workout_repository.dart';
import 'package:hey_workout/ui/routine_profile_page.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../model/routine.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({Key? key}) : super(key: key);

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  WorkoutRepository repo = WorkoutRepository();

  //also need a duplicate name validation for routines
  late Future<List<Routine>?> routines;
  bool inAsyncCall = false;
  bool isInvalidName = false;

  @override
  void initState() {
    super.initState();
    routines = repo.readAllRoutines();
  }

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
                        await repo.routineNameExists(routineController.text);

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
                          routine.name = routineController.text;

                          if (!add) {
                            routine.date = DateTime.now().toString();
                            repo.updateRoutine(routine);
                          } else {
                            //set datetime of routine to 0 if it has never been used
                            routine.date = DateTime(0).toString();
                            repo.saveRoutine(routine);
                          }
                          setState(() {
                            routines = repo.readAllRoutines();
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
                    var allEntries = await repo.routineEntryByRoutine(routine.id);
                    for (var element in allEntries!) {
                      repo.deleteRoutineEntry(element.id);
                    }
                    repo.deleteRoutine(routine.id);
                    setState(() {
                      routines = repo.readAllRoutines();
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
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        RoutineProfile(routine: curRoutines![index])));
            setState(() {
              routines = repo.readAllRoutines();
            });
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