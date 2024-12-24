// import 'package:flutter/material.dart';
// import '../Utils/constants.dart';
//
// class BannerToExplore extends StatelessWidget {
//   const BannerToExplore({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 170,
//       // 设置背景为透明
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         color: Colors.transparent,
//       ),
//       child: Stack(
//         children: [
//           // 左边的文字和按钮
//           Positioned(
//             top: 32,
//             left: 20,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 修改文字颜色为 kBannerColor
//                 const Text(
//                   "今天你有好好吃饭吗",
//                   style: TextStyle(
//                     height: 1.1,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: kBannerColor, // 使用 kBannerColor 作为文字颜色
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 33,
//                     ),
//                     backgroundColor: kBannerColor, // 按钮背景颜色改为 kBannerColor
//                     elevation: 0,
//                   ),
//                   onPressed: () {},
//                   child: const Text(
//                     "Explore",
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white, // 按钮文字颜色保持白色
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // 右边的本地资产图片
//           Positioned(
//             top: 0,
//             bottom: 0,
//             right: -20,
//             child: Image.asset(
//               'assets/images/cat.jpg', // 使用本地资产图片
//               fit: BoxFit.cover,
//               width: 150, // 根据需要调整图片宽度
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/Widget/banner.dart

import 'package:flutter/material.dart';
import '../Utils/constants.dart';

typedef OnSearchChanged = void Function(String query);

class BannerToExplore extends StatefulWidget {
  final OnSearchChanged onSearchChanged;

  const BannerToExplore({super.key, required this.onSearchChanged});

  @override
  State<BannerToExplore> createState() => _BannerToExploreState();
}

class _BannerToExploreState extends State<BannerToExplore> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      // 设置背景为透明
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.transparent,
      ),
      child: Stack(
        children: [
          // 左边的文字
          Positioned(
            top: 32,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 修改文字颜色为 kBannerColor
                const Text(
                  "今天也有在好好吃饭",
                  style: TextStyle(
                    height: 1.1,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kBannerColor, // 使用 kBannerColor 作为文字颜色
                  ),
                ),
                const SizedBox(height: 10),
                // 替换 "Explore" 按钮为搜索框
                Container(
                  width: 200, // 根据需要调整宽度
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                          FocusScope.of(context).unfocus(); // 关闭键盘
                        },
                      )
                          : null,
                      hintText: "探索美食吧！",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 右边的本地资产图片
          Positioned(
            top: 0,
            bottom: 0,
            right: -20,
            child: Image.asset(
              'assets/images/cat.jpg', // 使用本地资产图片
              fit: BoxFit.cover,
              width: 150, // 根据需要调整图片宽度
            ),
          ),
        ],
      ),
    );
  }
}
