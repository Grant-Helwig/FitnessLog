import 'package:hey_workout/repository/workout_repository.dart';
import 'dart:async';
import '../model/workout_history.dart';

class WorkoutHistoryBloc {
  final repo = WorkoutRepository();

  final _workoutHistoryController = StreamController<List<WorkoutHistory>?>.broadcast();

  get workoutHistory => _workoutHistoryController.stream;

  WorkoutBloc() {
    getWorkoutHistory();
  }

  getWorkoutHistory() async {
    _workoutHistoryController.sink.add(await repo.readAllWorkoutHistory());
  }

  addWorkout(WorkoutHistory workoutHistory) async {
    await repo.saveWorkoutHistory(workoutHistory);
    getWorkoutHistory();
  }

  updateWorkout(WorkoutHistory workoutHistory) async {
    await repo.updateWorkoutHistory(workoutHistory);
    getWorkoutHistory();
  }

  deleteWorkout(WorkoutHistory workoutHistory) async {
    await repo.deleteWorkoutHistory(workoutHistory.id);
    getWorkoutHistory();
  }
}