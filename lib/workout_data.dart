// lib/workout_data.dart

import 'package:flutter/material.dart';
import 'dart:collection';

// *** 定義重量單位的列舉 ***
enum WeightUnit { kg, lbs }

// *** ：代表單一組數 ***
class ExerciseSet {
  String reps;      // e.g., "10"
  String weight;    // e.g., "60"
  bool isCompleted;

  ExerciseSet({
    required this.reps,
    required this.weight,
    this.isCompleted = false,
  });
}

// *** 代表一個完整的運動項目 ***
class Exercise {
  String name;
  final List<ExerciseSet> sets;
  int restTimeInSeconds; // 組間休息秒數
  WeightUnit weightUnit;   // 重量單位

  Exercise({
    required this.name,
    required this.sets,
    this.restTimeInSeconds = 60, // 預設 60 秒
    this.weightUnit = WeightUnit.kg, // 預設公斤
  });
}

// 代表一個完整的訓練菜單 (不變)
class WorkoutRoutine {
  String name;
  final List<Exercise> exercises;
  WorkoutRoutine({ required this.name, required this.exercises });
}


// --- 狀態管理中心 (State Management) ---
class WorkoutData extends ChangeNotifier {
  final List<WorkoutRoutine> _routines = [
    // *** 使用新的資料結構更新預設資料 ***
    WorkoutRoutine(
      name: "胸肌日 - 中級",
      exercises: [
        Exercise(name: "平板臥推", restTimeInSeconds: 90, weightUnit: WeightUnit.kg, sets: [
          ExerciseSet(reps: "10", weight: "60"),
          ExerciseSet(reps: "10", weight: "60"),
          ExerciseSet(reps: "8", weight: "60"),
        ]),
        Exercise(name: "上斜啞鈴臥推", restTimeInSeconds: 60, weightUnit: WeightUnit.lbs, sets: [
          ExerciseSet(reps: "12", weight: "45"),
          ExerciseSet(reps: "12", weight: "45"),
          ExerciseSet(reps: "11", weight: "45"),
        ]),
      ],
    ),
    WorkoutRoutine(
      name: "腿部轟炸",
      exercises: [
        Exercise(name: "深蹲", restTimeInSeconds: 120, sets: [
          ExerciseSet(reps: "8", weight: "100"),
          ExerciseSet(reps: "8", weight: "100"),
          ExerciseSet(reps: "6", weight: "100"),
        ]),
      ],
    ),
  ];

  UnmodifiableListView<WorkoutRoutine> get routines => UnmodifiableListView(_routines);

  // 以下方法不變...
  void addRoutine(WorkoutRoutine routine) {
    _routines.add(routine);
    notifyListeners();
  }

  void deleteRoutine(int index) {
    _routines.removeAt(index);
    notifyListeners();
  }
  
  void updateRoutine(int index, WorkoutRoutine routine) {
    _routines[index] = routine;
    notifyListeners();
  }

  void addExercise(int routineIndex, Exercise exercise) {
    _routines[routineIndex].exercises.add(exercise);
    notifyListeners();
  }

  void addSet(int routineIndex, int exerciseIndex, ExerciseSet set) {
     _routines[routineIndex].exercises[exerciseIndex].sets.add(set);
     notifyListeners();
  }

  void deleteExercise(int routineIndex, int exerciseIndex) {
    _routines[routineIndex].exercises.removeAt(exerciseIndex);
    notifyListeners();
  }

  void deleteSet(int routineIndex, int exerciseIndex, int setIndex) {
    _routines[routineIndex].exercises[exerciseIndex].sets.removeAt(setIndex);
    notifyListeners();
  }
}