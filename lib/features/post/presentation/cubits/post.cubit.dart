import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/post/domain/entities/post.dart';
import 'package:social_media/features/post/domain/repos/post_repo.dart';
import 'package:social_media/features/post/presentation/cubits/post_states.dart';
import 'package:social_media/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitial());

  // create a new post
  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;

    try {
      // handle image upload for mobile
      if (imagePath != null) {
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      }

      // Handle image upload for web
      else if (imageBytes != null) {
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      // bind the image to the post
      final newPost = post.copyWith(imageUrl: imageUrl);

      //Save the post to the backend
      postRepo.createPost(newPost);

      // re-fetch all posts
      fetchAllPost();
    } catch (e) {
      emit(PostsError('Failed to create post: $e'));
    }
  }

  // Fetch all posts
  Future<void> fetchAllPost() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to fetch posts: $e"));
    }
  }

  // Delete post

  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {
      throw Exception('Fail to delete $e');
    }
  }
}
