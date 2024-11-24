
import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import '../models/category.dart';
import '../models/food_item.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "minidb.db");

    bool exists = await databaseExists(path);
    print("数据库存在: $exists at path: $path");

    if (!exists) {
      print("数据库不存在，准备从 assets 中复制...");
      await Directory(dirname(path)).create(recursive: true);
      ByteData data = await rootBundle.load(join('assets', 'minidb.db'));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
      print("数据库已成功复制到: $path");
    } else {
      print("数据库已存在，无需复制。");
    }

    Database db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    // 创建食物类别表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS food_category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''');

    // 创建食物项表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Complete_Flutter_App (
        id_every INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cal INTEGER NOT NULL,
        category TEXT NOT NULL,
        image_path TEXT NOT NULL,
        rate REAL NOT NULL,
        reviews INTEGER NOT NULL,
        time INTEGER NOT NULL,
        ingredientsAmount TEXT NOT NULL,
        ingredientsName TEXT NOT NULL,
        ingredientsImage TEXT NOT NULL
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
  }

  // 调试时使用，重新复制数据库文件
  Future<void> clearOldDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "minidb.db");
    final File dbFile = File(path);
    if (await dbFile.exists()) {
      await dbFile.delete();
      print('旧数据库已被删除');
    }
  }

  // 获取类别列表
  Future<List<Category>> getCategories() async {
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
      return Category.fromMap(maps[i]);
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
}

