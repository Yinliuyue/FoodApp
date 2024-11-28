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
  String selectedCategory = "All"; // 默认选择 "All"
  List<model.Category> categories = [];
  List<FoodItem> randomItems = [];
  List<FoodItem> quickEasyItems = [];
  List<FoodItem> categoryItems = [];
  bool isLoadingRandom = true;
  bool isLoadingQuickEasy = true;
  bool isLoadingCategory = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    // 移除此行，避免重复调用 _fetchContent
    // _fetchContent();
  }

  // 加载类别数据并在前面添加一个 "All" 类别
  Future<void> _loadCategories() async {
    List<model.Category> fetchedCategories = await DatabaseHelper().getCategories();
    setState(() {
      categories = [
        model.Category(id: 0, name: "All"),
        ...fetchedCategories,
      ];
    });
    _fetchContent(); // 在加载类别后唯一调用
  }

  // 根据选中类别获取内容
  Future<void> _fetchContent() async {
    print('Fetching content for category: $selectedCategory'); // 调试日志
    if (selectedCategory == "All") {
      // 获取随机物品
      List<FoodItem> fetchedRandomItems = await DatabaseHelper().getRandomItemsFromEachCategory(limitPerCategory: 2);

      // 去重 (确保 FoodItem 实现了 == 和 hashCode)
      fetchedRandomItems = fetchedRandomItems.toSet().toList();

      setState(() {
        randomItems = fetchedRandomItems;
        isLoadingRandom = false;
        // 清空其他列表
        quickEasyItems = [];
        categoryItems = [];
        isLoadingQuickEasy = false;
        isLoadingCategory = false;
      });
    } else {
      // 获取“Quick & Easy”物品
      List<FoodItem> fetchedQuickEasy = await DatabaseHelper().getQuickEasyItems(selectedCategory, maxCalories: 500, maxTime: 30);
      // 获取该类别的所有物品
      List<FoodItem> fetchedCategoryItems = await DatabaseHelper().getFoodItems(category: selectedCategory);

      setState(() {
        quickEasyItems = fetchedQuickEasy;
        categoryItems = fetchedCategoryItems;
        isLoadingQuickEasy = false;
        isLoadingCategory = false;
        // 清空随机物品
        randomItems = [];
        isLoadingRandom = false;
      });
    }
  }

  // 当选择类别时更新
  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      // 重置加载状态
      isLoadingRandom = selectedCategory == "All";
      isLoadingQuickEasy = selectedCategory != "All";
      isLoadingCategory = selectedCategory != "All";
    });
    _fetchContent();
  }

  // 处理搜索功能
  void _onSearchChanged(String query) {
    // 根据需要实现搜索功能
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
                // 根据选中类别展示不同内容
                selectedCategory == "All"
                    ? _buildAllContent()
                    : _buildCategoryContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建“All”页面内容
  Widget _buildAllContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 随机推荐部分标题
        Text(
          "随机推荐",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // 根据加载状态显示内容
        isLoadingRandom
            ? const CircularProgressIndicator()
            : randomItems.isEmpty
            ? const Text("没有随机推荐的物品")
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
      ],
    );
  }

  // 构建特定类别页面内容
  Widget _buildCategoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // “Quick & Easy”物品部分
        Text(
          "Quick & Easy",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        isLoadingQuickEasy
            ? const CircularProgressIndicator()
            : quickEasyItems.isEmpty
            ? const Text("没有“Quick & Easy”物品")
            : SizedBox(
          height: 200, // 根据需要调整高度
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: quickEasyItems.length,
            itemBuilder: (context, index) {
              return FoodItemsDisplay(
                  foodItem: quickEasyItems[index]);
            },
          ),
        ),
        SizedBox(height: quickEasyItems.isEmpty ? 0 : 20),
        // 该类别的所有物品部分
        Text(
          "$selectedCategory 类别的所有物品",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        // const SizedBox(height: 10),
        //view all按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                // 打开弹窗显示所有推荐物品和该类别的所有物品
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 标题
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "所有推荐物品",
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
                            // 所有推荐物品列表
                            FutureBuilder<List<FoodItem>>(
                              future: DatabaseHelper().getRecommendedItems(limit: 20),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('错误: ${snapshot.error}');
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Text('没有推荐的物品');
                                } else {
                                  // 去重推荐物品
                                  List<FoodItem> uniqueRecommended = snapshot.data!.toSet().toList();
                                  return GridView.builder(
                                    itemCount: uniqueRecommended.length,
                                    shrinkWrap: true, // 自适应高度
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 3 / 4,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemBuilder: (context, index) {
                                      return FoodItemsDisplay(
                                          foodItem: uniqueRecommended[index]);
                                    },
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            Divider(),
                            const SizedBox(height: 10),
                            // 标题
                            Text(
                              "所有 $selectedCategory 类别的物品",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            // 该类别的所有物品列表
                            FutureBuilder<List<FoodItem>>(
                              future: DatabaseHelper()
                                  .getFoodItems(category: selectedCategory),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('错误: ${snapshot.error}');
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Text('该类别中没有物品');
                                } else {
                                  // 去重类别物品
                                  List<FoodItem> uniqueCategory = snapshot.data!.toSet().toList();
                                  return GridView.builder(
                                    itemCount: uniqueCategory.length,
                                    shrinkWrap: true, // 自适应高度
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 3 / 4,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemBuilder: (context, index) {
                                      return FoodItemsDisplay(
                                          foodItem: uniqueCategory[index]);
                                    },
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
              },
              child: const Text(
                "View All",
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
          physics: NeverScrollableScrollPhysics(), // 禁止滚动
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
          hintText: "搜索食谱",
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
          "今天你想做什么？",
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