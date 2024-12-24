// lib/Views/my_app_home_screen.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../Utils/constants.dart';
import '../Utils/database_helper.dart';
import 'package:miniapp/models/category.dart' as model;
import 'package:miniapp/models/food_item.dart';
import '../Widget/banner.dart';
import '../Widget/my_icon_button.dart';
import '../Widget/food_items_display.dart';
import 'package:provider/provider.dart';
import '../Provider/favorite_provider.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String selectedCategory = "所有"; // 默认选择 "所有"
  List<model.Category> categories = [];
  List<FoodItem> randomItems = [];
  List<FoodItem> quickEasyItems = [];
  List<FoodItem> categoryItems = [];
  List<FoodItem> allCategoryItems = []; // 用于展示所有类别的所有物品
  List<FoodItem> searchResults = []; // 搜索结果
  bool isLoadingRandom = true;
  bool isLoadingQuickEasy = true;
  bool isLoadingCategory = true;
  bool isLoadingAllCategory = true;
  bool isLoadingSearch = false; // 搜索加载状态
  String searchQuery = ""; // 当前搜索查询

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 加载类别数据
  Future<void> _loadCategories() async {
    List<model.Category> fetchedCategories = await DatabaseHelper().getCategories();
    print("Fetched Categories: ${fetchedCategories.map((c) => c.name).toList()}");

    setState(() {
      categories = fetchedCategories;
    });

    _fetchContent(); // 在加载类别后唯一调用
  }

  // 根据选中类别或搜索查询获取内容
  Future<void> _fetchContent() async {
    if (searchQuery.isNotEmpty) {
      // 如果有搜索查询，获取搜索结果
      await _fetchSearchResults();
    } else {
      // 没有搜索查询，根据选中类别获取内容
      print('Fetching content for category: $selectedCategory'); // 调试日志
      if (selectedCategory == "所有") {
        // 获取随机物品
        List<FoodItem> fetchedRandomItems = await DatabaseHelper().getRandomItemsFromEachCategory(limitPerCategory: 2);

        // 去重 (确保 FoodItem 实现了 == 和 hashCode)
        fetchedRandomItems = fetchedRandomItems.toSet().toList();

        // 获取所有类别的所有物品
        List<FoodItem> fetchedAllCategoryItems = await DatabaseHelper().getFoodItems();
        fetchedAllCategoryItems = fetchedAllCategoryItems.toSet().toList();

        setState(() {
          randomItems = fetchedRandomItems;
          allCategoryItems = fetchedAllCategoryItems;
          isLoadingRandom = false;
          isLoadingAllCategory = false;

          // 清空其他列表
          quickEasyItems = [];
          categoryItems = [];
          isLoadingQuickEasy = false;
          isLoadingCategory = false;
        });
      } else {
        // 获取“快速简单”物品
        List<FoodItem> fetchedQuickEasy = await DatabaseHelper().getQuickEasyItems(
          selectedCategory,
          maxCalories: 500,
          maxTime: 30,
        );

        // 获取该类别的所有物品
        List<FoodItem> fetchedCategoryItems = await DatabaseHelper().getFoodItems(category: selectedCategory);

        setState(() {
          quickEasyItems = fetchedQuickEasy;
          categoryItems = fetchedCategoryItems;
          isLoadingQuickEasy = false;
          isLoadingCategory = false;

          // 清空随机物品和所有类别物品
          randomItems = [];
          allCategoryItems = [];
          isLoadingRandom = false;
          isLoadingAllCategory = false;
        });
      }
    }
  }

  // 当选择类别时更新
  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      // 重置加载状态
      isLoadingRandom = selectedCategory == "所有";
      isLoadingQuickEasy = selectedCategory != "所有";
      isLoadingCategory = selectedCategory != "所有";
      isLoadingAllCategory = selectedCategory == "所有";
      searchQuery = "";
      searchResults = [];
    });
    _fetchContent();
  }

  // 处理搜索功能
  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query.trim();
    });
    _fetchContent();
  }

  // 获取搜索结果
  Future<void> _fetchSearchResults() async {
    if (searchQuery.isEmpty) {
      setState(() {
        searchResults = [];
        isLoadingSearch = false;
      });
      return;
    }

    setState(() {
      isLoadingSearch = true;
    });

    try {
      List<FoodItem> results = await DatabaseHelper().searchFoodItems(
        searchQuery,
        category: selectedCategory == "所有" ? null : selectedCategory,
      );
      setState(() {
        searchResults = results;
        isLoadingSearch = false;
      });
    } catch (e) {
      print("搜索失败: $e");
      setState(() {
        searchResults = [];
        isLoadingSearch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building UI with categories: ${categories.map((c) => c.name).toList()}");
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
                // 替换现有的搜索框为 BannerToExplore 中的搜索框
                BannerToExplore(onSearchChanged: _onSearchChanged),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Text(
                    "菜系总览", // 将 "Categories" 替换为中文 "类别"
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
                    children: categories.map((category) {
                      bool isSelected = selectedCategory == category.name;
                      return GestureDetector(
                        onTap: () => _onCategorySelected(category.name),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: isSelected ? kprimaryColor : Colors.grey[200],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          margin: const EdgeInsets.only(right: 15),
                          child: Text(
                            category.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                // 根据是否有搜索查询展示不同内容
                searchQuery.isNotEmpty
                    ? _buildSearchContent()
                    : (selectedCategory == "所有"
                    ? _buildAllContent()
                    : _buildCategoryContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 搜索结果内容
  Widget _buildSearchContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "搜索结果",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        isLoadingSearch
            ? const CircularProgressIndicator()
            : searchResults.isEmpty
            ? const Text("没有匹配的物品")
            : GridView.builder(
          itemCount: searchResults.length,
          shrinkWrap: true, // 适应内容高度
          physics: NeverScrollableScrollPhysics(), // 禁止内部滚动
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 每行两个项目
            childAspectRatio: 3 / 4, // 设置宽高比
            crossAxisSpacing: 10, // 列间距
            mainAxisSpacing: 10, // 行间距
          ),
          itemBuilder: (context, index) {
            return FoodItemsDisplay(foodItem: searchResults[index]);
          },
        ),
      ],
    );
  }

  // 构建“所有”页面内容
  Widget _buildAllContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 随机推荐部分标题
        Text(
          "今日推荐",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // 根据加载状态显示随机推荐内容
        isLoadingRandom
            ? const CircularProgressIndicator()
            : randomItems.isEmpty
            ? const Text("没有推荐的物品")
            : GridView.builder(
          itemCount: randomItems.length,
          shrinkWrap: true, // 适应内容高度
          physics: NeverScrollableScrollPhysics(), // 禁止内部滚动
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 每行两个项目
            childAspectRatio: 3 / 4, // 设置宽高比
            crossAxisSpacing: 10, // 列间距
            mainAxisSpacing: 10, // 行间距
          ),
          itemBuilder: (context, index) {
            return FoodItemsDisplay(foodItem: randomItems[index]);
          },
        ),
        const SizedBox(height: 30), // 增加空间分隔
        // 所有类别的所有物品部分标题
        Text(
          "所有菜品",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // 根据加载状态显示所有类别的所有物品
        isLoadingAllCategory
            ? const CircularProgressIndicator()
            : allCategoryItems.isEmpty
            ? const Text("没有物品")
            : GridView.builder(
          itemCount: allCategoryItems.length,
          shrinkWrap: true, // 适应内容高度
          physics: NeverScrollableScrollPhysics(), // 禁止内部滚动
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 每行两个项目
            childAspectRatio: 3 / 4, // 设置宽高比
            crossAxisSpacing: 10, // 列间距
            mainAxisSpacing: 10, // 行间距
          ),
          itemBuilder: (context, index) {
            return FoodItemsDisplay(foodItem: allCategoryItems[index]);
          },
        ),
      ],
    );
  }

  // 构建特定类别页面内容
  Widget _buildCategoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // “快速简单”物品部分
        Text(
          "猜你喜欢",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        isLoadingQuickEasy
            ? const CircularProgressIndicator()
            : quickEasyItems.isEmpty
            ? const Text("没有物品")
            : SizedBox(
          height: 200, // 根据需要调整高度
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: quickEasyItems.length,
            itemBuilder: (context, index) {
              return FoodItemsDisplay(foodItem: quickEasyItems[index]);
            },
          ),
        ),
        SizedBox(height: quickEasyItems.isEmpty ? 0 : 20),
        // 该类别的收藏物品部分标题
        Text(
          "总览",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        // 查看全部按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () async {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: FutureBuilder<List<FoodItem>>(
                        future: DatabaseHelper().getFavoriteFoodItemsByCategory(selectedCategory),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('错误: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('该类别中没有收藏的物品');
                          } else {
                            // 去重类别物品
                            List<FoodItem> uniqueFavorites = snapshot.data!.toSet().toList();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 标题
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "我收藏的$selectedCategory",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // 收藏物品列表
                                Expanded(
                                  child: GridView.builder(
                                    itemCount: uniqueFavorites.length,
                                    shrinkWrap: true, // 自适应高度
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 3 / 4,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemBuilder: (context, index) {
                                      return FoodItemsDisplay(foodItem: uniqueFavorites[index]);
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
              child: const Text(
                "查看收藏",
                style: TextStyle(
                  color: kprimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        isLoadingCategory
            ? const CircularProgressIndicator()
            : categoryItems.isEmpty
            ? const Text("该类别中没有物品")
            : GridView.builder(
          itemCount: categoryItems.length,
          shrinkWrap: true,
          physics:
          NeverScrollableScrollPhysics(), // 禁止滚动
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 两列
            childAspectRatio: 3 / 4, // 宽高比
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final foodItem = categoryItems[index];
            return FoodItemsDisplay(foodItem: foodItem);
          },
        ),
        SizedBox(height: categoryItems.isEmpty ? 0 : 20),
      ],
    );
  }
}

