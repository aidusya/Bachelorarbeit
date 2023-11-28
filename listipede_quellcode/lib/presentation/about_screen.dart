import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AboutScreen extends StatelessWidget {
  AboutScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text("Impressum"),
          material: (_, __) => MaterialAppBarData(
            centerTitle: true,
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
            previousPageTitle: 'Listen',
          ),
        ),
        body: Placeholder());
  }
}
