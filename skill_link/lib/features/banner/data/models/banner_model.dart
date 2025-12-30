class BannerModel {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? ctaText;
  final String targetType;
  final String? targetValue;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime? deletedAt;

  BannerModel({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.ctaText,
    required this.targetType,
    this.targetValue,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.deletedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
      ctaText: json['ctaText'],
      targetType: json['targetType'] ?? 'externalLink',
      targetValue: json['targetValue'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] == null ? true : (json['isActive'] as bool),
      deletedAt:
          json['deletedAt'] == null
              ? null
              : DateTime.tryParse(json['deletedAt']),
    );
  }
}
