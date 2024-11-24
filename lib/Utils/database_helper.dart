// lib/Utils/database_helper.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart'; // 用于 kReleaseMode
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

// 为 models 导入添加前缀
import 'package:miniapp/models/category.dart' as model;
import 'package:miniapp/models/food_item.dart';

class DatabaseHelper {
  // 单例模式
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "minidb.db");

    bool exists = await databaseExists(path);
    print("数据库存在: $exists at path: $path");

    if (!exists || !kReleaseMode) { // 开发模式下每次复制
      print("数据库不存在或开发模式，准备从 assets 中复制...");
      try {
        // 加载资产中的数据库文件
        ByteData data = await rootBundle.load(join('assets', 'minidb.db'));
        List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        // 确保目标目录存在
        await Directory(dirname(path)).create(recursive: true);

        // 写入数据库文件
        await File(path).writeAsBytes(bytes, flush: true);
        print("数据库已成功复制到: $path");
      } catch (e) {
        print("复制数据库文件失败: $e");
      }
    }

    // 打开数据库
    Database db = await openDatabase(
      path,
      version: 2, // 更新的版本号
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return db;
  }

  // 创建数据库表
  FutureOr<void> _onCreate(Database db, int version) async {
    print("创建数据库表...");
    // 创建食物类别表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS food_category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''');

    // 创建食物项表，移除 ingredients 字段
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Complete_Flutter_App (
        id_every INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cal INTEGER NOT NULL,
        category TEXT NOT NULL,
        image_path TEXT NOT NULL,
        rate REAL NOT NULL,
        reviews INTEGER NOT NULL,
        time INTEGER NOT NULL
      );
    ''');

    // 创建收藏表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_item_id INTEGER NOT NULL,
        FOREIGN KEY (food_item_id) REFERENCES Complete_Flutter_App (id_every) ON DELETE CASCADE
      );
    ''');

    // 插入初始数据（可选）
    await _insertInitialData(db);
  }

  // 数据库升级
  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("升级数据库，从版本 $oldVersion 到 $newVersion");
    if (oldVersion < 2) {
      // 示例：插入推荐食物项
      await db.execute('''
        INSERT INTO Complete_Flutter_App (name, cal, category, image_path, rate, reviews, time)
        VALUES 
          ('推荐食物1', 300, 'CategoryName', 'image1.png', 4.5, 100, 30),
          ('推荐食物2', 250, 'CategoryName', 'image2.png', 4.7, 150, 25)
      ''');
      print("推荐食物项已插入");
    }
    // 如果未来有更多版本，可以在此处继续添加升级逻辑
  }

  // 插入初始数据（可选）
  Future<void> _insertInitialData(Database db) async {
    // 插入类别数据
    await db.insert('food_category', {'name': 'All'});
    await db.insert('food_category', {'name': 'Category1'});
    await db.insert('food_category', {'name': 'Category2'});
    // 插入更多类别或食物项
    print("初始数据已插入");
  }

  // 获取所有类别
  Future<List<model.Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('food_category');

    if (maps.isEmpty) {
      print('food_category 表中没有数据');
    } else {
      print('food_category 表中的数据:');
      for (var row in maps) {
        print(row);
      }
    }

    return List.generate(maps.length, (i) {
      return model.Category.fromMap(maps[i]);
    });
  }

  // 获取食物项列表，可按类别过滤
  Future<List<FoodItem>> getFoodItems({String? category}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (category == null || category == "All") {
      maps = await db.query('Complete_Flutter_App');
    } else {
      maps = await db.query(
        'Complete_Flutter_App',
        where: 'category = ?',
        whereArgs: [category],
      );
    }

    if (maps.isEmpty) {
      print('Complete_Flutter_App 表中没有数据');
    } else {
      print('Complete_Flutter_App 表中的数据:');
      for (var row in maps) {
        print(row);
      }
    }

    return List.generate(maps.length, (i) {
      return FoodItem.fromMap(maps[i]);
    });
  }

  // 获取单个食物项，通过 id_every
  Future<FoodItem?> getFoodItemById(int idEvery) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'Complete_Flutter_App',
      where: 'id_every = ?',
      whereArgs: [idEvery],
    );

    if (maps.isNotEmpty) {
      return FoodItem.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // 搜索食物项
  Future<List<FoodItem>> searchFoodItems(String query,
      {String? category}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (category != null && category != "All") {
      whereClause += 'category = ?';
      whereArgs.add(category);
    }

    if (query.isNotEmpty) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'name LIKE ?';
      whereArgs.add('%$query%');
    }

    maps = await db.query(
      'Complete_Flutter_App',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    if (maps.isEmpty) {
      print('Complete_Flutter_App 表中没有数据');
    } else {
      print('Complete_Flutter_App 表中的数据:');
      for (var row in maps) {
        print(row);
      }
    }

    return List.generate(maps.length, (i) {
      return FoodItem.fromMap(maps[i]);
    });
  }

  // 添加收藏
  Future<void> addFavorite(int foodItemId) async {
    final db = await database;
    await db.insert(
      'favorites',
      {'food_item_id': foodItemId},
      conflictAlgorithm: ConflictAlgorithm.ignore, // 避免重复添加
    );
    print('添加收藏: food_item_id = $foodItemId');
  }

  // 移除收藏
  Future<void> removeFavorite(int foodItemId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'food_item_id = ?',
      whereArgs: [foodItemId],
    );
    print('移除收藏: food_item_id = $foodItemId');
  }

  // 获取收藏的食物项
  Future<List<FoodItem>> getFavoriteFoodItems() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT Complete_Flutter_App.*
      FROM Complete_Flutter_App
      INNER JOIN favorites ON Complete_Flutter_App.id_every = favorites.food_item_id
    ''');

    if (maps.isEmpty) {
      print('favorites 表中没有数据');
      return [];
    } else {
      print('favorites 表中的数据:');
      for (var row in maps) {
        print(row);
      }
    }

    return List.generate(maps.length, (i) {
      return FoodItem.fromMap(maps[i]);
    });
  }

  // 获取同类别的推荐食物项，排除当前食物项
  Future<List<FoodItem>> getRecommendedFoodItems(String category, int excludeId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'Complete_Flutter_App',
      where: 'category = ? AND id_every != ?',
      whereArgs: [category, excludeId],
    );

    if (maps.isEmpty) {
      print('No recommended food items found for category "$category", excluding ID $excludeId');
      return [];
    } else {
      print('Recommended food items for category "$category", excluding ID $excludeId:');
      for (var row in maps) {
        print(row);
      }
    }

    return List.generate(maps.length, (i) {
      return FoodItem.fromMap(maps[i]);
    });
  }

  // 导出数据库文件到外部存储（可选）
  Future<String> exportDatabase() async {
    final db = await database;
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      throw Exception("无法获取外部存储目录");
    }
    String exportPath = join(externalDir.path, "minidb_export.db");
    await db.close();
    try {
      await File(join(await getDatabasesPath(), 'minidb.db')).copy(exportPath);
      print("数据库已导出到: $exportPath");
      return exportPath;
    } catch (e) {
      print("导出数据库失败: $e");
      throw e;
    } finally {
      // 重新打开数据库
      _database = await openDatabase(
        join(await getDatabasesPath(), 'minidb.db'),
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }

  // 导入数据库文件从外部存储（可选）
  Future<void> importDatabase(String importPath) async {
    final db = await database;
    await db.close();
    try {
      await File(importPath).copy(join(await getDatabasesPath(), 'minidb.db'));
      print("数据库已从 $importPath 导入");
      _database = await _initDatabase(); // 重新初始化数据库
    } catch (e) {
      print("导入数据库失败: $e");
      throw e;
    }
  }
}
