import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/core/models/course.dart';

void main() {
  test('maps backend course payload to CourseModel', () {
    final course = CourseModel.fromApi({
      'id': '11111111-1111-1111-1111-111111111111',
      'title': 'API Course',
      'description': 'Loaded from the .NET backend',
      'price': 199,
      'level': 'Intermediate',
      'instructorName': 'Mina Hassan',
      'subjectName': 'Design',
      'averageRating': 4.7,
      'reviewsCount': 12,
      'isEnrolled': true,
    });

    expect(course.title, 'API Course');
    expect(course.instructor, 'Mina Hassan');
    expect(course.price, '199');
    expect(course.level, 'Intermediate');
    expect(course.tag, 'Design');
    expect(course.rating, 4.7);
  });
}
