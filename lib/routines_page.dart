// lib/routines_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'workout_data.dart';
import 'routine_editor_page.dart'; // 我們下一步會建立這個檔案

class RoutinesPage extends StatelessWidget {
  const RoutinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, workoutData, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('管理我的菜單'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  // 跳轉到編輯頁來建立新菜單
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutineEditorPage(
                        // 傳入一個全新的 Routine 物件
                        routine: WorkoutRoutine(name: '新菜單', exercises: []),
                        isNewRoutine: true, // 告訴編輯頁這是全新的
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: workoutData.routines.length,
            itemBuilder: (context, index) {
              final routine = workoutData.routines[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(routine.name),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    // 跳轉到編輯頁來修改現有菜單
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoutineEditorPage(
                          routine: routine,
                          routineIndex: index, // 傳入索引值，方便更新
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}