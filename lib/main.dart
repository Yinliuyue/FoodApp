// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/favorite_provider.dart';
import 'Utils/constants.dart';
import 'Views/app_main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        // 注册其他 Provider 如有需要
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniApp',
      theme: ThemeData(
        primaryColor: kprimaryColor,
        scaffoldBackgroundColor: kbackgroundColor,
        // 配置其他主题参数
      ),
      home: const AppMainScreen(),
    );
  }
}