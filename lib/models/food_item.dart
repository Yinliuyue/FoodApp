// lib/models/food_item.dart

class FoodItem {
  final int idEvery;
  final String name;
  final int cal;
  final String category;
  final String imagePath;
  final double rate;
  final int reviews;
  final int time;

  FoodItem({
    required this.idEvery,
    required this.name,
    required this.cal,
    required this.category,
    required this.imagePath,
    required this.rate,
    required this.reviews,
    required this.time,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      idEvery: map['id_every'] as int,
      name: map['name'] as String,
      cal: map['cal'] as int,
      category: map['category'] as String,
      imagePath: map['image_path'] as String,
      rate: (map['rate'] as num).toDouble(),
      reviews: map['reviews'] as int,
      time: map['time'] as int,
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
    };
  }

  FoodItem copyWith({
    int? idEvery,
    String? name,
    int? cal,
    String? category,
    String? imagePath,
    double? rate,
    int? reviews,
    int? time,
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
    );
  }
}
