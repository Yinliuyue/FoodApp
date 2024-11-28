
class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  // 从 Map 创建 Category 对象
  factory Category.fromMap(Map<String, dynamic> map) {
    print('Reading category: id=${map['id']} (${map['id'].runtimeType}), name=${map['name']} (${map['name'].runtimeType})');

    return Category(
      id: map['id'] as int,
      name: map['name'].toString(), // 强制转换 name 为 String
    );
  }

  // 将 Category 对象转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name}';
  }
}