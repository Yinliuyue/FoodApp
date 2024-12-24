// lib/Views/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../Provider/favorite_provider.dart';
import '../Utils/constants.dart';
import '../Utils/database_helper.dart'; // 引入 DatabaseHelper
import '../models/food_item.dart';
import '../Widget/my_icon_button.dart';
import '../Widget/food_items_display.dart'; // 确保引入 FoodItemsDisplay 组件
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
    // 根据当前菜品的 taste 获取推荐物品
    String currentTaste = widget.foodItem.taste?.toLowerCase() ?? '';
    recommendedFuture = DatabaseHelper().getRecommendedItemsByTaste(currentTaste);
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double imageHeight = screenHeight / 2.5; // 调整图片高度
    double foodImageHeight = imageHeight * 0.5;
    double textFontSize = screenWidth * 0.05;
    double infoFontSize = screenWidth * 0.035;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: startCookingAndFavoriteButton(favoriteProvider, screenWidth),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: widget.foodItem.imagePath,
                  child: Container(
                    height: imageHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/${widget.foodItem.imagePath}'),
                      ),
                    ),
                  ),
                ),
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
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: imageHeight - 20,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                width: screenWidth * 0.1,
                height: screenWidth * 0.02,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.foodItem.name,
                    style: TextStyle(
                      fontSize: textFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    children: [
                      Icon(
                        Iconsax.flash_1,
                        size: screenWidth * 0.05,
                        color: Colors.grey,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        "${widget.foodItem.category} ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: infoFontSize,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        " · ",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          fontSize: infoFontSize,
                        ),
                      ),
                      // Icon(
                      //   Iconsax.taste,
                      //   size: screenWidth * 0.05,
                      //   color: Colors.grey,
                      // ),
                      SizedBox(width: screenWidth * 0.005),
                      Text(
                        "${widget.foodItem.taste} ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: infoFontSize,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Iconsax.star1,
                  //       color: Colors.amberAccent,
                  //       size: screenWidth * 0.05,
                  //     ),
                  //     SizedBox(width: screenWidth * 0.01),
                  //     Text(
                  //       widget.foodItem.rate.toString(),
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: infoFontSize,
                  //       ),
                  //     ),
                  //     Text(
                  //       "/5",
                  //       style: TextStyle(fontSize: infoFontSize),
                  //     ),
                  //     SizedBox(width: screenWidth * 0.01),
                  //     Text(
                  //       "${widget.foodItem.reviews} 评论",
                  //       style: TextStyle(color: Colors.grey, fontSize: infoFontSize),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: screenHeight * 0.03),
                  if (widget.foodItem.introduction != null && widget.foodItem.introduction!.trim().isNotEmpty)
                    SectionBox(
                      title: "简介",
                      content: widget.foodItem.introduction!,
                    ),
                  if (widget.foodItem.source != null && widget.foodItem.source!.trim().isNotEmpty)
                    SectionBox(
                      title: "需要准备的原料",
                      content: widget.foodItem.source!,
                    ),
                  SizedBox(height: screenHeight * 0.03),
                  SectionBox(
                    title: "制作步骤",
                    content: widget.foodItem.content,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    "推荐",
                    style: TextStyle(
                      fontSize: textFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  FutureBuilder<List<FoodItem>>(
                    future: recommendedFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('没有推荐的物品');
                      } else {
                        List<FoodItem> recommended = snapshot.data!;
                        return SizedBox(
                          height: foodImageHeight * 2,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recommended.length,
                            itemBuilder: (context, index) {
                              final item = recommended[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: FoodItemsDisplay(foodItem: item),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton startCookingAndFavoriteButton(FavoriteProvider provider, double screenWidth) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () {},
      label: Row(
        children: [
          IconButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenWidth * 0.03,
                ),
                foregroundColor: Colors.white,
              ),
            onPressed: () {
              provider.toggleFavorite(widget.foodItem);
            },
            icon: Icon(
              provider.isExist(widget.foodItem) ? Iconsax.heart5 : Iconsax.heart,
              color: provider.isExist(widget.foodItem) ? Colors.red : Colors.black,
              size: screenWidth * 0.05,
            ),
          ),
          // SizedBox(width: screenWidth * 0.02),
        ],
      ),
    );
  }
}

class SectionBox extends StatelessWidget {
  final String title;
  final String content;

  const SectionBox({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            content,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
