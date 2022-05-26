import 'package:hey_workout/repository/workout_repository.dart';
import 'dart:async';
import '../model/workout.dart';

class WorkoutBloc {
  final repo = WorkoutRepository();

  final _workoutController = StreamController<List<Workout>?>.broadcast();

  final _activeWorkoutController = StreamController<Workout?>.broadcast();

  Stream<List<Workout>?> get workouts => _workoutController.stream;

  Stream<Workout?> get activeWorkout => _activeWorkoutController.stream;

  WorkoutBloc({Workout? workout}) {
    getWorkouts();

    setActiveWorkout(workout: workout);
  }

  getWorkouts() async {
    _workoutController.sink.add(await repo.readAllWorkouts());
  }

  getWorkoutsByName(String workoutName) async {
    _workoutController.sink.add(await repo.readAllWorkoutsByName(workoutName));
  }

  getWorkoutsConditional({String? workoutName}) async {
    if(workoutName != null){
      getWorkoutsByName(workoutName);
    } else {
      getWorkouts();
    }
  }

  addWorkout({required Workout workout, String? workoutName}) async {
    await repo.saveWorkout(workout);
    getWorkoutsConditional(workoutName: workoutName);
  }

  updateWorkout({required Workout workout, String? workoutName}) async {
    await repo.updateWorkout(workout);
    getWorkoutsConditional(workoutName: workoutName);
  }

  deleteWorkout({required Workout workout, String? workoutName}) async {
    await repo.deleteWorkout(workout.id);
    getWorkoutsConditional(workoutName: workoutName);
  }

  setActiveWorkout({Workout? workout}){
    _activeWorkoutController.sink.add(workout);
  }
}