// lib/exercise_library.dart

// 定義動作分類的列舉
enum ExerciseCategory {
  chest('胸'),
  shoulder('肩'),
  back('背'),
  arm('手臂'),
  core('核心'),
  leg('腿'),
  cardio('有氧'),
  other('其他');

  const ExerciseCategory(this.displayName);
  final String displayName;
}

// 定義一個標準庫動作的資料結構
class LibraryExercise {
  final String name;
  final String imagePath;
  final ExerciseCategory category;
  final String description;

  LibraryExercise({
    required this.name,
    required this.imagePath,
    required this.category,
    this.description = '', // 描述可選
  });
}

// 建立一個全域的、包含所有預設動作的列表
// final List<LibraryExercise> exerciseLibrary = [
//   LibraryExercise(
//     name: 'dumbbell_shoulder_press',
//     imagePath: 'assets/images/dumbbell_shoulder_press.jpg',
//     category: ExerciseCategory.shoulder,
//   ),
//   LibraryExercise(
//     name: 'hammer_dumbbell_curl',
//     imagePath: 'assets/images/hammer_dumbbell_curl.jpg',
//     category: ExerciseCategory.arm,
//   ),
//   LibraryExercise(
//     name: '平板臥推',
//     imagePath: '',
//     category: ExerciseCategory.chest,
//     description: '發展胸大肌、前三角肌和三頭肌的主要動作。',
//   ),
//   LibraryExercise(
//     name: '深蹲',
//     imagePath: '',
//     category: ExerciseCategory.leg,
//     description: '全身性的力量訓練動作，主要鍛鍊股四頭肌、臀大肌和腿後腱肌群。',
//   ),
//   LibraryExercise(
//     name: '硬舉',
//     imagePath: '',
//     category: ExerciseCategory.back,
//     description: '一個複合式動作，能有效訓練背部、臀部和腿後側肌群。',
//   ),
//   LibraryExercise(
//     name: '肩推',
//     imagePath: '',
//     category: ExerciseCategory.shoulder,
//   ),
//   LibraryExercise(
//     name: '引體向上',
//     imagePath: '',
//     category: ExerciseCategory.back,
//   ),
//   // TODO: 增加更多動作 ...
// ];