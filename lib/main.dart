import 'package:flutter/material.dart';
import 'routes.dart';
import 'UserData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 초기화를 위한 설정

  final userService = UserService(); // Singleton 인스턴스 생성
  await userService.fetchAllData(); // 사용자 및 포스트 데이터 초기화

  runApp(HyFiveApp());
}

class HyFiveApp extends StatelessWidget {
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
    );
  }
}