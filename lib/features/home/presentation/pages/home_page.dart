import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  late final postCubit = context.read<PostCubit>();
  bool _isOnline = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    fetchAllPosts();
  }

  Future<void> checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });

    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
      if (_isOnline) {
        syncData(); // Sync when connection is restored
      }
    });
  }

  Future<void> syncData() async {
    setState(() {
      _isSyncing = true;
    });

    // Simulate sync delay
    await Future.delayed(const Duration(seconds: 2));
    fetchAllPosts(); // Remove await since it's void

    setState(() {
      _isSyncing = false;
    });
  }

  void fetchAllPosts() {
    postCubit.fetchAllPost();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Light blue-tinted background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "FlutterPost", // Changed from "Home" to match app name
          style: TextStyle(
            color: const Color(0xFF1E3A8A), // Deep rich blue
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // Sync status indicator
          if (_isSyncing)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF4776E6), // Light blue
                    ),
                  ),
                ),
              ),
            ),
          // Sync button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _isOnline ? const Color(0xFFEEF2FF) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _isOnline ? syncData : null,
              icon: Icon(
                _isOnline ? Icons.sync : Icons.sync_disabled,
                color: _isOnline ? const Color(0xFF4776E6) : Colors.grey,
                size: 22,
              ),
            ),
          ),
          // Upload new post
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4776E6), // Light blue
                  Color(0xFF2F56E8), // Deeper blue
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadPostPage()),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          // Offline indicator with improved styling
          if (!_isOnline)
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF9966), // Warm orange
                    Color(0xFFFF5E62), // Coral
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.wifi_off,
                        size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'You\'re offline. Changes will sync when online.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: BlocBuilder<PostCubit, PostState>(
              builder: (context, state) {
                if (state is PostsLoading || state is PostsUploading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF4776E6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Loading posts...",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is PostsLoaded) {
                  final allPosts = state.posts;

                  if (allPosts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.post_add_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No posts yet",
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Be the first to share something!",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await syncData();
                    },
                    color: const Color(0xFF4776E6),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: allPosts.length,
                      itemBuilder: (context, index) {
                        final post = allPosts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: PostTile(
                            post: post,
                            onDeletePressed: () => deletePost(post.id),
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is PostsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: syncData,
                          child: const Text("Try Again"),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
