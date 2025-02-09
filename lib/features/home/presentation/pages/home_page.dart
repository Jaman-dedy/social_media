import 'package:flutter/material.dart';
import 'package:social_media/features/home/presentation/components/my_drawer.dart';
import 'package:social_media/features/post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    );
  }
}
