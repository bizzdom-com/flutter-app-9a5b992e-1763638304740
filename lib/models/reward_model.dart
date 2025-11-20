class RewardModel {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int costPoints;
  final DateTime createdAt;
  final DateTime updatedAt;

  RewardModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.costPoints,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      costPoints: json['cost_points'] as int,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'cost_points': costPoints,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}