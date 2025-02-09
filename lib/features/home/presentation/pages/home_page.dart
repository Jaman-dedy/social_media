import 'package:flutter/material.dart';
import 'package:social_media/features/home/presentation/components/my_drawer.dart';

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
      ),

      // Drawer
      drawer: const MyDrawer(),
    );
  }
}
