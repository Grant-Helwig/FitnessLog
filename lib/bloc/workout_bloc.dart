import 'package:hey_workout/repository/workout_repository.dart';
import 'dart:async';
import '../model/workout.dart';

class WorkoutBloc {
  final repo = WorkoutRepository();

  final _workoutController = StreamController<List<Workout>?>.broadcast();

  get workouts => _workoutController.stream;

  WorkoutBloc() {
    getWorkouts();
  }

  getWorkouts() async {
    _workoutController.sink.add(await repo.readAllWorkouts());
  }

  getWorkoutsByName(String workoutName) async {
    _workoutController.sink.add(await repo.readAllWorkoutsByName(workoutName));
  }

  addWorkout(Workout workout) async {
    await repo.saveWorkout(workout);
    getWorkouts();
  }

  updateWorkout(Workout workout) async {
    await repo.updateWorkout(workout);
    getWorkouts();
  }

  deleteWorkout(Workout workout) async {
    await repo.deleteWorkout(workout.id);
    getWorkouts();
  }

  Future<bool> workoutNameExists(String workoutName) async{
    return repo.workoutNameExists(workoutName);
  }
}