import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:social_media/features/auth/data/firebase_auth_repo.dart";
import "package:social_media/features/auth/presentation/cubits/auth_cubit.dart";
import "package:social_media/features/auth/presentation/cubits/auth_states.dart";
import "package:social_media/features/auth/presentation/pages/auth_page.dart";
import "package:social_media/features/post/presentation/pages/home_page.dart";
import "package:social_media/themes/light_mode.dart";

/*

APP - Root Level

-----------------------------------------------------------------------

Initialize repositories: for the database
   - firebase

Initialize the bloc providers for state management
   
   - auth
   - post
   - profile
   - search
   - theme

Check auth state
   - Unauthenticated goes auth page (login/register)
   - Authenticated goes to home page

*/

class MyApp extends StatelessWidget {
  // Auth repo

  final authRepo = FirebaseAuthRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // provide cubit to our app
    return BlocProvider(
        create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightMode,
          home:
              BlocConsumer<AuthCubit, AuthState>(builder: (context, authState) {
            print(authState);

            // if Unauthenticated -> auth page (login/register)
            if (authState is Unauthenticated) {
              return const AuthPage();
            }

            // if authenticated
            if (authState is Authenticated) {
              return const HomePage();
            }

            // loading ...

            else {
              return Scaffold(
                  body: Center(
                child: CircularProgressIndicator(),
              ));
            }
          },
                  // listen for errors
                  listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          }),
        ));
  }
}
