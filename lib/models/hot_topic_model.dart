class HotTopic {
  final String id;
  final String title;
  final String description;
  final String category;
  final int popularity; // 热度值
  final List<String> tags;
  final DateTime createdAt;
  final String? imageUrl;
  final Map<String, dynamic> characterTemplate; // 角色模板数据

  HotTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.popularity,
    required this.tags,
    required this.createdAt,
    this.imageUrl,
    required this.characterTemplate,
  });

  factory HotTopic.fromJson(Map<String, dynamic> json) {
    return HotTopic(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      popularity: json['popularity'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      imageUrl: json['image_url'],
      characterTemplate: json['character_template'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'popularity': popularity,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
      'character_template': characterTemplate,
    };
  }

  HotTopic copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? popularity,
    List<String>? tags,
    DateTime? createdAt,
    String? imageUrl,
    Map<String, dynamic>? characterTemplate,
  }) {
    return HotTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      popularity: popularity ?? this.popularity,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      characterTemplate: characterTemplate ?? this.characterTemplate,
    );
  }
}