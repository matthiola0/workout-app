// lib/workout_data.dart

import 'package:flutter/material.dart';
import 'dart:collection';

// 定義重量單位的列舉
enum WeightUnit { kg, lbs }

// 代表單一組數
class ExerciseSet {
  String reps;      // e.g., "10"
  String weight;    // e.g., "60"
  String? lastReps;   // 上次完成的次數 (nullable)
  String? lastWeight; // // 上次完成的重量 (nullable)
  bool isCompleted;

  ExerciseSet({
    required this.reps,
    required this.weight,
    this.lastReps,
    this.lastWeight,
    this.isCompleted = false,
  });
}

// 代表一個完整的運動項目
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
    // 使用新的資料結構更新預設資料
    WorkoutRoutine(
      name: "胸肌日 - 中級",
      exercises: [
        Exercise(name: "平板臥推", restTimeInSeconds: 90, weightUnit: WeightUnit.kg, sets: [
          ExerciseSet(reps: "10", weight: "60", lastReps: "10", lastWeight: "55"),
          ExerciseSet(reps: "10", weight: "60", lastReps: "9", lastWeight: "55"),
          ExerciseSet(reps: "8", weight: "60"), // 新增的組，沒有上次紀錄
        ]),
        Exercise(name: "上斜啞鈴臥推", restTimeInSeconds: 60, weightUnit: WeightUnit.lbs, sets: [
          ExerciseSet(reps: "12", weight: "45", lastReps: "12", lastWeight: "40"),
          ExerciseSet(reps: "12", weight: "45", lastReps: "11", lastWeight: "40"),
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

  // 儲存訓練紀錄與更新菜單
  void saveWorkoutLog(int routineIndex, List<Exercise> completedExercises, bool updateRoutineStructure) {
    // 取得原始菜單
    final originalRoutine = _routines[routineIndex];

    // 更新歷史紀錄 (這步無論如何都會執行)
    for (int i = 0; i < completedExercises.length; i++) {
      // 如果原始菜單裡還有這個動作，就更新它
      if (i < originalRoutine.exercises.length) {
        final completedExercise = completedExercises[i];
        final originalExercise = originalRoutine.exercises[i];

        for (int j = 0; j < completedExercise.sets.length; j++) {
          // 如果原始菜單的動作裡還有這個組數，就更新它
          if (j < originalExercise.sets.length) {
            final completedSet = completedExercise.sets[j];
            // 把這次完成的紀錄，存為下次的「上次紀錄」
            originalExercise.sets[j].lastReps = completedSet.reps;
            originalExercise.sets[j].lastWeight = completedSet.weight;
          }
        }
      }
    }

    // 如果使用者選擇要儲存結構變更
    if (updateRoutineStructure) {
      // 直接用訓練完成後的結構替換掉原始菜單的結構
      originalRoutine.exercises.clear();
      originalRoutine.exercises.addAll(completedExercises.map((ex) => 
        Exercise(
          name: ex.name,
          restTimeInSeconds: ex.restTimeInSeconds,
          weightUnit: ex.weightUnit,
          // 在存回範本時，只保留目標值和歷史值，不儲存 isCompleted 狀態
          sets: ex.sets.map((s) => ExerciseSet(
            reps: s.reps, 
            weight: s.weight, 
            lastReps: s.lastReps, 
            lastWeight: s.lastWeight
          )).toList()
        )
      ).toList());
    }

    notifyListeners(); // 通知 UI 更新
  }

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