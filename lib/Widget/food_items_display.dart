// lib/Widget/food_items_display.dart

import 'package:flutter/material.dart';
import '../Provider/favorite_provider.dart';
import '../Views/recipe_detail_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';

class FoodItemsDisplay extends StatelessWidget {
  final FoodItem foodItem;
  const FoodItemsDisplay({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;

    // 根据屏幕宽度调整组件尺寸
    double containerWidth = screenWidth * 0.6; // 比如 60% 屏幕宽度
    double imageHeight = containerWidth * 0.6;  // 60% 宽度作为高度
    double iconSize = screenWidth * 0.04;       // 图标大小
    double fontSize = screenWidth * 0.035;      // 字体大小

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(foodItem: foodItem),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: screenWidth * 0.03), // 响应式右边距
        width: containerWidth,
        height: imageHeight + 110,  // 动态调整高度
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: foodItem.imagePath, // 使用 imagePath 作为 Hero 标签
                  child: Container(
                    width: double.infinity,
                    height: imageHeight, // 动态调整图片高度
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          'assets/images/${foodItem.imagePath}', // 从 assets 加载图片
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                // 使用 Flexible 包裹 Text，防止溢出
                Flexible(
                  child: Text(
                    foodItem.name,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // 防止文本溢出
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                // 使用 Flexible 包裹 Row，防止溢出
                Flexible(
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.flash_1,
                        size: iconSize,
                        color: Colors.grey,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        "${foodItem.cal} Cal",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize * 0.85,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        " · ",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          fontSize: fontSize * 0.85,
                        ),
                      ),
                      Icon(
                        Iconsax.clock,
                        size: iconSize,
                        color: Colors.grey,
                      ),
                      SizedBox(width: screenWidth * 0.005),
                      Text(
                        "${foodItem.time} Min",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize * 0.85,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 收藏按钮
            Positioned(
              top: screenWidth * 0.01,
              right: screenWidth * 0.01,
              child: CircleAvatar(
                radius: screenWidth * 0.045, // 动态调整半径
                backgroundColor: Colors.white,
                child: InkWell(
                  onTap: () {
                    favoriteProvider.toggleFavorite(foodItem);
                  },
                  child: Icon(
                    favoriteProvider.isExist(foodItem)
                        ? Iconsax.heart5
                        : Iconsax.heart,
                    color: favoriteProvider.isExist(foodItem)
                        ? Colors.red
                        : Colors.black,
                    size: screenWidth * 0.05, // 动态调整图标大小
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
