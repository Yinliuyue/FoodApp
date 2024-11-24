

// lib/Provider/favorite_provider.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../Utils/database_helper.dart';

class FavoriteProvider extends ChangeNotifier {
  List<FoodItem> _favorites = [];

  List<FoodItem> get favorites => _favorites;

  FavoriteProvider() {
    loadFavorites();
  }

  // 切换收藏状态
  void toggleFavorite(FoodItem item) async {
    if (isExist(item)) {
      _favorites.removeWhere((fav) => fav.idEvery == item.idEvery);
      await DatabaseHelper().removeFavorite(item.idEvery); // 从收藏中移除
    } else {
      _favorites.add(item);
      await DatabaseHelper().addFavorite(item.idEvery); // 添加到收藏
    }
    notifyListeners();
  }

  // 检查是否收藏
  bool isExist(FoodItem item) {
    return _favorites.any((fav) => fav.idEvery == item.idEvery);
  }

  // 加载收藏列表
  Future<void> loadFavorites() async {
    _favorites = await DatabaseHelper().getFavoriteFoodItems();
    notifyListeners();
  }

  // 静态方法，从任何上下文中访问 Provider
  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen,
    );
  }
}
