class CreateBookingDto {
  CreateBookingDto({required this.studentId, required this.instructorId, required this.startTime, required this.endTime});

  final String studentId;
  final String instructorId;
  final DateTime startTime;
  final DateTime endTime;

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'instructorId': instructorId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      };
}

class BookingResponseDto {
  BookingResponseDto({required this.id, required this.status, required this.title});

  factory BookingResponseDto.fromJson(Map<String, dynamic> json) => BookingResponseDto(
        id: json['id'] as String,
        status: json['status'] as String? ?? '',
        title: json['title'] as String? ?? '',
      );

  final String id;
  final String status;
  final String title;
}

class CreatePublicBookingDto {
  CreatePublicBookingDto({required this.title, required this.description, required this.price, required this.startTime, required this.endTime});

  final String title;
  final String description;
  final int price;
  final DateTime startTime;
  final DateTime endTime;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'price': price,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      };
}

class PublicBookingResponseDto {
  PublicBookingResponseDto({required this.id, required this.title, required this.status});

  factory PublicBookingResponseDto.fromJson(Map<String, dynamic> json) => PublicBookingResponseDto(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        status: json['status'] as String? ?? '',
      );

  final String id;
  final String title;
  final String status;
}

