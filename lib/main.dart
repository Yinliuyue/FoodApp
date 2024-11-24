
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/favorite_provider.dart';
import 'Provider/quantity.dart';
import 'Views/app_main_screen.dart';
import 'Utils/database_helper.dart'; // 引入数据库助手

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库
  await DatabaseHelper().database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => QuantityProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 应用的根部件
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppMainScreen(),
    );
  }
}

