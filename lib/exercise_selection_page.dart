// lib/exercise_selection_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'exercise_library.dart';
import 'workout_data.dart';
import 'exercise_detail_page.dart';

class ExerciseSelectionPage extends StatefulWidget {
  const ExerciseSelectionPage({super.key});

  @override
  State<ExerciseSelectionPage> createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends State<ExerciseSelectionPage> {
  ExerciseCategory? _selectedCategory; // 可為 null，代表顯示全部

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, workoutData, child) {
        final filteredList = _selectedCategory == null
            ? workoutData.masterExerciseList
            : workoutData.masterExerciseList.where((ex) => ex.category == _selectedCategory).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('選擇動作'),
            actions: [
              // 自訂新動作的按鈕
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: '自訂新動作',
                onPressed: () async {
                  final newCustomExercise = Exercise(  // 直接在這裡建立新物件
                    name: '',
                    sets: [
                      ExerciseSet(reps: '', weight: ''),
                      ExerciseSet(reps: '', weight: ''),
                      ExerciseSet(reps: '', weight: ''),
                      ExerciseSet(reps: '', weight: ''),
                    ],
                    category: _selectedCategory ?? ExerciseCategory.other,
                  );

                  final createdExercise = await Navigator.push<Exercise>(
                    context,
                    MaterialPageRoute(builder: (context) => ExerciseDetailPage(exercise: newCustomExercise)),
                  );

                  if (createdExercise != null && createdExercise.name.isNotEmpty) {
                    // 將新動作存入總列表
                    workoutData.addExerciseToLibrary(createdExercise);
                    // 然後再回傳給前一頁
                    Navigator.pop(context, createdExercise);
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<ExerciseCategory>(
                  value: _selectedCategory,
                  hint: const Text('所有分類'),
                  isExpanded: true,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: ExerciseCategory.values.map((category) {
                    return DropdownMenuItem(value: category, child: Text(category.displayName));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() { _selectedCategory = newValue; });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final exerciseTemplate = filteredList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        // 在顯示圖片前先檢查路徑是否為空
                        leading: exerciseTemplate.imagePath.isNotEmpty
                          ? Image.asset(exerciseTemplate.imagePath, width: 60, height: 60, fit: BoxFit.cover)
                          : const SizedBox(width: 60, height: 60, child: Icon(Icons.image, color: Colors.grey)),
                        title: Text(exerciseTemplate.name),
                        subtitle: Text(exerciseTemplate.category.displayName),
                        onTap: () {
                          // 當選擇一個範本時，我們建立一個它的副本來加入菜單
                          // 這樣可以避免後續修改影響到總列表中的範本
                          final newExerciseForRoutine = Exercise(
                            name: exerciseTemplate.name,
                            imagePath: exerciseTemplate.imagePath,
                            category: exerciseTemplate.category,
                            description: exerciseTemplate.description,
                            sets: exerciseTemplate.sets.map((s) => ExerciseSet(reps: s.reps, weight: s.weight)).toList(),
                          );
                          Navigator.pop(context, newExerciseForRoutine);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}