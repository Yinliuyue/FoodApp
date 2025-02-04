// // lib/Utils/database_helper.dart
//
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart'; // 用于 kReleaseMode
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:flutter/services.dart';
//
// // 为 models 导入添加前缀
// import 'package:miniapp/models/category.dart' as model;
// import 'package:miniapp/models/food_item.dart';
//
// class DatabaseHelper {
//   // 单例模式
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();
//
//   static Database? _database;
//
//   // 获取数据库实例
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   // 初始化数据库
//   Future<Database> _initDatabase() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, "minidb.db");
//
//     bool exists = await databaseExists(path);
//     print("数据库存在: $exists at path: $path");
//
//     if (!exists || !kReleaseMode) { // 开发模式下每次复制
//       print("数据库不存在或开发模式，准备从 assets 中复制...");
//       try {
//         // 加载资产中的数据库文件
//         ByteData data = await rootBundle.load(join('assets', 'minidb.db'));
//         List<int> bytes =
//         data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//
//         // 确保目标目录存在
//         await Directory(dirname(path)).create(recursive: true);
//
//         // 写入数据库文件
//         await File(path).writeAsBytes(bytes, flush: true);
//         print("数据库已成功复制到: $path");
//       } catch (e) {
//         print("复制数据库文件失败: $e");
//       }
//     }
//
//     // 打开数据库
//     Database db = await openDatabase(
//       path,
//       version: 2, // 更新的版本号
//       onCreate: _onCreate,
//       onUpgrade: _onUpgrade,
//     );
//     return db;
//   }
//
//   // 创建数据库表
//   FutureOr<void> _onCreate(Database db, int version) async {
//     print("创建数据库表...");
//     // 创建食物类别表，确保 name 字段唯一
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS food_category (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL UNIQUE
//       );
//     ''');
//
//     // 创建食物项表
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS Complete_Flutter_App (
//         id_every INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         category TEXT NOT NULL,
//         image_path TEXT NOT NULL,
//         introduction TEXT,
//         content TEXT NOT NULL,
//         taste TEXT,
//         source TEXT
//       );
//     ''');
//
//     // 创建收藏表
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS favorites (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         food_item_id INTEGER NOT NULL,
//         FOREIGN KEY (food_item_id) REFERENCES Complete_Flutter_App (id_every) ON DELETE CASCADE
//       );
//     ''');
//
//     // 插入初始数据（可选）
//     await _insertInitialData(db);
//   }
//
//   // 数据库升级
//   FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     print("升级数据库，从版本 $oldVersion 到 $newVersion");
//     if (oldVersion < 2) {
//       // 示例：插入推荐食物项，确保 'rate' 是数值类型
//       await db.execute('''
//         INSERT INTO Complete_Flutter_App (name, cal, category, image_path, rate, reviews, time)
//         VALUES
//           ('推荐食物1', 300, 'CategoryName', 'image1.png', 4.5, 100, 30),
//           ('推荐食物2', 250, 'CategoryName', 'image2.png', 4.7, 150, 25)
//       ''');
//       print("推荐食物项已插入");
//     }
//     // 如果未来有更多版本，可以在此处继续添加升级逻辑
//   }
//
//   // 插入初始数据（可选）
//   Future<void> _insertInitialData(Database db) async {
//     // 插入类别数据，确保不重复插入 "所有"
//     List<String> initialCategories = [
//       '所有',
//       '川菜',
//       '鲁菜',
//       '粤菜',
//       '苏菜',
//       '闽菜',
//       '浙菜',
//       '湘菜',
//       '徽菜',
//     ];
//
//     for (String category in initialCategories) {
//       try {
//         await db.insert(
//           'food_category',
//           {'name': category},
//           conflictAlgorithm: ConflictAlgorithm.ignore, // 避免重复插入
//         );
//         print("插入类别: $category");
//       } catch (e) {
//         // 如果类别已存在，则忽略错误
//         print("类别 '$category' 已存在，跳过插入。");
//       }
//     }
//
//     // 插入更多类别或食物项
//     print("初始数据已插入");
//   }
//
//   // 插入单个类别
//   Future<void> insertCategory(model.Category category) async {
//     final db = await database;
//     try {
//       await db.insert(
//         'food_category',
//         {'name': category.name}, // 只插入 'name'，不插入 'id'
//         conflictAlgorithm: ConflictAlgorithm.ignore, // 避免重复插入
//       );
//       print("插入类别: ${category.name}");
//     } catch (e) {
//       print("插入类别失败: $e");
//     }
//   }
//
//   // 获取所有类别
//   Future<List<model.Category>> getCategories() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'food_category',
//       orderBy: "CASE WHEN name = '所有' THEN 0 ELSE 1 END, name ASC", // 确保 '所有' 排在前面
//     );
//
//     if (maps.isEmpty) {
//       print('food_category 表中没有数据');
//     } else {
//       print('food_category 表中的数据:');
//       for (var row in maps) {
//         print(row);
//       }
//     }
//
//     // 使用 Set 确保类别名称唯一
//     final uniqueNames = <String>{};
//     final uniqueCategories = <model.Category>[];
//
//     for (var map in maps) {
//       final name = map['name'] as String;
//       if (!uniqueNames.contains(name)) {
//         uniqueNames.add(name);
//         uniqueCategories.add(model.Category.fromMap(map));
//       }
//     }
//
//     // 额外排序，确保 '所有' 排在第一位
//     uniqueCategories.sort((a, b) {
//       if (a.name == '所有') return -1;
//       if (b.name == '所有') return 1;
//       return a.name.compareTo(b.name);
//     });
//
//     return uniqueCategories;
//   }
//
//   // 获取食物项列表，可按类别过滤
//   Future<List<FoodItem>> getFoodItems({String? category}) async {
//     final db = await database;
//     List<Map<String, dynamic>> maps;
//
//     if (category == null || category == "所有") {
//       maps = await db.query('Complete_Flutter_App');
//     } else {
//       maps = await db.query(
//         'Complete_Flutter_App',
//         where: 'category = ?',
//         whereArgs: [category],
//       );
//     }
//
//     if (maps.isEmpty) {
//       print('Complete_Flutter_App 表中没有数据');
//     } else {
//       print('Complete_Flutter_App 表中的数据:');
//       for (var row in maps) {
//         print(row);
//       }
//     }
//
//     // 使用 try-catch 以防某条数据有问题
//     List<FoodItem> foodItems = [];
//     for (var map in maps) {
//       try {
//         foodItems.add(FoodItem.fromMap(map));
//       } catch (e) {
//         print("Error parsing FoodItem: $e");
//       }
//     }
//
//     return foodItems;
//   }
//
//   // 获取单个食物项，通过 id_every
//   Future<FoodItem?> getFoodItemById(int idEvery) async {
//     final db = await database;
//     List<Map<String, dynamic>> maps = await db.query(
//       'Complete_Flutter_App',
//       where: 'id_every = ?',
//       whereArgs: [idEvery],
//     );
//
//     if (maps.isNotEmpty) {
//       return FoodItem.fromMap(maps.first);
//     } else {
//       return null;
//     }
//   }
//
//   // 搜索食物项
//   Future<List<FoodItem>> searchFoodItems(String query, {String? category}) async {
//     final db = await database;
//     List<Map<String, dynamic>> maps;
//
//     String whereClause = '';
//     List<dynamic> whereArgs = [];
//
//     if (category != null && category != "所有") {
//       whereClause += 'category = ?';
//       whereArgs.add(category);
//     }
//
//     if (query.isNotEmpty) {
//       if (whereClause.isNotEmpty) {
//         whereClause += ' AND ';
//       }
//       whereClause += 'name LIKE ?';
//       whereArgs.add('%$query%');
//     }
//
//     maps = await db.query(
//       'Complete_Flutter_App',
//       where: whereClause.isNotEmpty ? whereClause : null,
//       whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
//     );
//
//     if (maps.isEmpty) {
//       print('Complete_Flutter_App 表中没有数据');
//     } else {
//       print('Complete_Flutter_App 表中的数据:');
//       for (var row in maps) {
//         print(row);
//       }
//     }
//
//     // 使用 try-catch 以防某条数据有问题
//     List<FoodItem> foodItems = [];
//     for (var map in maps) {
//       try {
//         foodItems.add(FoodItem.fromMap(map));
//       } catch (e) {
//         print("Error parsing FoodItem: $e");
//       }
//     }
//
//     return foodItems;
//   }
//
//   // 获取随机物品
//   Future<List<FoodItem>> getRandomItems({int limit = 10}) async {
//     final db = await database;
//     List<Map<String, dynamic>> maps = await db.query(
//       'Complete_Flutter_App',
//       orderBy: 'RANDOM()',
//       limit: limit,
//     );
//
//     return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
//   }
//
//   // 获取每个类别的随机物品
//   Future<List<FoodItem>> getRandomItemsFromEachCategory({int limitPerCategory = 2}) async {
//     final db = await database;
//     List<FoodItem> randomItems = [];
//
//     // 获取所有类别，排除 "所有"
//     List<model.Category> categories = await getCategories();
//     categories = categories.where((category) => category.name != '所有').toList();
//
//     for (var category in categories) {
//       List<Map<String, dynamic>> maps = await db.query(
//         'Complete_Flutter_App',
//         where: 'category = ?',
//         whereArgs: [category.name],
//         orderBy: 'RANDOM()',
//         limit: limitPerCategory,
//       );
//
//       if (maps.isNotEmpty) {
//         randomItems.addAll(maps.map((map) => FoodItem.fromMap(map)).toList());
//       }
//     }
//
//     return randomItems;
//   }
//
//   // 获取“快速简单”物品
//   Future<List<FoodItem>> getQuickEasyItems(String category, {int maxCalories = 500, int maxTime = 30}) async {
//     final db = await database;
//     List<Map<String, dynamic>> maps = await db.query(
//       'Complete_Flutter_App',
//       where: 'category = ? ',
//       whereArgs: [category],
//       orderBy: 'RANDOM()',
//       limit: 5, // 根据需要调整
//     );
//
//     return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
//   }
//
//   // **新增：根据 taste 推荐物品**
//   Future<List<FoodItem>> getRecommendedItemsByTaste(String currentTaste, {int limit = 10}) async {
//     final db = await database;
//
//     if (currentTaste.isEmpty) {
//       // 如果当前 taste 为空，返回空列表或使用其他推荐逻辑
//       return [];
//     }
//
//     // 假设 taste 关键词以逗号分隔，例如 "辣,甜"
//     List<String> tasteKeywords = currentTaste.split(',').map((e) => e.trim()).toList();
//
//     if (tasteKeywords.isEmpty) {
//       return [];
//     }
//
//     // 构建 WHERE 子句：taste LIKE '%关键词1%' OR taste LIKE '%关键词2%' ...
//     String whereClause = '';
//     List<dynamic> whereArgs = [];
//     for (int i = 0; i < tasteKeywords.length; i++) {
//       whereClause += 'taste LIKE ?';
//       whereArgs.add('%${tasteKeywords[i]}%');
//       if (i < tasteKeywords.length - 1) {
//         whereClause += ' OR ';
//       }
//     }
//
//     // 执行查询，按 rating 降序排序，限制返回数量
//     List<Map<String, dynamic>> maps = await db.query(
//       'Complete_Flutter_App',
//       where: whereClause,
//       whereArgs: whereArgs,
//       orderBy: 'rate DESC',
//       limit: limit,
//     );
//
//     if (maps.isEmpty) {
//       print('根据 taste 推荐，Complete_Flutter_App 表中没有匹配的数据');
//     } else {
//       print('根据 taste 推荐，Complete_Flutter_App 表中的数据:');
//       for (var row in maps) {
//         print(row);
//       }
//     }
//
//     List<FoodItem> recommendedItems = [];
//     for (var map in maps) {
//       try {
//         recommendedItems.add(FoodItem.fromMap(map));
//       } catch (e) {
//         print("解析推荐食物项时出错: $e");
//       }
//     }
//
//     return recommendedItems;
//   }
//
//   // 获取推荐的物品，根据用户收藏的类别
//   Future<List<FoodItem>> getRecommendedItems({int limit = 10}) async {
//     final db = await database;
//
//     // 获取用户收藏的所有物品
//     List<FoodItem> favoriteItems = await getFavoriteFoodItems();
//
//     if (favoriteItems.isEmpty) {
//       // 如果没有收藏，随机推荐一些物品
//       return getRandomItems(limit: limit);
//     }
//
//     // 获取收藏物品的所有类别
//     Set<String> favoriteCategories = favoriteItems.map((item) => item.category).toSet();
//
//     // 获取已收藏的物品ID
//     Set<int> favoriteIds = favoriteItems.map((item) => item.idEvery).toSet();
//
//     // 构建WHERE子句
//     String categoryWhere = favoriteCategories.map((_) => '?').join(', ');
//     String excludeWhere = favoriteIds.map((_) => '?').join(', ');
//
//     List<dynamic> arguments = [...favoriteCategories, ...favoriteIds];
//
//     // 查询与收藏类别相同且不在收藏列表中的高评分物品
//     List<Map<String, dynamic>> maps = await db.rawQuery('''
//       SELECT * FROM Complete_Flutter_App
//       WHERE category IN ($categoryWhere)
//         AND id_every NOT IN ($excludeWhere)
//       ORDER BY rate DESC
//       LIMIT $limit
//     ''', arguments);
//
//     return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
//   }
//
//   // 添加收藏
//   Future<void> addFavorite(int foodItemId) async {
//     final db = await database;
//     await db.insert(
//       'favorites',
//       {'food_item_id': foodItemId},
//       conflictAlgorithm: ConflictAlgorithm.ignore, // 避免重复添加
//     );
//     print('添加收藏: food_item_id = $foodItemId');
//   }
//
//   // 移除收藏
//   Future<void> removeFavorite(int foodItemId) async {
//     final db = await database;
//     await db.delete(
//       'favorites',
//       where: 'food_item_id = ?',
//       whereArgs: [foodItemId],
//     );
//     print('移除收藏: food_item_id = $foodItemId');
//   }
//
//   // 获取收藏的食物项
//   Future<List<FoodItem>> getFavoriteFoodItems() async {
//     final db = await database;
//     List<Map<String, dynamic>> maps = await db.rawQuery('''
//       SELECT Complete_Flutter_App.*
//       FROM Complete_Flutter_App
//       INNER JOIN favorites ON Complete_Flutter_App.id_every = favorites.food_item_id
//     ''');
//
//     if (maps.isEmpty) {
//       print('favorites 表中没有数据');
//       return [];
//     } else {
//       print('favorites 表中的数据:');
//       for (var row in maps) {
//         print(row);
//       }
//     }
//
//     // 使用 try-catch 以防某条数据有问题
//     List<FoodItem> favoriteItems = [];
//     for (var map in maps) {
//       try {
//         favoriteItems.add(FoodItem.fromMap(map));
//       } catch (e) {
//         print("Error parsing Favorite FoodItem: $e");
//       }
//     }
//
//     return favoriteItems;
//   }
//
//   // **新增：根据类别获取收藏的食物项**
//   Future<List<FoodItem>> getFavoriteFoodItemsByCategory(String category) async {
//     final db = await database;
//     List<Map<String, dynamic>> maps = await db.rawQuery('''
//       SELECT Complete_Flutter_App.*
//       FROM Complete_Flutter_App
//       INNER JOIN favorites ON Complete_Flutter_App.id_every = favorites.food_item_id
//       WHERE Complete_Flutter_App.category = ?
//     ''', [category]);
//
//     if (maps.isEmpty) {
//       print('类别 "$category" 中没有收藏的物品。');
//       return [];
//     } else {
//       print('类别 "$category" 中的收藏物品：');
//       for (var row in maps) {
//         print(row);
//       }
//     }
//
//     List<FoodItem> favoriteItems = [];
//     for (var map in maps) {
//       try {
//         favoriteItems.add(FoodItem.fromMap(map));
//       } catch (e) {
//         print("解析收藏食物项时出错: $e");
//       }
//     }
//
//     return favoriteItems;
//   }
// }

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
    // 创建食物类别表，确保 name 字段唯一
    await db.execute('''
      CREATE TABLE IF NOT EXISTS food_category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      );
    ''');

    // 创建食物项表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Complete_Flutter_App (
        id_every INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        image_path TEXT NOT NULL,
        introduction TEXT,
        content TEXT NOT NULL,
        taste TEXT,
        source TEXT
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
      // 示例：插入推荐食物项，移除了 'rate'
      await db.execute('''
        INSERT INTO Complete_Flutter_App (name, cal, category, image_path, reviews, time)
        VALUES 
          ('推荐食物1', 300, 'CategoryName', 'image1.png', 100, 30),
          ('推荐食物2', 250, 'CategoryName', 'image2.png', 150, 25)
      ''');
      print("推荐食物项已插入（不包含 rate）");
    }
    // 如果未来有更多版本，可以在此处继续添加升级逻辑
  }

  // 插入初始数据（可选）
  Future<void> _insertInitialData(Database db) async {
    // 插入类别数据，确保不重复插入 "所有"
    List<String> initialCategories = [
      '所有',
      '川菜',
      '鲁菜',
      '粤菜',
      '苏菜',
      '闽菜',
      '浙菜',
      '湘菜',
      '徽菜',
    ];

    for (String category in initialCategories) {
      try {
        await db.insert(
          'food_category',
          {'name': category},
          conflictAlgorithm: ConflictAlgorithm.ignore, // 避免重复插入
        );
        print("插入类别: $category");
      } catch (e) {
        // 如果类别已存在，则忽略错误
        print("类别 '$category' 已存在，跳过插入。");
      }
    }

    // 插入更多类别或食物项
    print("初始数据已插入");
  }

  // 插入单个类别
  Future<void> insertCategory(model.Category category) async {
    final db = await database;
    try {
      await db.insert(
        'food_category',
        {'name': category.name}, // 只插入 'name'，不插入 'id'
        conflictAlgorithm: ConflictAlgorithm.ignore, // 避免重复插入
      );
      print("插入类别: ${category.name}");
    } catch (e) {
      print("插入类别失败: $e");
    }
  }

  // 获取所有类别
  Future<List<model.Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_category',
      orderBy: "CASE WHEN name = '所有' THEN 0 ELSE 1 END, name ASC", // 确保 '所有' 排在前面
    );

    if (maps.isEmpty) {
      print('food_category 表中没有数据');
    } else {
      print('food_category 表中的数据:');
      for (var row in maps) {
        print(row);
      }
    }

    // 使用 Set 确保类别名称唯一
    final uniqueNames = <String>{};
    final uniqueCategories = <model.Category>[];

    for (var map in maps) {
      final name = map['name'] as String;
      if (!uniqueNames.contains(name)) {
        uniqueNames.add(name);
        uniqueCategories.add(model.Category.fromMap(map));
      }
    }

    // 额外排序，确保 '所有' 排在第一位
    uniqueCategories.sort((a, b) {
      if (a.name == '所有') return -1;
      if (b.name == '所有') return 1;
      return a.name.compareTo(b.name);
    });

    return uniqueCategories;
  }

  // 获取食物项列表，可按类别过滤
  Future<List<FoodItem>> getFoodItems({String? category}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (category == null || category == "所有") {
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

    // 使用 try-catch 以防某条数据有问题
    List<FoodItem> foodItems = [];
    for (var map in maps) {
      try {
        foodItems.add(FoodItem.fromMap(map));
      } catch (e) {
        print("Error parsing FoodItem: $e");
      }
    }

    return foodItems;
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
  Future<List<FoodItem>> searchFoodItems(String query, {String? category}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (category != null && category != "所有") {
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

    // 使用 try-catch 以防某条数据有问题
    List<FoodItem> foodItems = [];
    for (var map in maps) {
      try {
        foodItems.add(FoodItem.fromMap(map));
      } catch (e) {
        print("Error parsing FoodItem: $e");
      }
    }

    return foodItems;
  }

  // 获取随机物品
  Future<List<FoodItem>> getRandomItems({int limit = 10}) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'Complete_Flutter_App',
      orderBy: 'RANDOM()',
      limit: limit,
    );

    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }

  // 获取每个类别的随机物品
  Future<List<FoodItem>> getRandomItemsFromEachCategory({int limitPerCategory = 2}) async {
    final db = await database;
    List<FoodItem> randomItems = [];

    // 获取所有类别，排除 "所有"
    List<model.Category> categories = await getCategories();
    categories = categories.where((category) => category.name != '所有').toList();

    for (var category in categories) {
      List<Map<String, dynamic>> maps = await db.query(
        'Complete_Flutter_App',
        where: 'category = ?',
        whereArgs: [category.name],
        orderBy: 'RANDOM()',
        limit: limitPerCategory,
      );

      if (maps.isNotEmpty) {
        randomItems.addAll(maps.map((map) => FoodItem.fromMap(map)).toList());
      }
    }

    return randomItems;
  }

  // 获取“快速简单”物品
  Future<List<FoodItem>> getQuickEasyItems(String category, {int maxCalories = 500, int maxTime = 30}) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'Complete_Flutter_App',
      where: 'category = ? ',
      whereArgs: [category],
      orderBy: 'RANDOM()',
      limit: 5, // 根据需要调整
    );

    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }

  // **新增：根据 taste 推荐物品**
  Future<List<FoodItem>> getRecommendedItemsByTaste(String currentTaste, {int limit = 10}) async {
    final db = await database;

    if (currentTaste.isEmpty) {
      // 如果当前 taste 为空，返回空列表或使用其他推荐逻辑
      return [];
    }

    // 假设 taste 关键词以逗号分隔，例如 "辣,甜"
    List<String> tasteKeywords = currentTaste.split(',').map((e) => e.trim()).toList();

    if (tasteKeywords.isEmpty) {
      return [];
    }

    // 构建 WHERE 子句：taste LIKE '%关键词1%' OR taste LIKE '%关键词2%' ...
    String whereClause = '';
    List<dynamic> whereArgs = [];
    for (int i = 0; i < tasteKeywords.length; i++) {
      whereClause += 'taste LIKE ?';
      whereArgs.add('%${tasteKeywords[i]}%');
      if (i < tasteKeywords.length - 1) {
        whereClause += ' OR ';
      }
    }

    // 执行查询，限制返回数量
    List<Map<String, dynamic>> maps = await db.query(
      'Complete_Flutter_App',
      where: whereClause,
      whereArgs: whereArgs,
      // 移除了 'ORDER BY rate DESC'
      limit: limit,
    );

    if (maps.isEmpty) {
      print('根据 taste 推荐，Complete_Flutter_App 表中没有匹配的数据');
    } else {
      print('根据 taste 推荐，Complete_Flutter_App 表中的数据:');
      for (var row in maps) {
        print(row);
      }
    }

    List<FoodItem> recommendedItems = [];
    for (var map in maps) {
      try {
        recommendedItems.add(FoodItem.fromMap(map));
      } catch (e) {
        print("解析推荐食物项时出错: $e");
      }
    }

    return recommendedItems;
  }

  // 获取推荐的物品，根据用户收藏的类别
  Future<List<FoodItem>> getRecommendedItems({int limit = 10}) async {
    final db = await database;

    // 获取用户收藏的所有物品
    List<FoodItem> favoriteItems = await getFavoriteFoodItems();

    if (favoriteItems.isEmpty) {
      // 如果没有收藏，随机推荐一些物品
      return getRandomItems(limit: limit);
    }

    // 获取收藏物品的所有类别
    Set<String> favoriteCategories = favoriteItems.map((item) => item.category).toSet();

    // 获取已收藏的物品ID
    Set<int> favoriteIds = favoriteItems.map((item) => item.idEvery).toSet();

    if (favoriteCategories.isEmpty) {
      // 如果没有类别信息，返回随机物品
      return getRandomItems(limit: limit);
    }

    // 构建WHERE子句
    String categoryWhere = favoriteCategories.map((_) => '?').join(', ');
    String excludeWhere = favoriteIds.map((_) => '?').join(', ');

    List<dynamic> arguments = [...favoriteCategories, ...favoriteIds];

    // 查询与收藏类别相同且不在收藏列表中的物品
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM Complete_Flutter_App
      WHERE category IN ($categoryWhere)
        AND id_every NOT IN ($excludeWhere)
      LIMIT $limit
    ''', arguments);

    // 可选择添加排序逻辑，例如按时间、热度等
    // 例如：ORDER BY time DESC

    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
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

    // 使用 try-catch 以防某条数据有问题
    List<FoodItem> favoriteItems = [];
    for (var map in maps) {
      try {
        favoriteItems.add(FoodItem.fromMap(map));
      } catch (e) {
        print("Error parsing Favorite FoodItem: $e");
      }
    }

    return favoriteItems;
  }

  // **新增：根据类别获取收藏的食物项**
  Future<List<FoodItem>> getFavoriteFoodItemsByCategory(String category) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT Complete_Flutter_App.*
      FROM Complete_Flutter_App
      INNER JOIN favorites ON Complete_Flutter_App.id_every = favorites.food_item_id
      WHERE Complete_Flutter_App.category = ?
    ''', [category]);

    if (maps.isEmpty) {
      print('类别 "$category" 中没有收藏的物品。');
      return [];
    } else {
      print('类别 "$category" 中的收藏物品：');
      for (var row in maps) {
        print(row);
      }
    }

    List<FoodItem> favoriteItems = [];
    for (var map in maps) {
      try {
        favoriteItems.add(FoodItem.fromMap(map));
      } catch (e) {
        print("解析收藏食物项时出错: $e");
      }
    }

    return favoriteItems;
  }
}
