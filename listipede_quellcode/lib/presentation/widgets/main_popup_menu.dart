import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class MainPopupMenu extends StatelessWidget {
  const MainPopupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformPopupMenu(
        options: [
          PopupMenuOption(
              label: 'Profil',
              onTap: (PopupMenuOption) {
                Navigator.pushNamed(context, '/profile');
              }),
          PopupMenuOption(
              label: 'Meine Produkte',
              onTap: (PopupMenuOption) {
                Navigator.pushNamed(context, '/my-products');
              }),
          PopupMenuOption(
              label: 'Über Listipede',
              onTap: (PopupMenuOption) {
                Navigator.pushNamed(context, '/about');
              })
        ],
        icon: Icon(
            context.platformIcon(
                material: Icons.more_vert,
                cupertino: CupertinoIcons.ellipsis_vertical),
            size: 24));
  }
}
