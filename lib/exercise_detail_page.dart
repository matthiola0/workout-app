// lib/exercise_detail_page.dart

import 'package:flutter/material.dart';
import 'workout_data.dart';
import 'exercise_library.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late ExerciseCategory _selectedCategory;
  // 在這裡操作的是傳入 exercise 的一個副本

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
    _descriptionController = TextEditingController(text: widget.exercise.description);
    _selectedCategory = widget.exercise.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveAndReturn() {
    // 當儲存時，我們更新原始 widget.exercise 的屬性
    widget.exercise.name = _nameController.text;
    widget.exercise.description = _descriptionController.text;
    widget.exercise.category = _selectedCategory;
    // 然後將這個被修改過的 exercise 物件回傳
    Navigator.pop(context, widget.exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('動作詳情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAndReturn,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 動作圖片
          widget.exercise.imagePath.isNotEmpty
              ? Image.asset(widget.exercise.imagePath, height: 200, fit: BoxFit.contain)
              : Container(height: 200, color: Colors.grey[300], child: const Icon(Icons.image, size: 100, color: Colors.grey)),
          const SizedBox(height: 20),

          // 動作名稱編輯
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '動作名稱', border: OutlineInputBorder()),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 分類選擇下拉選單
          DropdownButtonFormField<ExerciseCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(labelText: '動作分類', border: OutlineInputBorder()),
            items: ExerciseCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.displayName),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCategory = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 20),

          // 動作描述編輯
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: '動作描述', border: OutlineInputBorder()),
            maxLines: 5,
            minLines: 3,
          ),
        ],
      ),
    );
  }
}