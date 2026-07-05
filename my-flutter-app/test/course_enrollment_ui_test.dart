import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/features/courses/course_details_screen.dart';

void main() {
  test('uses the same enrollment labels as Angular for enrolled and free courses', () {
    expect(
      getEnrollmentButtonLabel(isEnrolled: true, isOwner: false, price: 120, isStudent: true),
      'Continue Learning',
    );
    expect(
      getEnrollmentButtonLabel(isEnrolled: false, isOwner: false, price: 0, isStudent: true),
      'Enroll Free',
    );
    expect(
      getEnrollmentButtonLabel(isEnrolled: false, isOwner: false, price: 120, isStudent: true),
      'Buy for \$120.00',
    );
  });

  test('formats paid course prices with a currency-style value', () {
    expect(formatCoursePrice(120), '\$120.00');
    expect(formatCoursePrice(0), 'Free');
  });
}
