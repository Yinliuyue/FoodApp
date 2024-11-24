
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../Utils/constants.dart';
import '../Utils/database_helper.dart';
import '../models/category.dart';
import '../models/food_item.dart';
import '../Widget/banner.dart';
import '../Widget/my_icon_button.dart';
import '../Widget/food_items_display.dart';
import 'view_all_items.dart';
import 'package:provider/provider.dart';
import '../Provider/favorite_provider.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String selectedCategory = "All"; // 默认选择 "All"
  List<Category> categories = [];
  late Future<List<FoodItem>> foodItemsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    // 直接初始化 foodItemsFuture
    foodItemsFuture = DatabaseHelper().getFoodItems(
      category: selectedCategory == "All" ? null : selectedCategory,
    );
  }

  // 加载类别数据
  Future<void> _loadCategories() async {
    List<Category> fetchedCategories = await DatabaseHelper().getCategories();
    setState(() {
      categories = fetchedCategories;
    });
  }

  // 当选择类别时更新
  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      foodItemsFuture = DatabaseHelper().getFoodItems(
        category: selectedCategory == "All" ? null : selectedCategory,
      );
    });
  }

  // 处理搜索功能
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      foodItemsFuture = DatabaseHelper().searchFoodItems(
        query,
        category: selectedCategory == "All" ? null : selectedCategory,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                headerParts(),
                mySearchBar(),
                const BannerToExplore(),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 横向滚动的类别按钮
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // "All" 类别按钮
                      GestureDetector(
                        onTap: () => _onCategorySelected("All"),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: selectedCategory == "All"
                                ? kprimaryColor
                                : Colors.grey[200],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          margin: const EdgeInsets.only(right: 15),
                          child: Text(
                            "All",
                            style: TextStyle(
                              color: selectedCategory == "All"
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // 动态生成的类别按钮
                      ...categories.map((category) {
                        bool isSelected = selectedCategory == category.name;
                        return GestureDetector(
                          onTap: () => _onCategorySelected(category.name),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: isSelected
                                  ? kprimaryColor
                                  : Colors.grey[200],
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            margin: const EdgeInsets.only(right: 15),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 显示选择的类别
                Text(
                  selectedCategory != "All"
                      ? "$selectedCategory 类别"
                      : "所有类别",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // 根据选择的类别显示食物项
                FutureBuilder<List<FoodItem>>(
                  future: foodItemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No food items available');
                    } else {
                      List<FoodItem> foodItems = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.only(top: 5, left: 15),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: foodItems.map((item) {
                              return FoodItemsDisplay(
                                foodItem: item,
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                // "Quick & Easy" 部分
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Quick & Easy",
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ViewAllItems(),
                          ),
                        );
                      },
                      child: const Text(
                        "View all",
                        style: TextStyle(
                          color: kBannerColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                // 显示所有食物项
                FutureBuilder<List<FoodItem>>(
                  future: DatabaseHelper().getFoodItems(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No food items available');
                    } else {
                      List<FoodItem> foodItems = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.only(top: 5, left: 15),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: foodItems.map((item) {
                              return FoodItemsDisplay(
                                foodItem: item,
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 搜索栏组件
  Padding mySearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          prefixIcon: const Icon(Iconsax.search_normal),
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintText: "Search any recipes",
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        onChanged: (value) {
          _onSearchChanged(value);
        },
      ),
    );
  }

  // 头部组件
  Row headerParts() {
    return Row(
      children: [
        const Text(
          "What are you\ncooking today?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const Spacer(),
        MyIconButton(
          icon: Iconsax.notification, // 指定按钮图标
          pressed: () {},
        ),
      ],
    );
  }
}
