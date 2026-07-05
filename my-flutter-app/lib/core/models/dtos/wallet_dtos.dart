class WalletBalanceResponse {
  WalletBalanceResponse({required this.coins});

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) => WalletBalanceResponse(
        coins: (json['coins'] as num).toInt(),
      );

  final int coins;

  Map<String, dynamic> toJson() => {'coins': coins};
}

class TopUpRequest {
  TopUpRequest({required this.amount});

  factory TopUpRequest.fromJson(Map<String, dynamic> json) => TopUpRequest(amount: (json['amount'] as num).toInt());

  final int amount;

  Map<String, dynamic> toJson() => {'amount': amount};
}

class BuyCourseRequest {
  BuyCourseRequest({required this.courseId});

  factory BuyCourseRequest.fromJson(Map<String, dynamic> json) => BuyCourseRequest(courseId: json['courseId'] as String);

  final String courseId;

  Map<String, dynamic> toJson() => {'courseId': courseId};
}

class BookSessionRequest {
  BookSessionRequest({required this.bookingId});

  factory BookSessionRequest.fromJson(Map<String, dynamic> json) => BookSessionRequest(bookingId: json['bookingId'] as String);

  final String bookingId;

  Map<String, dynamic> toJson() => {'bookingId': bookingId};
}

class StripeCheckoutResponseDto {
  StripeCheckoutResponseDto({required this.checkoutUrl});

  factory StripeCheckoutResponseDto.fromJson(Map<String, dynamic> json) => StripeCheckoutResponseDto(checkoutUrl: json['checkoutUrl'] as String);

  final String checkoutUrl;
}

