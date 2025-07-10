// lib/routine_editor_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'workout_data.dart';
import 'exercise_selection_page.dart';
import 'exercise_library.dart';
import 'exercise_detail_page.dart';

class RoutineEditorPage extends StatefulWidget {
  final WorkoutRoutine routine;
  final int? routineIndex;
  final bool isNewRoutine;

  const RoutineEditorPage({
    super.key,
    required this.routine,
    this.routineIndex,
    this.isNewRoutine = false,
  });

  @override
  State<RoutineEditorPage> createState() => _RoutineEditorPageState();
}

class _RoutineEditorPageState extends State<RoutineEditorPage> {
  late TextEditingController _routineNameController;
  late List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _routineNameController = TextEditingController(text: widget.routine.name);
    _exercises = widget.routine.exercises.map((ex) =>
        Exercise(
          name: ex.name,
          restTimeInSeconds: ex.restTimeInSeconds,
          weightUnit: ex.weightUnit,
          sets: ex.sets.map((s) =>
            ExerciseSet(reps: s.reps, weight: s.weight, lastReps: s.lastReps, lastWeight: s.lastWeight)).toList()
        )
    ).toList();
  }

  @override
  void dispose() {
    _routineNameController.dispose();
    super.dispose();
  }

  void _saveRoutine() {
    final workoutData = Provider.of<WorkoutData>(context, listen: false);
    final updatedRoutine = WorkoutRoutine(
      name: _routineNameController.text,
      exercises: _exercises,
    );

    if (widget.isNewRoutine) {
      workoutData.addRoutine(updatedRoutine);
    } else {
      workoutData.updateRoutine(widget.routineIndex!, updatedRoutine);
    }
    Navigator.pop(context);
  }
  
  void _deleteRoutine() {
    final workoutData = Provider.of<WorkoutData>(context, listen: false);
    workoutData.deleteRoutine(widget.routineIndex!);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // 處理跳轉到選擇頁的邏輯
  void _addExercise() async {
    // 返回的可能是一個從庫裡選的，或是自訂的 Exercise 物件
    final selectedExercise = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(builder: (context) => const ExerciseSelectionPage()),
    );

    if (selectedExercise != null) {
      setState(() {
        _exercises.add(selectedExercise);
      });
    }
  }

  void _editExerciseDetails(Exercise exercise) async {
    // 等待使用者從詳情頁回傳更新後的 exercise 物件
    final updatedExercise = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(builder: (context) => ExerciseDetailPage(exercise: exercise)),
    );

    if (updatedExercise != null) {
      setState(() {
        // exercise 是 class，只需要呼叫 setState 來刷新 UI 即可
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewRoutine ? '建立新菜單' : '編輯菜單'),
        actions: [
          if (!widget.isNewRoutine)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: _deleteRoutine,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRoutine,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _routineNameController,
              decoration: const InputDecoration(
                labelText: '菜單名稱',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, exerciseIndex) {
                  final exercise = _exercises[exerciseIndex];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text(exercise.category.displayName), // 顯示動作分類
                          trailing: IconButton( // 將刪除按鈕放到這裡
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                _exercises.removeAt(exerciseIndex);
                              });
                            },
                          ),
                          onTap: () => _editExerciseDetails(exercise), // 整個 ListTile 都可以點擊
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              // 休息時間和單位設定
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController(text: exercise.restTimeInSeconds.toString()),
                                      decoration: const InputDecoration(labelText: '組間休息(秒)', border: OutlineInputBorder()),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) { exercise.restTimeInSeconds = int.tryParse(value) ?? 60; },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SegmentedButton<WeightUnit>(
                                    segments: const <ButtonSegment<WeightUnit>>[
                                      ButtonSegment<WeightUnit>(value: WeightUnit.kg, label: Text('kg')),
                                      ButtonSegment<WeightUnit>(value: WeightUnit.lbs, label: Text('lbs')),
                                    ],
                                    selected: {exercise.weightUnit},
                                    onSelectionChanged: (Set<WeightUnit> newSelection) {
                                      setState(() {
                                        exercise.weightUnit = newSelection.first;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              ...exercise.sets.asMap().entries.map((entrySet) {
                                int setIndex = entrySet.key;
                                // 組數拆分為次數和重量
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("第 ${setIndex + 1} 組", style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: TextEditingController(text: entrySet.value.reps),
                                        decoration: const InputDecoration(labelText: '次數'),
                                        onChanged: (newReps) { entrySet.value.reps = newReps; },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: TextEditingController(text: entrySet.value.weight),
                                        decoration: const InputDecoration(labelText: '重量'),
                                        keyboardType: TextInputType.number,
                                        onChanged: (newWeight) { entrySet.value.weight = newWeight; },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.grey),
                                      onPressed: () { setState(() { exercise.sets.removeAt(setIndex); }); },
                                    ),
                                  ],
                                );
                              }).toList(),
                              TextButton(
                                child: const Text('新增組數'),
                                onPressed: () { setState(() { exercise.sets.add(ExerciseSet(reps: '', weight: '')); }); },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              child: const Text('新增運動項目'),
              onPressed: _addExercise, 
            )
          ],
        ),
      ),
    );
  }
}