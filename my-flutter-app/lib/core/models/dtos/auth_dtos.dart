class LoginDto {
  LoginDto({required this.emailOrUserName, required this.password});

  factory LoginDto.fromJson(Map<String, dynamic> json) => LoginDto(
        emailOrUserName: json['emailOrUserName'] as String,
        password: json['password'] as String,
      );

  final String emailOrUserName;
  final String password;

  Map<String, dynamic> toJson() => {
        'emailOrUserName': emailOrUserName,
        'password': password,
      };
}

class RegisterDto {
  RegisterDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userName,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.roleName,
    this.gender,
  });

  factory RegisterDto.fromJson(Map<String, dynamic> json) => RegisterDto(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        userName: json['userName'] as String,
        phoneNumber: json['phoneNumber'] as String,
        password: json['password'] as String,
        confirmPassword: json['confirmPassword'] as String,
        roleName: json['roleName'],
        gender: json['gender'] as int?,
      );

  final String firstName;
  final String lastName;
  final String email;
  final String userName;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final dynamic roleName;
  final int? gender;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'userName': userName,
        'phoneNumber': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
        'roleName': roleName,
        'gender': gender,
      };
}

class GoogleLoginDto {
  GoogleLoginDto({required this.idToken});

  factory GoogleLoginDto.fromJson(Map<String, dynamic> json) => GoogleLoginDto(
        idToken: json['idToken'] as String,
      );

  final String idToken;

  Map<String, dynamic> toJson() => {'idToken': idToken};
}

class EmailVerificationDto {
  EmailVerificationDto({required this.email, required this.token});

  factory EmailVerificationDto.fromJson(Map<String, dynamic> json) =>
      EmailVerificationDto(
        email: json['email'] as String,
        token: json['token'] as String,
      );

  final String email;
  final String token;

  Map<String, dynamic> toJson() => {'email': email, 'token': token};
}

class ResendVerificationDto {
  ResendVerificationDto({required this.email});

  factory ResendVerificationDto.fromJson(Map<String, dynamic> json) =>
      ResendVerificationDto(email: json['email'] as String);

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}

class ForgetPasswordDto {
  ForgetPasswordDto({required this.email});

  factory ForgetPasswordDto.fromJson(Map<String, dynamic> json) =>
      ForgetPasswordDto(email: json['email'] as String);

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordDto {
  ResetPasswordDto({
    required this.email,
    required this.token,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  factory ResetPasswordDto.fromJson(Map<String, dynamic> json) =>
      ResetPasswordDto(
        email: json['email'] as String,
        token: json['token'] as String,
        newPassword: json['newPassword'] as String,
        confirmNewPassword: json['confirmNewPassword'] as String,
      );

  final String email;
  final String token;
  final String newPassword;
  final String confirmNewPassword;

  Map<String, dynamic> toJson() => {
        'email': email,
        'token': token,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      };
}

class Verify2FADto {
  Verify2FADto({required this.email, required this.code});

  factory Verify2FADto.fromJson(Map<String, dynamic> json) => Verify2FADto(
        email: json['email'] as String?,
        code: json['code'] as String,
      );

  final String? email;
  final String code;

  Map<String, dynamic> toJson() => {'email': email, 'code': code};
}

class AuthResponseDto {
  AuthResponseDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userName,
    required this.phoneNumber,
    this.address,
    required this.gender,
    this.profileImage,
    this.coverImage,
    required this.isLockout,
    required this.isEmailConfirmed,
    required this.accessFailedCount,
    required this.roles,
    required this.token,
    required this.refreshTokenExpiration,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) => AuthResponseDto(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        userName: json['userName'] as String,
        phoneNumber: json['phoneNumber'] as String,
        address: json['address'] as String?,
        gender: (json['gender'] as num).toInt(),
        profileImage: json['profileImage'] as String?,
        coverImage: json['coverImage'] as String?,
        isLockout: json['isLockout'] as bool,
        isEmailConfirmed: json['isEmailConfirmed'] as bool,
        accessFailedCount: (json['accessFailedCount'] as num).toInt(),
        roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
        token: json['token'] as String,
        refreshTokenExpiration: DateTime.parse(json['refreshTokenExpiration'] as String),
      );

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String userName;
  final String phoneNumber;
  final String? address;
  final int gender;
  final String? profileImage;
  final String? coverImage;
  final bool isLockout;
  final bool isEmailConfirmed;
  final int accessFailedCount;
  final List<String> roles;
  final String token;
  final DateTime refreshTokenExpiration;

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'userName': userName,
        'phoneNumber': phoneNumber,
        'address': address,
        'gender': gender,
        'profileImage': profileImage,
        'coverImage': coverImage,
        'isLockout': isLockout,
        'isEmailConfirmed': isEmailConfirmed,
        'accessFailedCount': accessFailedCount,
        'roles': roles,
        'token': token,
        'refreshTokenExpiration': refreshTokenExpiration.toIso8601String(),
      };
}

class LoginResponseDto {
  LoginResponseDto({required this.requiresTwoFactor, this.authData});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      LoginResponseDto(
        requiresTwoFactor: json['requiresTwoFactor'] as bool,
        authData: json['authData'] == null
            ? null
            : AuthResponseDto.fromJson(json['authData'] as Map<String, dynamic>),
      );

  final bool requiresTwoFactor;
  final AuthResponseDto? authData;

  Map<String, dynamic> toJson() => {
        'requiresTwoFactor': requiresTwoFactor,
        'authData': authData?.toJson(),
      };
}

class ApiResponse<T> {
  ApiResponse({
    required this.statusCode,
    this.message,
    this.data,
    required this.isSuccess,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      ApiResponse<T>(
        statusCode: (json['statusCode'] as num).toInt(),
        message: json['message'] as String?,
        data: json['data'] == null ? null : fromJsonT(json['data']),
        isSuccess: json['isSuccess'] as bool,
      );

  final int statusCode;
  final String? message;
  final T? data;
  final bool isSuccess;
}

