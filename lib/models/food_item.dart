// // lib/models/food_item.dart
//
// class FoodItem {
//   final int idEvery;
//   final String name;
//   final int cal;
//   final String category;
//   final String imagePath;
//   final double rate;
//   final int reviews;
//   final int time;
//   final String? introduction; // 可为空
//   final String content;
//   final String? taste; // 可为空
//   final String? source; // 可为空
//
//   FoodItem({
//     required this.idEvery,
//     required this.name,
//     required this.cal,
//     required this.category,
//     required this.imagePath,
//     required this.rate,
//     required this.reviews,
//     required this.time,
//     this.introduction, // 设置为可选
//     required this.content,
//     this.taste, // 设置为可选
//     this.source, // 设置为可选
//   });
//
//   // 工厂方法：从 Map 构造对象
//   factory FoodItem.fromMap(Map<String, dynamic> map) {
//     return FoodItem(
//       idEvery: map['id_every'] as int,
//       name: map['name'] as String,
//       cal: map['cal'] as int,
//       category: map['category'] as String,
//       imagePath: map['image_path'] as String,
//       rate: (map['rate'] as num).toDouble(),
//       reviews: map['reviews'] as int,
//       time: map['time'] as int,
//       introduction: map['introduction'] as String?, // 可为空
//       content: map['content'] as String,
//       taste: map['taste'] as String?, // 可为空
//       source: map['source'] as String?, // 可为空
//     );
//   }
//
//   // 将对象转换为 Map
//   Map<String, dynamic> toMap() {
//     return {
//       'id_every': idEvery,
//       'name': name,
//       'cal': cal,
//       'category': category,
//       'image_path': imagePath,
//       'rate': rate,
//       'reviews': reviews,
//       'time': time,
//       'introduction': introduction, // 可为空
//       'content': content,
//       'taste': taste, // 可为空
//       'source': source, // 可为空
//     };
//   }
//
//   // 返回带有修改值的新对象
//   FoodItem copyWith({
//     int? idEvery,
//     String? name,
//     int? cal,
//     String? category,
//     String? imagePath,
//     double? rate,
//     int? reviews,
//     int? time,
//     String? introduction, // 可为空
//     String? content,
//     String? taste, // 可为空
//     String? source, // 可为空
//   }) {
//     return FoodItem(
//       idEvery: idEvery ?? this.idEvery,
//       name: name ?? this.name,
//       cal: cal ?? this.cal,
//       category: category ?? this.category,
//       imagePath: imagePath ?? this.imagePath,
//       rate: rate ?? this.rate,
//       reviews: reviews ?? this.reviews,
//       time: time ?? this.time,
//       introduction: introduction ?? this.introduction, // 可为空
//       content: content ?? this.content,
//       taste: taste ?? this.taste, // 可为空
//       source: source ?? this.source, // 可为空
//     );
//   }
// }


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
  final String? introduction; // 可为空
  final String content;
  final String? taste; // 可为空
  final String? source; // 可为空

  FoodItem({
    required this.idEvery,
    required this.name,
    required this.cal,
    required this.category,
    required this.imagePath,
    required this.rate,
    required this.reviews,
    required this.time,
    this.introduction, // 设置为可选
    required this.content,
    this.taste, // 设置为可选
    this.source, // 设置为可选
  });

  // 工厂方法：从 Map 构造对象
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    double parsedRate = 0.0;

    if (map['rate'] is num) {
      parsedRate = (map['rate'] as num).toDouble();
    } else if (map['rate'] is String) {
      parsedRate = double.tryParse(map['rate']) ?? 0.0;
      if (parsedRate == 0.0) {
        print("警告: 无法解析 'rate' 字段为数字，默认值 0.0");
      }
    } else {
      print("警告: 'rate' 字段的类型未知，默认值 0.0");
    }

    return FoodItem(
      idEvery: map['id_every'] is int ? map['id_every'] as int : 0,
      name: map['name']?.toString() ?? "Unnamed",
      cal: map['cal'] is int ? map['cal'] as int : 0,
      category: map['category']?.toString() ?? "Uncategorized",
      imagePath: map['image_path']?.toString() ?? "default.png",
      rate: parsedRate,
      reviews: map['reviews'] is int ? map['reviews'] as int : 0,
      time: map['time'] is int ? map['time'] as int : 0,
      introduction: map['introduction']?.toString(),
      content: map['content']?.toString() ?? "",
      taste: map['taste']?.toString(),
      source: map['source']?.toString(),
    );
  }

  // 将对象转换为 Map
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
      'introduction': introduction, // 可为空
      'content': content,
      'taste': taste, // 可为空
      'source': source, // 可为空
    };
  }

  // 返回带有修改值的新对象
  FoodItem copyWith({
    int? idEvery,
    String? name,
    int? cal,
    String? category,
    String? imagePath,
    double? rate,
    int? reviews,
    int? time,
    String? introduction, // 可为空
    String? content,
    String? taste, // 可为空
    String? source, // 可为空
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
      introduction: introduction ?? this.introduction, // 可为空
      content: content ?? this.content,
      taste: taste ?? this.taste, // 可为空
      source: source ?? this.source, // 可为空
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FoodItem &&
              runtimeType == other.runtimeType &&
              idEvery == other.idEvery;

  @override
  int get hashCode => idEvery.hashCode;
}
