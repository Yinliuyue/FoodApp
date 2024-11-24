// // lib/Views/recipe_detail_screen.dart
//
// import 'package:flutter/material.dart';
// import '../Provider/favorite_provider.dart';
// import '../Provider/quantity.dart';
// import '../Utils/constants.dart';
// import '../Widget/my_icon_button.dart';
// import '../Widget/quantity_increment_decrement.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:provider/provider.dart';
// import '../models/food_item.dart';
//
// class RecipeDetailScreen extends StatefulWidget {
//   final FoodItem foodItem;
//   const RecipeDetailScreen({super.key, required this.foodItem});
//
//   @override
//   State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
// }
//
// class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // 初始化基础成分数量
//     List<double> baseAmounts = widget.foodItem.ingredientsAmount;
//     Provider.of<QuantityProvider>(context, listen: false)
//         .setBaseIngredientAmounts(baseAmounts);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<FavoriteProvider>(context);
//     final quantityProvider = Provider.of<QuantityProvider>(context);
//     return Scaffold(
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: startCookingAndFavoriteButton(provider),
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               children: [
//                 // 图片
//                 Hero(
//                   tag: widget.foodItem.imagePath, // 使用 imagePath 作为 Hero tag
//                   child: Container(
//                     height: MediaQuery.of(context).size.height / 2.1,
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         fit: BoxFit.cover,
//                         image: AssetImage(
//                           'assets/images/${widget.foodItem.imagePath}', // 从 assets 加载图片
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // 返回和通知按钮
//                 Positioned(
//                   top: 40,
//                   left: 10,
//                   right: 10,
//                   child: Row(
//                     children: [
//                       MyIconButton(
//                         icon: Icons.arrow_back_ios_new,
//                         pressed: () {
//                           Navigator.pop(context);
//                         },
//                       ),
//                       const Spacer(),
//                       MyIconButton(
//                         icon: Iconsax.notification,
//                         pressed: () {},
//                       )
//                     ],
//                   ),
//                 ),
//                 // 其他装饰（如果需要）
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   top: MediaQuery.of(context).size.width,
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             // 拖动手柄
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.foodItem.name,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       const Icon(
//                         Iconsax.flash_1,
//                         size: 20,
//                         color: Colors.grey,
//                       ),
//                       Text(
//                         "${widget.foodItem.cal} Cal",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const Text(
//                         " · ",
//                         style: TextStyle(
//                           fontWeight: FontWeight.w900,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const Icon(
//                         Iconsax.clock,
//                         size: 20,
//                         color: Colors.grey,
//                       ),
//                       const SizedBox(width: 5),
//                       Text(
//                         "${widget.foodItem.time} Min",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   // 评分
//                   Row(
//                     children: [
//                       const Icon(
//                         Iconsax.star1,
//                         color: Colors.amberAccent,
//                       ),
//                       const SizedBox(width: 5),
//                       Text(
//                         widget.foodItem.rate.toString(),
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Text("/5"),
//                       const SizedBox(width: 5),
//                       Text(
//                         "${widget.foodItem.reviews} Reviews",
//                         style: const TextStyle(
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // 成分标题和数量选择器
//                   Row(
//                     children: [
//                       const Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Ingredients",
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 10),
//                           Text(
//                             "How many servings?",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey,
//                             ),
//                           )
//                         ],
//                       ),
//                       const Spacer(),
//                       QuantityIncrementDecrement(
//                         currentNumber: quantityProvider.currentNumber,
//                         onAdd: () => quantityProvider.increaseQuantity(),
//                         onRemov: () => quantityProvider.decreaseQuanity(),
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   // 成分列表
//                   Column(
//                     children: [
//                       Row(
//                         children: [
//                           // 成分图片
//                           Column(
//                             children: widget.foodItem.ingredientsImage
//                                 .map<Widget>((imagePath) {
//                               return Container(
//                                 height: 60,
//                                 width: 60,
//                                 margin: const EdgeInsets.only(bottom: 10),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(20),
//                                   image: DecorationImage(
//                                     fit: BoxFit.cover,
//                                     image: AssetImage(
//                                       'assets/images/$imagePath', // 从 assets 加载成分图片
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                           const SizedBox(width: 20),
//                           // 成分名称
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: widget.foodItem.ingredientsName
//                                 .map<Widget>((ingredient) {
//                               return SizedBox(
//                                 height: 60,
//                                 child: Center(
//                                   child: Text(
//                                     ingredient,
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.grey.shade400,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                           // 成分数量
//                           const Spacer(),
//                           Column(
//                             children: quantityProvider.updateIngredientAmounts
//                                 .map<Widget>((amount) {
//                               return SizedBox(
//                                 height: 60,
//                                 child: Center(
//                                   child: Text(
//                                     "${amount}gm",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.grey.shade400,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   FloatingActionButton startCookingAndFavoriteButton(
//       FavoriteProvider provider) {
//     return FloatingActionButton.extended(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       onPressed: () {},
//       label: Row(
//         children: [
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: kprimaryColor,
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 100, vertical: 13),
//                 foregroundColor: Colors.white),
//             onPressed: () {},
//             child: const Text(
//               "Start Cooking",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 17,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           IconButton(
//             style: IconButton.styleFrom(
//               shape: const CircleBorder(
//                 side: BorderSide(
//                   color: Colors.grey,
//                   width: 2,
//                 ),
//               ),
//             ),
//             onPressed: () {
//               provider.toggleFavorite(widget.foodItem);
//             },
//             icon: Icon(
//               provider.isExist(widget.foodItem)
//                   ? Iconsax.heart5
//                   : Iconsax.heart,
//               color: provider.isExist(widget.foodItem)
//                   ? Colors.red
//                   : Colors.black,
//               size: 22,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/Views/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import '../Provider/favorite_provider.dart';
import '../Provider/quantity.dart';
import '../Utils/constants.dart';
import '../Widget/my_icon_button.dart';
import '../Widget/quantity_increment_decrement.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';

class RecipeDetailScreen extends StatefulWidget {
  final FoodItem foodItem;
  const RecipeDetailScreen({super.key, required this.foodItem});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化基础成分数量
    List<double> baseAmounts = widget.foodItem.ingredientsAmount;
    Provider.of<QuantityProvider>(context, listen: false)
        .setBaseIngredientAmounts(baseAmounts);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoriteProvider>(context);
    final quantityProvider = Provider.of<QuantityProvider>(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: startCookingAndFavoriteButton(provider),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // 图片
                Hero(
                  tag: widget.foodItem.imagePath, // 使用 imagePath 作为 Hero tag
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2.1,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          'assets/images/${widget.foodItem.imagePath}', // 从 assets 加载图片
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
                      )
                    ],
                  ),
                ),
                // 其他装饰（如果需要）
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
                  Text(
                    widget.foodItem.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  // 成分标题和数量选择器
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ingredients",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "How many servings?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                      QuantityIncrementDecrement(
                        currentNumber: quantityProvider.currentNumber,
                        onAdd: () => quantityProvider.increaseQuantity(),
                        onRemov: () => quantityProvider.decreaseQuanity(),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 成分列表
                  Column(
                    children: [
                      Row(
                        children: [
                          // 成分图片
                          Column(
                            children: widget.foodItem.ingredientsImage
                                .map<Widget>((imagePath) {
                              return Container(
                                height: 60,
                                width: 60,
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                      'assets/images/$imagePath', // 从 assets 加载成分图片
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(width: 20),
                          // 成分名称
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.foodItem.ingredientsName
                                .map<Widget>((ingredient) {
                              return SizedBox(
                                height: 60,
                                child: Center(
                                  child: Text(
                                    ingredient,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          // 成分数量
                          const Spacer(),
                          Column(
                            children: quantityProvider.updateIngredientAmounts
                                .map<Widget>((amount) {
                              return SizedBox(
                                height: 60,
                                child: Center(
                                  child: Text(
                                    "${amount}gm",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    ],
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
