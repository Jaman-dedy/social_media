import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/home/presentation/components/my_drawer.dart';
import 'package:social_media/features/post/presentation/components/post_tile.dart';
import 'package:social_media/features/post/presentation/cubits/post.cubit.dart';
import 'package:social_media/features/post/presentation/cubits/post_states.dart';
import 'package:social_media/features/post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // post cubit (state)
  late final postCubit = context.read<PostCubit>();

  //on startup
  @override
  void initState() {
    super.initState();

    //fetch all posts
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPost();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  //Home page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar
      appBar: AppBar(
        title: const Text("Home"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // upload new post
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadPostPage(),
                  )),
              icon: const Icon(Icons.add))
        ],
      ),

      // Drawer
      drawer: const MyDrawer(),

      // BODY
      body: BlocBuilder<PostCubit, PostState>(builder: (context, state) {
        print("Current state: ${state.runtimeType}"); // Debug print
        //loading
        if (state is PostsLoading || state is PostsUploading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        //loaded
        else if (state is PostsLoaded) {
          final allPosts = state.posts;
          print(allPosts);
          print("Number of posts: ${allPosts.length}"); // Debug print

          if (allPosts.isEmpty) {
            return const Center(
              child: Text(" No post available at the moment"),
            );
          }

          return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                // get individual post
                final post = allPosts[index];

                //Display post image
                return PostTile(
                    post: post, onDeletePressed: () => deletePost(post.id));
              });
        }
        //error
        else if (state is PostsError) {
          return Center(
            child: Text(state.message),
          );
        } else {
          return const SizedBox();
        }
      }),
    );
  }
}
