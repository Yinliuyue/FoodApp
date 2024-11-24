
// lib/models/food_item.dart

import 'dart:convert';

class FoodItem {
  final int idEvery;
  final String name;
  final int cal;
  final String category;
  final String imagePath;
  final double rate;
  final int reviews;
  final int time;
  final List<double> ingredientsAmount;
  final List<String> ingredientsName;
  final List<String> ingredientsImage;

  FoodItem({
    required this.idEvery,
    required this.name,
    required this.cal,
    required this.category,
    required this.imagePath,
    required this.rate,
    required this.reviews,
    required this.time,
    required this.ingredientsAmount,
    required this.ingredientsName,
    required this.ingredientsImage,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    List<dynamic> ingredientsAmountDynamic =
    json.decode(map['ingredientsAmount'] ?? '[]');
    List<dynamic> ingredientsNameDynamic =
    json.decode(map['ingredientsName'] ?? '[]');
    List<dynamic> ingredientsImageDynamic =
    json.decode(map['ingredientsImage'] ?? '[]');

    return FoodItem(
      idEvery: map['id_every'] as int,
      name: map['name'] as String,
      cal: map['cal'] as int,
      category: map['category'] as String,
      imagePath: map['image_path'] as String,
      rate: (map['rate'] as num).toDouble(),
      reviews: map['reviews'] as int,
      time: map['time'] as int,
      ingredientsAmount:
      ingredientsAmountDynamic.map<double>((e) => e.toDouble()).toList(),
      ingredientsName:
      ingredientsNameDynamic.map<String>((e) => e.toString()).toList(),
      ingredientsImage:
      ingredientsImageDynamic.map<String>((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_every': idEvery,
      'name': name,
      'cal': cal,
      'category': category,
      'image_path': imagePath,
      'rate': rate,
      'reviews': reviews,
      'time': time,
      'ingredientsAmount': json.encode(ingredientsAmount),
      'ingredientsName': json.encode(ingredientsName),
      'ingredientsImage': json.encode(ingredientsImage),
    };
  }

  // 可选：实现 copyWith 方法，以便更新 FoodItem 对象
  FoodItem copyWith({
    int? idEvery,
    String? name,
    int? cal,
    String? category,
    String? imagePath,
    double? rate,
    int? reviews,
    int? time,
    List<double>? ingredientsAmount,
    List<String>? ingredientsName,
    List<String>? ingredientsImage,
  }) {
    return FoodItem(
      idEvery: idEvery ?? this.idEvery,
      name: name ?? this.name,
      cal: cal ?? this.cal,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      rate: rate ?? this.rate,
      reviews: reviews ?? this.reviews,
      time: time ?? this.time,
      ingredientsAmount: ingredientsAmount ?? this.ingredientsAmount,
      ingredientsName: ingredientsName ?? this.ingredientsName,
      ingredientsImage: ingredientsImage ?? this.ingredientsImage,
    );
  }
}
