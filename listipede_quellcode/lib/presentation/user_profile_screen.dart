import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class UserProfileScreen extends StatelessWidget {
  final List<AuthProvider> providers;
  UserProfileScreen({required this.providers});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text("Profil"),
          material: (_, __) => MaterialAppBarData(
            centerTitle: true,
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
            previousPageTitle: 'Listen',
          ),
        ),
        body: ProfileScreen(
          //ProfileScreen = Firebase Auth, UserProfileScreen = custom
          providers: providers,
          actions: [
            SignedOutAction((context) {
              Navigator.pushReplacementNamed(context, '/sign-in');
            }),
          ],
        ));
  }
}
