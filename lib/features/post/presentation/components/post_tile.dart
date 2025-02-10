import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/domain/entities/app_user.dart';
import 'package:social_media/features/auth/presentation/components/my_text_field.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/post/domain/entities/comment.dart';
import 'package:social_media/features/post/domain/entities/post.dart';
import 'package:social_media/features/post/presentation/components/comment_tile.dart';
import 'package:social_media/features/post/presentation/cubits/post.cubit.dart';
import 'package:social_media/features/post/presentation/cubits/post_states.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media/features/profile/presentation/pages/profile_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile(
      {super.key, required this.post, required this.onDeletePressed});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  //cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  //current user
  AppUser? currentUser;

  // post user
  ProfileUser? postUser;

  //on Startup,
  @override
  void initState() {
    super.initState();

    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  /*
   LIKES
  */

  // user tapped like button
  void toggleLikePost() {
    // current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    // optimistically (locally) like
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid); //unlike locally
      } else {
        widget.post.likes.add(currentUser!.uid); // like
      }
    });

    //update like
    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      //if there's an error, revert back to original
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid); //revert unlike
        } else {
          widget.post.likes.remove(currentUser!.uid); // revert like
        }
      });
    });
  }

  //Show options for deletion
  void showOptions() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete Post?'),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel')),

                // delete button
                TextButton(
                    onPressed: () {
                      widget.onDeletePressed!();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete'))
              ],
            ));
  }

/*
COMMENTS
*/
  // comment text controller
  final commentTextController = TextEditingController();

  //open comment box when user wants to type a new comment
  void openNewCommentBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: MyTextField(
                  controller: commentTextController,
                  hintText: "Type a comment",
                  obscureText: false),
              actions: [
                //cancel button'
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),

                //save button
                TextButton(
                  onPressed: () {
                    addComment();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            ));
  }

  //add comment method
  void addComment() {
    //create a new comment
    final newComment = Comment(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        postId: widget.post.id,
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: commentTextController.text,
        timestamp: DateTime.now());

    //add comment using cubit
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  //Build ui
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: profile pic/name/delete button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(uid: widget.post.userId),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Profile picture
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: postUser?.profileImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: postUser!.profileImageUrl,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                ),
                                child: Icon(Icons.person,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            )
                          : Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                              ),
                              child: Icon(Icons.person,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Username and timestamp
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimestamp(widget.post.timestamp),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Delete button
                  if (isOwnPost)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: showOptions,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Post Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.zero,
              bottom: Radius.circular(2),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.post.imageUrl,
              height: 430,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 430,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 430,
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            ),
          ),

          // Interaction buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                // Like button and count
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: toggleLikePost,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            widget.post.likes.contains(currentUser!.uid)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.post.likes.contains(currentUser!.uid)
                                ? Colors.red
                                : Colors.grey[600],
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      widget.post.likes.length.toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Comment button and count
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: openNewCommentBox,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.grey[600],
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      widget.post.comments.length.toString(),
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Caption
          if (widget.post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.post.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: widget.post.text,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Comments section
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              if (state is PostsLoaded) {
                final post = state.posts
                    .firstWhere((post) => (post.id == widget.post.id));
                if (post.comments.isNotEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: post.comments.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final comment = post.comments[index];
                        return CommentTile(comment: comment);
                      },
                    ),
                  );
                }
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

// Helper method to format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
