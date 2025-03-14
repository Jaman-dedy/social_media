import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/domain/repos/profile_repo.dart';
import 'package:social_media/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_media/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.profileRepo, required this.storageRepo})
      : super(ProfileInitial());

  //fetch user profile using the repo
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError('User profile not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  //fetch user profile with a given user id -> useful for loading many profiles for posts
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  // update bio and or profile picture
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());

    try {
      // Fetch current user profile first
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError("Failed to fetch user profile for update"));
        return;
      }

      //Profile picture update
      String? imageDownloadUrl;

      //Make sure we have the image
      if (imageWebBytes != null || imageMobilePath != null) {
        //mobile
        if (imageMobilePath != null) {
          //upload
          imageDownloadUrl =
              await storageRepo.uploadProfileImageMobile(imageMobilePath, uid);
        }
        //web
        else if (imageWebBytes != null) {
          //upload
          imageDownloadUrl =
              await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
        }

        if (imageDownloadUrl == null) {
          emit(ProfileError('Failed to upload image'));
          return;
        }
      }

      // update new profile
      final updateProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );

      // update in repo

      await profileRepo.updateProfile(updateProfile);

      //Re-fetch the updated profile
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError('Error updating profile: $e'));
    }
  }
}
