import 'dart:developer';

import 'package:hey_workout/repository/workout_repository.dart';
import 'dart:async';
import '../model/routine.dart';

class RoutineBloc {
  final repo = WorkoutRepository();

  final _routineController = StreamController<List<Routine>?>.broadcast();

  final _activeRoutineController = StreamController<Routine?>.broadcast();

  Stream<List<Routine>?> get routines => _routineController.stream;

  Stream<Routine?> get activeRoutine => _activeRoutineController.stream;

  RoutineBloc({Routine? routine, bool? isDropdown}) {
    if(isDropdown != null){
      if(isDropdown){
        getRoutinesForDropdown();
      } else {
        getRoutines();
      }
    } else {
      getRoutines();
    }
    setActiveRoutine(routine: routine);
  }

  getRoutines() async {
    _routineController.sink.add(await repo.readAllRoutines());
    log(_routineController.stream.length.toString());
  }

  getRoutinesForDropdown() async {
    _routineController.sink.add(await repo.readAllRoutinesDropdown());
  }
  addRoutine({required Routine routine}) async {
    await repo.saveRoutine(routine);
    getRoutines();
  }

  updateRoutine({required Routine routine}) async {
    await repo.updateRoutine(routine);
    getRoutines();
  }

  deleteRoutine({required Routine routine}) async {
    await repo.deleteRoutine(routine.id);
    getRoutines();
  }

  setActiveRoutine({Routine? routine}) async{
    _activeRoutineController.sink.add(routine);
  }
}