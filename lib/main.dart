import 'package:flutter/material.dart';
import 'dart:async'; // Timer를 사용하기 위한 import
import 'routes.dart';
import 'UserData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 초기화를 위한 설정

  final userService = UserService(); // Singleton 인스턴스 생성
  await userService.fetchAllData(); // 사용자 및 포스트 데이터 초기화

  runApp(HyFiveApp(userService: userService)); // UserService를 전달
}

class HyFiveApp extends StatelessWidget {
  final UserService userService;

  HyFiveApp({required this.userService}); // UserService를 생성자에서 받음

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 표식 제거
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: Colors.white, // Scaffold 배경색을 흰색으로 설정
        appBarTheme: AppBarTheme(
          color: Colors.white, // AppBar 배경색을 흰색으로 설정
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          color: Colors.white, // BottomAppBar 배경색을 흰색으로 설정
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            textStyle: TextStyle(
              fontSize: 16, // 텍스트 크기를 반응형으로 설정
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0), // 둥근 모서리 설정
            ),
            side: BorderSide(color: Colors.grey[300]!), // 테두리 색상 설정
          ),
        ),
      ),
      initialRoute: '/home', // 홈 페이지를 Home으로 설정
      routes: routes,
      builder: (context, child) {
        return AppLifecycleObserver(
          userService: userService,
          child: child!,
        );
      },
    );
  }
}

class AppLifecycleObserver extends StatefulWidget {
  final Widget child;
  final UserService userService;

  AppLifecycleObserver({required this.child, required this.userService});

  @override
  _AppLifecycleObserverState createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startDataSync();
  }

  void _startDataSync() {
    // 주기적으로 데이터 갱신 (예: 10초마다)
    _syncTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await widget.userService.fetchAllData();
      print("데이터 동기화 완료");
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
