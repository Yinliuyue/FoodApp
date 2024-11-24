// lib/Views/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../Provider/favorite_provider.dart';
import '../Provider/quantity.dart';
import '../Utils/constants.dart';
import '../Utils/database_helper.dart'; // 引入 DatabaseHelper
import '../models/food_item.dart';
import '../Widget/food_items_display.dart';
import '../Widget/my_icon_button.dart';
import '../Widget/quantity_increment_decrement.dart';
import 'package:provider/provider.dart';

class RecipeDetailScreen extends StatefulWidget {
  final FoodItem foodItem;
  const RecipeDetailScreen({super.key, required this.foodItem});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<List<FoodItem>> recommendedFuture;

  @override
  void initState() {
    super.initState();
    // 初始化数量提供者（此处无需设置 ingredients）
    Provider.of<QuantityProvider>(context, listen: false)
        .setBaseIngredientAmounts([]); // 空列表，因为已移除 ingredients

    // 获取同类别的推荐食物项
    recommendedFuture = DatabaseHelper().getRecommendedFoodItems(
      widget.foodItem.category,
      widget.foodItem.idEvery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final quantityProvider = Provider.of<QuantityProvider>(context);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: startCookingAndFavoriteButton(favoriteProvider),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // 食物图片
                Hero(
                  tag: widget.foodItem.imagePath,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2.1,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          'assets/images/${widget.foodItem.imagePath}',
                        ),
                      ),
                    ),
                  ),
                ),
                // 返回和通知按钮
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      MyIconButton(
                        icon: Icons.arrow_back_ios_new,
                        pressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      MyIconButton(
                        icon: Iconsax.notification,
                        pressed: () {},
                      ),
                    ],
                  ),
                ),
                // 下方装饰容器
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.width,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            // 拖动手柄
            Center(
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 食物名称
                  Text(
                    widget.foodItem.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 卡路里和时间
                  Row(
                    children: [
                      const Icon(
                        Iconsax.flash_1,
                        size: 20,
                        color: Colors.grey,
                      ),
                      Text(
                        "${widget.foodItem.cal} Cal",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.foodItem.time} Min",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 评分
                  Row(
                    children: [
                      const Icon(
                        Iconsax.star1,
                        color: Colors.amberAccent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.foodItem.rate.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("/5"),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.foodItem.reviews} Reviews",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 推荐部分标题和数量选择器
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recommended",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Other recommendations from the same category",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                      // 可选：如果需要数量选择器，可以保留或移除
                      // 此处不需要，因为已删除 ingredients
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 推荐食物项列表
                  FutureBuilder<List<FoodItem>>(
                    future: recommendedFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No recommendations available');
                      } else {
                        List<FoodItem> recommended = snapshot.data!;
                        return Column(
                          children: recommended.map((item) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailScreen(foodItem: item),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                            'assets/images/${item.imagePath}',
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton startCookingAndFavoriteButton(
      FavoriteProvider provider) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () {},
      label: Row(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kprimaryColor,
                padding:
                const EdgeInsets.symmetric(horizontal: 100, vertical: 13),
                foregroundColor: Colors.white),
            onPressed: () {},
            child: const Text(
              "Start Cooking",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            style: IconButton.styleFrom(
              shape: const CircleBorder(
                side: BorderSide(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
            ),
            onPressed: () {
              provider.toggleFavorite(widget.foodItem);
            },
            icon: Icon(
              provider.isExist(widget.foodItem)
                  ? Iconsax.heart5
                  : Iconsax.heart,
              color: provider.isExist(widget.foodItem)
                  ? Colors.red
                  : Colors.black,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
