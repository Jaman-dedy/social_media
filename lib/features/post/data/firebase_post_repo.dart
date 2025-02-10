import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/post/domain/entities/comment.dart';
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
        } catch (e) {
          continue;
        }
      }
      return allPosts;
    } catch (e) {
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

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      //get the post document from firestore
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        //check if user has already liked this post
        final hasLiked = post.likes.contains(userId);

        //update the likes list
        if (hasLiked) {
          post.likes.remove(userId); //unlike
        } else {
          post.likes.add(userId); // like
        }

        // update the post document with the new like list
        await postsCollection.doc(postId).update({
          'likes': post.likes,
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error toggling like: $e');
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      //get post document
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        //convert json object to post
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment
        post.comments.add(comment);

        //update the post document in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception("Error adding comment: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      //get post document
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        //convert json object to post
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // remove a comment
        post.comments.removeWhere((comment) => comment.id == commentId);

        //update the post document in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception("Error deleting a comment: $e");
    }
  }
}
