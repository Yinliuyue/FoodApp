// lib/models/food_item.dart

class FoodItem {
  final int idEvery;
  final String name;
  final String category;
  final String imagePath;
  final String? introduction; // 可为空
  final String content;
  final String? taste; // 可为空
  final String? source; // 可为空

  FoodItem({
    required this.idEvery,
    required this.name,
    required this.category,
    required this.imagePath,
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
      category: map['category']?.toString() ?? "Uncategorized",
      imagePath: map['image_path']?.toString() ?? "default.png",
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
      'category': category,
      'image_path': imagePath,
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
    String? category,
    String? imagePath,
    String? introduction, // 可为空
    String? content,
    String? taste, // 可为空
    String? source, // 可为空
  }) {
    return FoodItem(
      idEvery: idEvery ?? this.idEvery,
      name: name ?? this.name,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
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
