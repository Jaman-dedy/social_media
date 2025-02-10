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
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );

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
        print("post state : $state");
        // loading or uploading

        if (state is PostsLoading || state is PostsUploading) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFF),
            body: Center(
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
                    state is PostsUploading
                        ? "Uploading post..."
                        : "Loading...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
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
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Create Post",
          style: TextStyle(
            color: const Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Upload button with gradient
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4776E6),
                  Color(0xFF2F56E8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4776E6).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: uploadPost,
              icon: const Icon(Icons.upload, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Container
              Container(
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4776E6).withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: imagePickedFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Add a photo to share",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: kIsWeb
                            ? Image.memory(
                                webImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Image.file(
                                File(imagePickedFile!.path!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                      ),
              ),

              const SizedBox(height: 20),

              // Pick image button
              ElevatedButton.icon(
                onPressed: pickImage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4776E6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: const Color(0xFF4776E6).withOpacity(0.5),
                    ),
                  ),
                ),
                icon: const Icon(Icons.photo_library),
                label: Text(
                  imagePickedFile == null ? 'Choose Photo' : 'Change Photo',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 24),

              // Caption section
              Container(
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        "Caption",
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextField(
                      controller: textController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write a caption...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Upload button for mobile view
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4776E6),
                      Color(0xFF2F56E8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4776E6).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: uploadPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.upload),
                  label: const Text(
                    'Share Post',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
