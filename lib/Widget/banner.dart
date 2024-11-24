import 'package:flutter/material.dart';
import '../Utils/constants.dart';

class BannerToExplore extends StatelessWidget {
  const BannerToExplore({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: kBannerColor,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 32,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Cook the best\nrecipes at home",
                  style: TextStyle(
                    height: 1.1,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 33,
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Explore",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: -20,
            child: Image.network(
              "https://cn.bing.com/images/search?view=detailV2&ccid=c0kgjWt4&id=0911CC01AA73FCA70C137FD5D46264BD4B7A5602&thid=OIP.c0kgjWt4PeSsL1AvweHpLQHaFj&mediaurl=https%3a%2f%2fimg.zcool.cn%2fcommunity%2f01f1b5602340b711013f7928e5f4e5.jpg%3fx-oss-process%3dimage%2fauto-orient%2c1%2fresize%2cm_lfit%2cw_1280%2climit_1%2fsharpen%2c100&exph=960&expw=1280&q=%e7%94%9c%e5%93%81%e7%85%a7%e7%89%87&FORM=IRPRST&ck=963E0CA288DC930C06E7ECD18038C528&selectedIndex=21&itb=0",
            ),
          ),
        ],
      ),
    );
  }
}