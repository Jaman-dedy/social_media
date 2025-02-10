import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/home/presentation/components/my_drawer_tile.dart';
import 'package:social_media/features/profile/presentation/pages/profile_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header section with gradient
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  // Profile icon in white circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 44,
                            // color: const Color(0xFF4776E6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Menu Items
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Home tile
                    _buildDrawerTile(
                      context: context,
                      title: "Home",
                      icon: Icons.home_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),

                    // Profile tile
                    _buildDrawerTile(
                      context: context,
                      title: "Profile",
                      icon: Icons.person_rounded,
                      onTap: () {
                        Navigator.of(context).pop();
                        final user = context.read<AuthCubit>().currentUser;
                        String? uid = user!.uid;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(uid: uid),
                          ),
                        );
                      },
                    ),

                    // Search tile
                    _buildDrawerTile(
                      context: context,
                      title: "Search",
                      icon: Icons.search_rounded,
                      onTap: () {},
                    ),

                    // Settings tile
                    _buildDrawerTile(
                      context: context,
                      title: "Settings",
                      icon: Icons.settings_rounded,
                      onTap: () {},
                    ),

                    const Spacer(),

                    // Divider before logout
                    Divider(color: Colors.grey[200]),

                    // Logout tile
                    _buildDrawerTile(
                      context: context,
                      title: "Logout",
                      icon: Icons.logout_rounded,
                      isLogout: true,
                      onTap: () => context.read<AuthCubit>().logout(),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLogout
                  ? Colors.red[50]
                  : const Color(0xFF4776E6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isLogout ? Colors.red[700] : const Color(0xFF4776E6),
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isLogout ? Colors.red[700] : const Color(0xFF2D3748),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: isLogout ? Colors.red[700] : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
