// lib/workout_in_progress_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'workout_data.dart';
import 'exercise_selection_page.dart';
import 'exercise_detail_page.dart';

class WorkoutInProgressPage extends StatefulWidget {
  final WorkoutRoutine routine;
  final int routineIndex;

  const WorkoutInProgressPage({
    super.key,
    required this.routine,
    required this.routineIndex,
  });

  @override
  State<WorkoutInProgressPage> createState() => _WorkoutInProgressPageState();
}

class _WorkoutInProgressPageState extends State<WorkoutInProgressPage> {
  late Timer _timer;
  int _totalSeconds = 0;
  late List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // 深拷貝，確保有自己的獨立副本 (此處邏輯需一併更新)
    _exercises = widget.routine.exercises.map((ex) =>
        Exercise(
          name: ex.name,
          imagePath: ex.imagePath,
          category: ex.category,
          description: ex.description,
          restTimeInSeconds: ex.restTimeInSeconds,
          weightUnit: ex.weightUnit,
          sets: ex.sets.map((s) =>
            ExerciseSet(reps: s.reps, weight: s.weight, lastReps: s.lastReps, lastWeight: s.lastWeight, isCompleted: false)).toList()
        )
    ).toList();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() { _totalSeconds++; });
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _showRestDialog(int restSeconds) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RestTimerDialog(restSeconds: restSeconds);
      },
    );
  }

  void _showEndWorkoutDialog() {
    _timer.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('儲存本次訓練?'),
        content: const Text('是否將本次訓練中新增的動作或組數，更新到您的原始菜單中？\n(注意：無論如何，本次的訓練表現都會被記錄下來)'),
        actions: [
          TextButton(
            child: const Text('不，保留原始菜單'),
            onPressed: () {
              Provider.of<WorkoutData>(context, listen: false)
                  .saveWorkoutLog(widget.routineIndex, _exercises, false);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          FilledButton(
            child: const Text('是，更新菜單'),
            onPressed: () {
              Provider.of<WorkoutData>(context, listen: false)
                  .saveWorkoutLog(widget.routineIndex, _exercises, true);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
  
  // 處理從選擇頁回傳的 Exercise 物件
  void _addExercise() async {
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

  // 處理跳轉到詳情頁的邏輯
  void _editExerciseDetails(Exercise exercise) async {
    await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(builder: (context) => ExerciseDetailPage(exercise: exercise)),
    );
    
    // 我們只需要呼叫 setState 來刷新 UI 即可。
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.routine.name} - ${_formatDuration(_totalSeconds)}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, exerciseIndex) {
                final exercise = _exercises[exerciseIndex];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: InkWell(
                      onTap: () => _editExerciseDetails(exercise), // 點擊時呼叫新方法
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          exercise.name, // 直接顯示名稱
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
                    subtitle: Text(exercise.category.displayName), // 順便顯示分類
                    initiallyExpanded: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(text: exercise.restTimeInSeconds.toString()),
                                    decoration: const InputDecoration(labelText: '組間休息(秒)', border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        exercise.restTimeInSeconds = int.tryParse(value) ?? 60;
                                      });
                                    },
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
                              ExerciseSet currentSet = entrySet.value;
                              String lastRecord = (currentSet.lastReps != null && currentSet.lastWeight != null)
                                  ? "上次: ${currentSet.lastReps} x ${currentSet.lastWeight} ${exercise.weightUnit.name}"
                                  : "上次: 無紀錄";
                              
                              return CheckboxListTile(
                                isThreeLine: true,
                                title: Row(
                                  children: [
                                    Text("第 ${setIndex + 1} 組: "),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 80,
                                      child: TextFormField(
                                        initialValue: currentSet.reps,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(labelText: '次數'),
                                        onChanged: (value) { currentSet.reps = value; },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 80,
                                      child: TextFormField(
                                        initialValue: currentSet.weight,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(labelText: '重量 (${exercise.weightUnit.name})'),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) { currentSet.weight = value; },
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(lastRecord, style: TextStyle(color: Colors.grey[600])),
                                value: currentSet.isCompleted,
                                onChanged: (bool? value) {
                                  setState(() { currentSet.isCompleted = value ?? false; });
                                  if (currentSet.isCompleted) {
                                    _showRestDialog(exercise.restTimeInSeconds);
                                  }
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                              );
                            }).toList(),
                            TextButton(
                              child: const Text('+ 新增組數'),
                              onPressed: () {
                                setState(() { exercise.sets.add(ExerciseSet(reps: '', weight: '')); });
                              },
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
              child: const Text('+ 新增動作'),
              onPressed: _addExercise,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              onPressed: _showEndWorkoutDialog,
              child: const Text('結束運動', style: TextStyle(fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }
}

class RestTimerDialog extends StatefulWidget {
  final int restSeconds;
  const RestTimerDialog({super.key, required this.restSeconds});

  @override
  _RestTimerDialogState createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<RestTimerDialog> {
  late Timer _restTimer;
  late int _currentSeconds;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.restSeconds;
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        setState(() { _currentSeconds--; });
      } else {
        _restTimer.cancel();
        if (mounted) { Navigator.of(context).pop(); }
      }
    });
  }

  @override
  void dispose() {
    _restTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('組間休息'),
      content: Text(
        '$_currentSeconds',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filled(
              icon: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (_currentSeconds > 10) {
                    _currentSeconds -= 10;
                  } else {
                    _currentSeconds = 0;
                  }
                });
              },
            ),
            TextButton(
              onPressed: () {
                _restTimer.cancel();
                Navigator.of(context).pop();
              },
              child: const Text('跳過'),
            ),
            IconButton.filled(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _currentSeconds += 10;
                });
              },
            ),
          ],
        )
      ],
    );
  }
}