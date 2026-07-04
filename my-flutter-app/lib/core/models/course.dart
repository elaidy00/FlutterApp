class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.description,
    required this.level,
    required this.duration,
    required this.price,
    required this.rating,
    required this.lessons,
    required this.tag,
  });

  final String id;
  final String title;
  final String instructor;
  final String description;
  final String level;
  final String duration;
  final String price;
  final double rating;
  final int lessons;
  final String tag;

  factory CourseModel.fromApi(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      instructor: json['instructorName']?.toString() ?? 'Unknown instructor',
      description: json['description']?.toString() ?? '',
      level: json['level']?.toString() ?? 'Beginner',
      duration: 'Self-paced',
      price: json['price']?.toString() ?? '0',
      rating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      lessons: 0,
      tag: json['subjectName']?.toString() ?? 'General',
    );
  }
}
