class Food {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? image; // Caminho da imagem (ex: /media/foods/burger.jpg)

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.image,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      category: json['category'],
      image: json['image'],
    );
  }
}