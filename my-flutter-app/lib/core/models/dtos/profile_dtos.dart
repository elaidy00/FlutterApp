class UserResponseDto {
  UserResponseDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userName,
    required this.phoneNumber,
    this.address,
    this.gender,
    this.profileImage,
    this.coverImage,
    this.isLockout = false,
    this.isEmailConfirmed = false,
    this.accessFailedCount = 0,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) => UserResponseDto(
        id: json['id'] as String,
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        userName: json['userName'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        address: json['address'] as String?,
        gender: json['gender'] as int?,
        profileImage: json['profileImage'] as String?,
        coverImage: json['coverImage'] as String?,
        isLockout: json['isLockout'] as bool? ?? false,
        isEmailConfirmed: json['isEmailConfirmed'] as bool? ?? false,
        accessFailedCount: (json['accessFailedCount'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String userName;
  final String phoneNumber;
  final String? address;
  final int? gender;
  final String? profileImage;
  final String? coverImage;
  final bool isLockout;
  final bool isEmailConfirmed;
  final int accessFailedCount;
}

class UpdateProfileDto {
  UpdateProfileDto({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.address,
    this.gender,
    this.userName,
  });

  factory UpdateProfileDto.fromJson(Map<String, dynamic> json) => UpdateProfileDto(
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        address: json['address'] as String?,
        gender: json['gender'] as int?,
        userName: json['userName'] as String?,
      );

  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? address;
  final int? gender;
  final String? userName;

  Map<String, dynamic> toJson() => {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (address != null) 'address': address,
        if (gender != null) 'gender': gender,
        if (userName != null) 'userName': userName,
      };
}

class ChangePasswordDto {
  ChangePasswordDto({required this.currentPassword, required this.newPassword, required this.confirmNewPassword});

  factory ChangePasswordDto.fromJson(Map<String, dynamic> json) => ChangePasswordDto(
        currentPassword: json['currentPassword'] as String,
        newPassword: json['newPassword'] as String,
        confirmNewPassword: json['confirmNewPassword'] as String,
      );

  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      };
}

class SetPasswordDto {
  SetPasswordDto({required this.newPassword, required this.confirmNewPassword});

  factory SetPasswordDto.fromJson(Map<String, dynamic> json) => SetPasswordDto(
        newPassword: json['newPassword'] as String,
        confirmNewPassword: json['confirmNewPassword'] as String,
      );

  final String newPassword;
  final String confirmNewPassword;

  Map<String, dynamic> toJson() => {
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      };
}

class Enable2FADto {
  Enable2FADto({required this.enable});

  factory Enable2FADto.fromJson(Map<String, dynamic> json) => Enable2FADto(enable: json['enable'] as bool);

  final bool enable;

  Map<String, dynamic> toJson() => {'enable': enable};
}

