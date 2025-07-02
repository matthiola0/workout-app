// lib/workout_in_progress_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'workout_data.dart';

class WorkoutInProgressPage extends StatefulWidget {
  final WorkoutRoutine routine;

  const WorkoutInProgressPage({super.key, required this.routine});

  @override
  State<WorkoutInProgressPage> createState() => _WorkoutInProgressPageState();
}

class _WorkoutInProgressPageState extends State<WorkoutInProgressPage> {
  late Timer _timer;
  int _totalSeconds = 0;
  // *** 這是當次訓練的獨立資料副本，修改它不會影響原始菜單 ***
  late List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // *** 建立一個可修改的深拷貝副本，供本次訓練使用 ***
    _exercises = widget.routine.exercises.map((ex) =>
        Exercise(
          name: ex.name,
          restTimeInSeconds: ex.restTimeInSeconds,
          weightUnit: ex.weightUnit,
          sets: ex.sets.map((s) =>
            ExerciseSet(reps: s.reps, weight: s.weight, isCompleted: false)).toList() // isCompleted 設為 false
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
      setState(() {
        _totalSeconds++;
      });
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  // *** 修改：讓休息對話框接收秒數 ***
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
              title: const Text('恭喜！'),
              content: Text('您已完成本次訓練！\n總計時間：${_formatDuration(_totalSeconds)}'),
              actions: [
                TextButton(
                  onPressed: () {
                    // TODO: 在這裡可以將 _exercises (包含訓練中的修改) 存成訓練日誌
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('完成'),
                )
              ],
            ));
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
                    title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text("組間休息: ${exercise.restTimeInSeconds} 秒"),
                    initiallyExpanded: true, // 預設展開
                    children: [
                      ...exercise.sets.asMap().entries.map((entrySet) {
                        int setIndex = entrySet.key;
                        ExerciseSet currentSet = entrySet.value;
                        
                        // *** 顯示可即時編輯的次數和重量輸入框 ***
                        return CheckboxListTile(
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
                          value: currentSet.isCompleted,
                          onChanged: (bool? value) {
                            setState(() {
                              currentSet.isCompleted = value ?? false;
                            });
                            if (currentSet.isCompleted) {
                              // *** 傳入該項目的特定休息秒數 ***
                              _showRestDialog(exercise.restTimeInSeconds);
                            }
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
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

// *** 修改：組間休息對話框接收秒數 ***
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
    _currentSeconds = widget.restSeconds; // 從 widget 接收初始秒數
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        setState(() {
          _currentSeconds--;
        });
      } else {
        _restTimer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
        }
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
        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _restTimer.cancel();
            Navigator.of(context).pop();
          },
          child: const Text('跳過'),
        )
      ],
    );
  }
}