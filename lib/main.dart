// lib/main.dart

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '運動App', // [來源 1]
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // 定義App整體的字體和主題
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const MainScaffold(),
    );
  }
}

// 這個 Widget 負責 App 的主結構，包含底部的導覽列
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0; // 用來追蹤目前選中的頁面索引

  // 建立我們的頁面列表
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ProfilePage(), // 個人主頁（目前是空的）
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

// --- 主頁畫面 ---
// 根據您的規劃，主頁要顯示菜單與開始運動鍵 
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今天，準備好揮灑汗水了嗎？'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 顯示今日菜單的卡片 
            const Text(
              '今日菜單',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const ListTile(
                leading: Icon(Icons.fitness_center, color: Colors.deepPurple, size: 40),
                title: Text('胸肌日 - 中級', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('平板臥推, 上斜啞鈴臥推, 繩索飛鳥...'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            const SizedBox(height: 40),

            // 開始運動按鈕 
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // TODO: 按下後導航至運動中頁面
                print('開始運動按鈕被點擊！');
              },
              child: const Text('開始運動'),
            ),
            const SizedBox(height: 40),
            
            // 顯示其他菜單的區塊
            const Text(
              '我的所有菜單',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text('背肌日 - 初級'),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('腿部轟炸'),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// --- 個人主頁畫面 (目前是個佔位符) ---
// 未來這裡會放月曆、長條圖等 
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
          '這裡將會顯示您的運動月曆和成就獎盃！', // [cite: 4, 8]
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}