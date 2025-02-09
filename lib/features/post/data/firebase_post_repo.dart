import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/post/domain/entities/post.dart';
import 'package:social_media/features/post/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Store the post in a collections called 'posts
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      // get all post from the recents
      final postsSnapshot =
          await postsCollection.orderBy('timestamp', descending: true).get();

      // Convert each firestore document from json -> list of posts

      final List<Post> allPosts = [];
      for (var doc in postsSnapshot.docs) {
        try {
          final post = Post.fromJson(doc.data() as Map<String, dynamic>);
          allPosts.add(post);
        } catch (conversionError) {
          // Continue with next document instead of failing completely
          continue;
        }
      }
      return allPosts;
    } catch (e) {
      print("💥 Error in fetchAllPosts: $e");
      throw Exception('Error fetching posts: $e');
    }
  }

  @override
  Future<List<Post>> fetchPostByUserId(String userId) async {
    try {
      //fetch post snapshot with userId
      final postsSnapshot =
          await postsCollection.where('userId', isEqualTo: userId).get();

      //convert firestore documents from json -> list of posts
      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userPosts;
    } catch (e) {
      throw Exception("Error fetching posts by user: $e");
    }
  }
}
