import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/domain/entities/app_user.dart';
import 'package:social_media/features/auth/presentation/components/my_text_field.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/post/domain/entities/post.dart';
import 'package:social_media/features/post/presentation/cubits/post.cubit.dart';
import 'package:social_media/features/post/presentation/cubits/post_states.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  // mobile image pick
  PlatformFile? imagePickedFile;

  // We image pick
  Uint8List? webImage;

  //Text controller for caption
  final textController = TextEditingController();

  // Get current user
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  // Get current user method
  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  // pick image
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  // Create & upload post
  void uploadPost() {
    // validate image and caption
    if (imagePickedFile == null || textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image and caption are required")));
      return;
    }

    // create a new post object
    final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: textController.text,
        imageUrl: '',
        timestamp: DateTime.now());

    // post cubit
    final postCubit = context.read<PostCubit>();

    // web upload
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickedFile?.bytes);
    }

    //mobile
    else {
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }
  }

  //dispose text controller

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        print("post state : ${state}");
        // loading or uploading

        if (state is PostsLoading || state is PostsUploading) {
          return const Scaffold(
              body: Center(
            child: CircularProgressIndicator(),
          ));
        }

        //Build upload page
        return buildUploadpage();
      },
      // Go to previous page when upload is done & posts are loaded
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildUploadpage() {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Create Post"),
          foregroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            // upload button
            IconButton(onPressed: uploadPost, icon: const Icon(Icons.upload))
          ],
        ),

        //Body
        body: Center(
          child: Column(
            children: [
              // image preview for web
              if (kIsWeb && webImage != null) Image.memory(webImage!),

              // image preview for mobile
              if (!kIsWeb && imagePickedFile != null)
                Image.file(File(imagePickedFile!.path!)),

              // Pick image button
              MaterialButton(
                onPressed: pickImage,
                color: Colors.blue,
                child: const Text('Pick image'),
              ),

              // Caption text box
              MyTextField(
                  controller: textController,
                  hintText: 'Caption',
                  obscureText: false)
            ],
          ),
        ));
  }
}
