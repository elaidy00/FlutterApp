import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dtos/profile_dtos.dart';
import '../services/api_client.dart';

class ProfileState {
  const ProfileState({this.profile, this.isLoading = false, this.errorMessage});

  final UserResponseDto? profile;
  final bool isLoading;
  final String? errorMessage;

  ProfileState copyWith({UserResponseDto? profile, bool? isLoading, String? errorMessage}) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  final ApiClient _apiClient = ApiClient();

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _apiClient.dio.get('/profiles/profile');
      final data = response.data['data'];
      state = state.copyWith(profile: UserResponseDto.fromJson(data as Map<String, dynamic>), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _apiClient.getErrorMessage(e));
      rethrow;
    }
  }

  Future<bool> updateProfile(UpdateProfileDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _apiClient.dio.patch('/profiles/profile', data: dto.toJson());
      state = state.copyWith(isLoading: false);
      return response.statusCode == 200;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _apiClient.getErrorMessage(e));
      rethrow;
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) => ProfileNotifier());
