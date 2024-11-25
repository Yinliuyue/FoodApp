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
        margin: const EdgeInsets.only(right: 10),
        width: 230,
        height: 250,  // 增加容器的高度
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: foodItem.imagePath, // 使用 imagePath 作为 Hero 标签
                  child: Container(
                    width: double.infinity,
                    height: 140, // 调整图片高度
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
                const SizedBox(height: 10),
                // 使用 Flexible 包裹 Text，防止溢出
                Flexible(
                  child: Text(
                    foodItem.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // 防止文本溢出
                  ),
                ),
                const SizedBox(height: 5),
                // 使用 Flexible 包裹 Row，防止溢出
                Flexible(
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.flash_1,
                        size: 16,
                        color: Colors.grey,
                      ),
                      Text(
                        "${foodItem.cal} Cal",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const Text(
                        " · ",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                        ),
                      ),
                      const Icon(
                        Iconsax.clock,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${foodItem.time} Min",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
              top: 5,
              right: 5,
              child: CircleAvatar(
                radius: 18,
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
                    size: 20,
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
