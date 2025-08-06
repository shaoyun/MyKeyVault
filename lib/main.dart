import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/account_provider.dart';
import 'package:myapp/screens/home_screen.dart'; // 将 MyHomePage 改名为 HomeScreen
import 'package:myapp/utils/time_sync.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化账户提供者
  final accountProvider = AccountProvider();
  await accountProvider.loadAccounts();
  
  // 时间同步已简化为使用本机时间
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => accountProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 定义主题配色
    final Color primarySeedColor = Color(0xFF1A237E); // 深蓝色
    final Color secondaryColor = Color(0xFF673AB7); // 紫色
    final Color lightGray = Color(0xFFE0E0E0); // 浅灰色

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
        primary: primarySeedColor,
        secondary: secondaryColor,
        surface: Colors.white,
        onSurface: Colors.black87,
        background: lightGray, // 使用浅灰色作为背景
        onBackground: Colors.black87,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
      cardColor: Colors.white,
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.black87),
        titleMedium: TextStyle(color: Colors.black87),
        headlineSmall: TextStyle(color: Colors.black87),
      ),
      // ListTile 文本颜色调整
      listTileTheme: ListTileThemeData(
        textColor: Colors.black87,
        iconColor: Colors.black54,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
        primary: secondaryColor, // 深色模式下，紫色作为主色可能更突出
        secondary: primarySeedColor,
        surface: Color(0xFF424242), // 更深的灰色作为表面
        onSurface: Colors.white70,
        background: Color(0xFF303030), // 深色背景
        onBackground: Colors.white70,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF424242), // 深色背景
        foregroundColor: Colors.white,
         titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
      cardColor: Color(0xFF424242),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.white70),
         titleMedium: TextStyle(color: Colors.white70),
         headlineSmall: TextStyle(color: Colors.white),
      ),
       // ListTile 文本颜色调整
      listTileTheme: ListTileThemeData(
        textColor: Colors.white70,
        iconColor: Colors.white60,
      ),
    );


    return MaterialApp(
      title: 'OneTimePass',
      theme: lightTheme, // 使用浅色主题
      darkTheme: darkTheme, // 使用深色主题
      themeMode: ThemeMode.system, // 默认使用系统主题
      home: const HomeScreen(),
      // 将路由定义移到 HomeScreen 内部或使用命名路由
      // 推荐使用命名路由或 GoRouter 等路由管理方案
    );
  }
}
