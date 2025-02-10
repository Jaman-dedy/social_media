import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/domain/entities/app_user.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/post/presentation/components/post_tile.dart';
import 'package:social_media/features/post/presentation/cubits/post.cubit.dart';
import 'package:social_media/features/post/presentation/cubits/post_states.dart';
import 'package:social_media/features/profile/presentation/components/bio_box.dart';
import 'package:social_media/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_media/features/profile/presentation/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  // current user
  late AppUser? currentUser = authCubit.currentUser;

  //posts
  int postCount = 0;

  // on startup
  @override
  void initState() {
    super.initState();

    //load user profile data
    profileCubit.fetchUserProfile(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
      // loaded
      if (state is ProfileLoaded) {
        // get loaded user
        final user = state.profileUser;

        return Scaffold(
            appBar: AppBar(
              title: Text(user.name),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                // Edit profile
                IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(user: user),
                        )),
                    icon: const Icon(Icons.settings))
              ],
            ),

            //Body
            body: ListView(
              children: [
                //email
                Center(
                  child: Text(
                    user.email,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),

                const SizedBox(height: 25),

                // Profile picture
                Container(
                  width: 120, // Smaller size
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  clipBehavior: Clip
                      .hardEdge, // This ensures the image stays within the circle
                  child: Image.network(
                    user.profileImageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: 30, // Smaller loading indicator
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, // Thinner loading indicator
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,
                      size: 48, // Smaller icon size
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Bio box
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      Text(
                        'Bio',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                BioBox(text: user.bio),

                // Post

                Padding(
                  padding: const EdgeInsets.only(left: 25.0, top: 25),
                  child: Row(
                    children: [
                      Text(
                        'Posts',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                // list of uses posts
                BlocBuilder<PostCubit, PostState>(builder: (context, state) {
                  //posts loaded..
                  if (state is PostsLoaded) {
                    //filter posts by user id
                    final userPosts = state.posts
                        .where((post) => post.userId == widget.uid)
                        .toList();
                    postCount = userPosts.length;

                    return ListView.builder(
                      itemCount: postCount,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        //get individual post
                        final post = userPosts[index];

                        //return as post tile UI
                        return PostTile(
                            post: post,
                            onDeletePressed: () =>
                                context.read<PostCubit>().deletePost(post.id));
                      },
                    );
                  }

                  // posts loading
                  else if (state is PostsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return const Center(
                      child: Text('No posts yet..'),
                    );
                  }
                })
              ],
            ));
      }

      // loading
      else if (state is ProfileLoading) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        return const Center(
          child: Text("No profile found.."),
        );
      }
    });
  }
}
