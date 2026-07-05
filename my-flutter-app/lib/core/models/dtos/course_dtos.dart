class PaginationDto<T> {
  PaginationDto({
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.data,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      PaginationDto<T>(
        pageNumber: (json['pageNumber'] as num).toInt(),
        pageSize: (json['pageSize'] as num).toInt(),
        totalCount: (json['totalCount'] as num).toInt(),
        totalPages: (json['totalPages'] as num).toInt(),
        data: (json['data'] as List<dynamic>? ?? []).map((e) => fromJsonT(e)).toList(),
      );

  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final List<T> data;
}

class CourseResponseDto {
  CourseResponseDto({
    required this.id,
    required this.subjectId,
    required this.instructorId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.level,
    required this.isEnrolled,
    required this.isOwner,
    required this.instructorName,
    required this.instructorBio,
    required this.instructorImageUrl,
    required this.instructorAverageRating,
    required this.instructorReviewsCount,
    required this.instructorTotalStudents,
    required this.subjectName,
    required this.averageRating,
    required this.reviewsCount,
    required this.totalStudents,
    required this.totalLessons,
    required this.lastUpdated,
    this.sections,
  });

  factory CourseResponseDto.fromJson(Map<String, dynamic> json) => CourseResponseDto(
        id: json['id'] is String ? Guid.parse(json['id'] as String) : json['id'],
        subjectId: json['subjectId'] is String ? Guid.parse(json['subjectId'] as String) : json['subjectId'],
        instructorId: json['instructorId'] is String ? Guid.parse(json['instructorId'] as String) : json['instructorId'],
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        level: json['level'] as String? ?? '',
        isEnrolled: json['isEnrolled'] as bool? ?? false,
        isOwner: json['isOwner'] as bool? ?? false,
        instructorName: json['instructorName'] as String? ?? '',
        instructorBio: json['instructorBio'] as String? ?? '',
        instructorImageUrl: json['instructorImageUrl'] as String? ?? '',
        instructorAverageRating: (json['instructorAverageRating'] as num?)?.toDouble() ?? 0,
        instructorReviewsCount: (json['instructorReviewsCount'] as num?)?.toInt() ?? 0,
        instructorTotalStudents: (json['instructorTotalStudents'] as num?)?.toInt() ?? 0,
        subjectName: json['subjectName'] as String? ?? '',
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
        reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
        totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
        totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 0,
        lastUpdated: json['lastUpdated'] == null ? DateTime.now() : DateTime.parse(json['lastUpdated'] as String),
        sections: json['sections'] == null ? null : PaginationDto<SectionResponseDto>.fromJson(
              json['sections'] as Map<String, dynamic>,
              (value) => SectionResponseDto.fromJson(value as Map<String, dynamic>),
            ),
      );

  final dynamic id;
  final dynamic subjectId;
  final dynamic instructorId;
  final String title;
  final String description;
  final String imageUrl;
  final int price;
  final String level;
  final bool isEnrolled;
  final bool isOwner;
  final String instructorName;
  final String instructorBio;
  final String instructorImageUrl;
  final double instructorAverageRating;
  final int instructorReviewsCount;
  final int instructorTotalStudents;
  final String subjectName;
  final double averageRating;
  final int reviewsCount;
  final int totalStudents;
  final int totalLessons;
  final DateTime lastUpdated;
  final PaginationDto<SectionResponseDto>? sections;
}

class CourseOverviewDto {
  CourseOverviewDto({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.level,
    required this.instructorName,
    required this.subjectName,
    required this.averageRating,
    required this.reviewsCount,
    required this.isEnrolled,
  });

  factory CourseOverviewDto.fromJson(Map<String, dynamic> json) => CourseOverviewDto(
        id: json['id'],
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        level: json['level'] as String? ?? '',
        instructorName: json['instructorName'] as String? ?? '',
        subjectName: json['subjectName'] as String? ?? '',
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
        reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
        isEnrolled: json['isEnrolled'] as bool? ?? false,
      );

  final dynamic id;
  final String title;
  final String description;
  final String imageUrl;
  final int price;
  final String level;
  final String instructorName;
  final String subjectName;
  final double averageRating;
  final int reviewsCount;
  final bool isEnrolled;
}

class SectionResponseDto {
  SectionResponseDto({
    required this.id,
    required this.title,
    required this.order,
    required this.lessons,
  });

  factory SectionResponseDto.fromJson(Map<String, dynamic> json) => SectionResponseDto(
        id: json['id'],
        title: json['title'] as String? ?? '',
        order: (json['order'] as num?)?.toInt() ?? 0,
        lessons: (json['lessons'] as List<dynamic>? ?? []).map((e) => LessonResponseDto.fromJson(e as Map<String, dynamic>)).toList(),
      );

  final dynamic id;
  final String title;
  final int order;
  final List<LessonResponseDto> lessons;
}

class LessonResponseDto {
  LessonResponseDto({
    required this.id,
    required this.courseId,
    required this.sectionId,
    required this.title,
    required this.content,
    required this.videoUrl,
    required this.hlsVideoUrl,
    required this.fileUrl,
    required this.order,
    required this.isIntroVideo,
    required this.isPreview,
    required this.isLocked,
    required this.videoTranscript,
    required this.videoSummary,
    required this.videoNotes,
    required this.transcriptStatus,
  });

  factory LessonResponseDto.fromJson(Map<String, dynamic> json) => LessonResponseDto(
        id: json['id'],
        courseId: json['courseId'],
        sectionId: json['sectionId'],
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        videoUrl: json['videoUrl'] as String? ?? '',
        hlsVideoUrl: json['hlsVideoUrl'] as String? ?? '',
        fileUrl: json['fileUrl'] as String? ?? '',
        order: (json['order'] as num?)?.toInt() ?? 0,
        isIntroVideo: json['isIntroVideo'] as bool? ?? false,
        isPreview: json['isPreview'] as bool? ?? false,
        isLocked: json['isLocked'] as bool? ?? false,
        videoTranscript: json['videoTranscript'] as String? ?? '',
        videoSummary: json['videoSummary'] as String? ?? '',
        videoNotes: json['videoNotes'] as String? ?? '',
        transcriptStatus: json['transcriptStatus'] as String? ?? '',
      );

  final dynamic id;
  final dynamic courseId;
  final dynamic sectionId;
  final String title;
  final String content;
  final String videoUrl;
  final String hlsVideoUrl;
  final String fileUrl;
  final int order;
  final bool isIntroVideo;
  final bool isPreview;
  final bool isLocked;
  final String videoTranscript;
  final String videoSummary;
  final String videoNotes;
  final String transcriptStatus;
}

class CourseProgressResponseDto {
  CourseProgressResponseDto({
    required this.courseId,
    required this.completedLessonsCount,
    required this.totalLessonsCount,
    required this.progressPercentage,
    required this.completedLessonIds,
  });

  factory CourseProgressResponseDto.fromJson(Map<String, dynamic> json) =>
      CourseProgressResponseDto(
        courseId: json['courseId'],
        completedLessonsCount: (json['completedLessonsCount'] as num?)?.toInt() ?? 0,
        totalLessonsCount: (json['totalLessonsCount'] as num?)?.toInt() ?? 0,
        progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0,
        completedLessonIds: (json['completedLessonIds'] as List<dynamic>? ?? []).map((e) => e as dynamic).toList(),
      );

  final dynamic courseId;
  final int completedLessonsCount;
  final int totalLessonsCount;
  final double progressPercentage;
  final List<dynamic> completedLessonIds;
}

class EnrolledCourseOverviewDto {
  EnrolledCourseOverviewDto({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.instructorName,
    required this.progressPercentage,
    required this.totalLessons,
  });

  factory EnrolledCourseOverviewDto.fromJson(Map<String, dynamic> json) =>
      EnrolledCourseOverviewDto(
        id: json['id'],
        title: json['title'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        instructorName: json['instructorName'] as String? ?? '',
        progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0,
        totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 0,
      );

  final dynamic id;
  final String title;
  final String imageUrl;
  final String instructorName;
  final double progressPercentage;
  final int totalLessons;
}

class CourseQueryFilter {
  const CourseQueryFilter({
    this.search,
    this.level,
    this.subjectId,
    this.sortBy,
    this.isEnrolledOnly,
    this.pageNumber,
    this.pageSize,
  });

  final String? search;
  final String? level;
  final String? subjectId;
  final String? sortBy;
  final bool? isEnrolledOnly;
  final int? pageNumber;
  final int? pageSize;

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (level != null && level!.isNotEmpty) params['level'] = level;
    if (subjectId != null && subjectId!.isNotEmpty) params['subjectId'] = subjectId;
    if (sortBy != null && sortBy!.isNotEmpty) params['sortBy'] = sortBy;
    if (isEnrolledOnly != null) params['isEnrolledOnly'] = isEnrolledOnly;
    if (pageNumber != null) params['pageNumber'] = pageNumber;
    if (pageSize != null) params['pageSize'] = pageSize;
    return params;
  }
}

class Guid {
  const Guid._(this.value);

  factory Guid.parse(String value) => Guid._(value);

  final String value;

  @override
  String toString() => value;
}

