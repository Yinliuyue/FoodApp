// lib/Views/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../Provider/favorite_provider.dart';
import '../Utils/constants.dart';
import '../Utils/database_helper.dart'; // 引入 DatabaseHelper
import '../models/food_item.dart';
import '../Widget/my_icon_button.dart';
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
    // 获取基于收藏的推荐物品
    recommendedFuture = DatabaseHelper().getRecommendedItems();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    // 获取屏幕尺寸
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 根据屏幕宽度计算尺寸比例
    double imageHeight = screenHeight / 2.5; // 调整图片高度
    double foodImageWidth = screenWidth * 0.4; // 食物图片宽度
    double foodImageHeight = imageHeight * 0.5; // 食物图片高度
    double textFontSize = screenWidth * 0.05; // 食物名称字体大小
    double infoFontSize = screenWidth * 0.035; // 其他信息字体大小

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: startCookingAndFavoriteButton(favoriteProvider, screenWidth),
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
                    height: imageHeight,
                    width: double.infinity,
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
                // 下方装饰容器（如需要添加其他装饰可以在这里）
                Positioned(
                  left: 0,
                  right: 0,
                  top: imageHeight - 20, // 确保装饰容器紧贴图片底部
                  child: Container(
                    height: 40, // 根据需要调整高度
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
            // 拖动手柄
            Center(
              child: Container(
                width: screenWidth * 0.1, // 响应式宽度
                height: screenWidth * 0.02, // 响应式高度
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
                  // 食物名称
                  Text(
                    widget.foodItem.name,
                    style: TextStyle(
                      fontSize: textFontSize, // 响应式字体大小
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // 卡路里和时间
                  Row(
                    children: [
                      Icon(
                        Iconsax.flash_1,
                        size: screenWidth * 0.05, // 响应式图标大小
                        color: Colors.grey,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        "${widget.foodItem.cal} Cal",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: infoFontSize, // 响应式字体大小
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        " · ",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          fontSize: infoFontSize,
                        ),
                      ),
                      Icon(
                        Iconsax.clock,
                        size: screenWidth * 0.05,
                        color: Colors.grey,
                      ),
                      SizedBox(width: screenWidth * 0.005),
                      Text(
                        "${widget.foodItem.time} Min",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: infoFontSize,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // 评分
                  Row(
                    children: [
                      Icon(
                        Iconsax.star1,
                        color: Colors.amberAccent,
                        size: screenWidth * 0.05,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        widget.foodItem.rate.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: infoFontSize,
                        ),
                      ),
                      Text(
                        "/5",
                        style: TextStyle(
                          fontSize: infoFontSize,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        "${widget.foodItem.reviews} Reviews",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: infoFontSize,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  // 推荐部分标题
                  Text(
                    "推荐",
                    style: TextStyle(
                      fontSize: textFontSize, // 响应式字体大小
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  // 推荐食物项列表
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
                          height: foodImageHeight * 2, // 根据需要调整高度
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recommended.length,
                            itemBuilder: (context, index) {
                              final item = recommended[index];
                              return FoodItemsDisplay(
                                foodItem: item,
                                screenWidth: screenWidth,
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kprimaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.25, // 响应式水平间距
                vertical: screenWidth * 0.03,      // 响应式垂直间距
              ),
              foregroundColor: Colors.white,
            ),
            onPressed: () {},
            child: Text(
              "Start Cooking",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045, // 响应式字体大小
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.02), // 响应式间距
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
              size: screenWidth * 0.05, // 响应式图标大小
            ),
          ),
        ],
      ),
    );
  }
}

// 添加 FoodItemsDisplay 组件到同一文件中，并进行响应式设计
class FoodItemsDisplay extends StatelessWidget {
  final FoodItem foodItem;
  final double screenWidth;

  const FoodItemsDisplay({
    Key? key,
    required this.foodItem,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 根据屏幕宽度调整组件尺寸
    double containerWidth = screenWidth * 0.4; // 40%屏幕宽度
    double imageHeight = containerWidth * 0.6;  // 60%宽度作为高度
    double iconSize = screenWidth * 0.04;       // 图标大小
    double fontSize = screenWidth * 0.035;      // 字体大小

    return Container(
      width: containerWidth,
      margin: EdgeInsets.only(right: screenWidth * 0.03), // 响应式右边距
      child: Column(
        mainAxisSize: MainAxisSize.min, // 不占用超出子项的空间
        crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
        children: [
          // 食物图片
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/${foodItem.imagePath}',
              width: containerWidth,
              height: imageHeight, // 固定高度，防止溢出
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: screenWidth * 0.02), // 响应式间距
          // 食物名称
          Text(
            foodItem.name,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1, // 限制为一行
            overflow: TextOverflow.ellipsis, // 溢出时显示省略号
          ),
          SizedBox(height: screenWidth * 0.01), // 响应式间距
          // 其他信息
          Row(
            children: [
              Icon(Icons.flash_on, size: iconSize, color: Colors.grey),
              SizedBox(width: screenWidth * 0.01),
              Text(
                "${foodItem.cal} Cal",
                style: TextStyle(
                  fontSize: fontSize * 0.9,
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Icon(Icons.timer, size: iconSize, color: Colors.grey),
              SizedBox(width: screenWidth * 0.01),
              Text(
                "${foodItem.time} Min",
                style: TextStyle(
                  fontSize: fontSize * 0.9,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
