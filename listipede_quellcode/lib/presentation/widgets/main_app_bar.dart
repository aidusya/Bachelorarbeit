import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:listipede/domain/entities/product.dart';
import 'package:listipede/presentation/widgets/main_popup_menu.dart';
import 'package:listipede/domain/repositories/shopping_list_repository.dart';
import 'list_creation_popup.dart';

String evidentmediawhite = '''<?xml version="1.0" encoding="utf-8"?>
<!-- Generator: Adobe Illustrator 27.6.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
	 viewBox="0 0 234.3 326.6" enable-background="new 0 0 234.3 326.6" xml:space="preserve">
<g id="Ebene_1">
	<g id="Ebene_2">
	</g>
	<g>
		<g>
			<path fill="#FFFFFF" d="M225.9,97.1l-30.1,30.1L94.1,25.5l21.2-21.2l1.9-1.9c1.9-1.5,4.4-2.4,7.1-2.4c2.6,0,5,0.9,6.9,2.3
				l2.2,2.2L225.9,97.1z"/>
			<path fill="#FFFFFF" d="M156.2,163.6H95.7L24.2,92.3l21.9-21.9c0,0,0,0,0,0l0.8-0.8c0,0,0,0,0,0c2-1.8,4.7-2.9,7.7-2.9
				c2.8,0,5.4,1,7.4,2.8L156.2,163.6z"/>
			<g>
				<path fill="#FFFFFF" d="M133.6,78.6l-0.1,43.8L65.4,54.2L80.6,39c1.9-1.4,4.2-2.2,6.7-2.2c2.5,0,4.8,0.8,6.6,2.2l2.6,2.6
					L133.6,78.6z"/>
			</g>
		</g>
	</g>
</g>
<g id="Layer_3">
	<path fill="#FFFFFF" d="M197.5,271.2H60.6L32.9,155.8L3,126.2C-1,122.3-1,116,2.9,112c3.9-3.9,10.2-4,14.1-0.1l34,33.6l5.1,21.4
		l178.1,0.5L197.5,271.2z M76.4,251.2h107l22.7-63.8L61,187L76.4,251.2z"/>
	<g>
		<circle fill="#FFFFFF" cx="83.8" cy="301" r="15.7"/>
		<path fill="#FFFFFF" d="M83.8,326.6c-14.1,0-25.7-11.5-25.7-25.7s11.5-25.7,25.7-25.7s25.7,11.5,25.7,25.7S98,326.6,83.8,326.6z
			 M83.8,295.3c-3.1,0-5.7,2.5-5.7,5.7s2.5,5.7,5.7,5.7s5.7-2.5,5.7-5.7S86.9,295.3,83.8,295.3z"/>
	</g>
	<g>
		<circle fill="#FFFFFF" cx="176.8" cy="301" r="15.7"/>
		<path fill="#FFFFFF" d="M176.8,326.6c-14.1,0-25.7-11.5-25.7-25.7s11.5-25.7,25.7-25.7s25.7,11.5,25.7,25.7S191,326.6,176.8,326.6
			z M176.8,295.3c-3.1,0-5.7,2.5-5.7,5.7s2.5,5.7,5.7,5.7c3.1,0,5.7-2.5,5.7-5.7S180,295.3,176.8,295.3z"/>
	</g>
</g>
</svg>

                ''';

String evidentmediablue = '''<?xml version="1.0" encoding="utf-8"?>
<!-- Generator: Adobe Illustrator 27.6.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
	 viewBox="0 0 234.3 326.6" enable-background="new 0 0 234.3 326.6" xml:space="preserve">
<g id="Ebene_1">
	<g id="Ebene_2">
	</g>
	<g>
		<g>
			<path fill="#003366" d="M225.9,97.1l-30.1,30.1L94.1,25.5l21.2-21.2l1.9-1.9c1.9-1.5,4.4-2.4,7.1-2.4c2.6,0,5,0.9,6.9,2.3
				l2.2,2.2L225.9,97.1z"/>
			<path fill="#003366" d="M156.2,163.6H95.7L24.2,92.3l21.9-21.9c0,0,0,0,0,0l0.8-0.8c0,0,0,0,0,0c2-1.8,4.7-2.9,7.7-2.9
				c2.8,0,5.4,1,7.4,2.8L156.2,163.6z"/>
			<g>
				<path fill="#003366" d="M133.6,78.6l-0.1,43.8L65.4,54.2L80.6,39c1.9-1.4,4.2-2.2,6.7-2.2c2.5,0,4.8,0.8,6.6,2.2l2.6,2.6
					L133.6,78.6z"/>
			</g>
		</g>
	</g>
</g>
<g id="Layer_3">
	<path fill="#003366" d="M197.5,271.2H60.6L32.9,155.8L3,126.2C-1,122.3-1,116,2.9,112c3.9-3.9,10.2-4,14.1-0.1l34,33.6l5.1,21.4
		l178.1,0.5L197.5,271.2z M76.4,251.2h107l22.7-63.8L61,187L76.4,251.2z"/>
	<g>
		<circle fill="#003366" cx="83.8" cy="301" r="15.7"/>
		<path fill="#003366" d="M83.8,326.6c-14.1,0-25.7-11.5-25.7-25.7s11.5-25.7,25.7-25.7s25.7,11.5,25.7,25.7S98,326.6,83.8,326.6z
			 M83.8,295.3c-3.1,0-5.7,2.5-5.7,5.7s2.5,5.7,5.7,5.7s5.7-2.5,5.7-5.7S86.9,295.3,83.8,295.3z"/>
	</g>
	<g>
		<circle fill="#003366" cx="176.8" cy="301" r="15.7"/>
		<path fill="#003366" d="M176.8,326.6c-14.1,0-25.7-11.5-25.7-25.7s11.5-25.7,25.7-25.7s25.7,11.5,25.7,25.7S191,326.6,176.8,326.6
			z M176.8,295.3c-3.1,0-5.7,2.5-5.7,5.7s2.5,5.7,5.7,5.7c3.1,0,5.7-2.5,5.7-5.7S180,295.3,176.8,295.3z"/>
	</g>
</g>
</svg>

                ''';

class MainAppBar extends StatefulWidget {
  MainAppBar({super.key});

  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return SliverAppBar(
        automaticallyImplyLeading: false,
        pinned: _pinned,
        snap: _snap,
        floating: _floating,
        expandedHeight: MediaQuery.of(context).size.height / 3,
        actions: [MainPopupMenu()],
        flexibleSpace: FlexibleSpaceBar(
          expandedTitleScale: 2.5,
          collapseMode: CollapseMode.pin,
          centerTitle: true,
          title: LayoutBuilder(builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (constraints.maxHeight < kToolbarHeight * 2)
                  Row(
                    children: [
                      SvgPicture.string(
                        evidentmediawhite,
                        allowDrawingOutsideViewBox: true,
                        height: 18,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                Text(
                  'Listipede',
                  style: TextStyle(
                      fontWeight: constraints.maxHeight > kToolbarHeight * 2
                          ? FontWeight.w200
                          : FontWeight.normal),
                ),
                if (constraints.maxHeight < kToolbarHeight * 2)
                  SizedBox(
                    width: 10,
                  ),
              ],
            );
          }),
          background: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.string(
                evidentmediawhite,
                allowDrawingOutsideViewBox: true,
                height: MediaQuery.of(context).size.width / 3,
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      );
    } else {
      return CupertinoSliverNavigationBar(
        automaticallyImplyLeading: false,
        largeTitle: Row(
          children: [
            SvgPicture.string(
              evidentmediablue,
              allowDrawingOutsideViewBox: true,
              height: 35,
            ),
            Text(' Listipede')
          ],
        ),
        middle: Text('Listipede'),
        alwaysShowMiddle: false,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlatformIconButton(
              cupertino: (_, __) => CupertinoIconButtonData(
                padding: EdgeInsets.zero,
                icon: Icon(CupertinoIcons.add),
                onPressed: () {
                  showPlatformDialog(
                    context: context,
                    builder: (context) => ListCreationDialog(),
                  );
                },
              ),
            ),
            MainPopupMenu(),
          ],
        ),
        backgroundColor: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey)),
      );
    }
  }
}
