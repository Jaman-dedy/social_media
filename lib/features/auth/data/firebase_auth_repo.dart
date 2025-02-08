import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/features/auth/domain/entities/app_user.dart';
import 'package:social_media/features/auth/domain/repos/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser> loginWithEmailPassword(String email, String password) async {
    try {
      // Attempt signin
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // Create our user

      AppUser user =
          AppUser(uid: userCredential.user!.uid, email: email, name: '');

      //return user
      return user;
    }
    // catch errors
    catch (e) {
      throw Exception('Login failed, + $e');
    }
  }

  @override
  Future<AppUser> registerWithEmailPassword(
      String name, String email, String password) async {
    try {
      // Attempt signup
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create our user
      AppUser user =
          AppUser(uid: userCredential.user!.uid, email: email, name: name);

      //Save user in the firestore database
      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .set(user.toJson());

      //return user
      return user;
    }
    // catch errors
    catch (e) {
      throw Exception('Login failed, + $e');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    // get current logged in user
    final firebaseUser = firebaseAuth.currentUser;

    // if no user logged in
    if (firebaseUser == null) {
      return null;
    }

    // if user exists
    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!, name: '');
  }
}
