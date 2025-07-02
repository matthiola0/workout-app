// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'workout_data.dart';
import 'routines_page.dart';
import 'workout_in_progress_page.dart';

void main() {
  // 使用 ChangeNotifierProvider 來提供 WorkoutData 實例給整個 App
  runApp(
    ChangeNotifierProvider(
      create: (context) => WorkoutData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '運動App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 將 MainScaffold 設為首頁
      home: const MainScaffold(),
    );
  }
}

// 主框架 (底部導覽列)
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // 將 RoutinesPage 加入我們的頁面列表
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    RoutinesPage(), // 第二個 Tab 改成菜單管理頁
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '主頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt), // 改成列表圖示
            label: '我的菜單',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '個人檔案',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


// 主頁
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // 顯示菜單選擇的對話框
  void _showRoutineSelectionDialog(BuildContext context) {
    final workoutData = Provider.of<WorkoutData>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('選擇要使用的菜單'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: workoutData.routines.length,
              itemBuilder: (context, index) {
                final routine = workoutData.routines[index];
                return ListTile(
                  title: Text(routine.name),
                  onTap: () {
                    // 關閉對話框
                    Navigator.of(context).pop();
                    // 導航到運動中頁面，並傳入選擇的菜單
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutInProgressPage(
                          // *** 傳入選擇的菜單 ***
                          routine: routine,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今天，準備好揮灑汗水了嗎？'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
              shape: const CircleBorder(),
              elevation: 8,
            ),
            // 按下按鈕後，顯示菜單選擇對話框
            onPressed: () => _showRoutineSelectionDialog(context),
            child: const Text(
              '開始\n運動',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// 個人檔案頁 (佔位)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('個人主頁'),
      ),
      body: const Center(
        child: Text(
          '這裡將會顯示您的運動月曆和成就獎盃！',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}