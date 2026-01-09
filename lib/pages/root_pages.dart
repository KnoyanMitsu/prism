import 'package:aceui/aceui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prism/pages/home_page.dart';
import 'package:prism/pages/settings.dart';


class RootPages extends StatefulWidget {
  const RootPages({super.key});

  @override
  State<RootPages> createState() => _RootPagesState();
}

class _RootPagesState extends State<RootPages> {
  int _currentIndex = 0;

  final List<Widget> _pages = [const HomePage(), const Settings()];

  final List<String> _titles = ["Home", "Settings"];

  @override
  Widget build(BuildContext context) {
    void dialogExit(BuildContext context) {
      AceAlertPopup.show(
        context,
        title: "Exit",
        message: "Are you sure you want to exit?",
        btnText: "Yes, Exit",
        color: Colors.red,
        isCancel: true,
        onPressed: () {
          SystemNavigator.pop();
        },
      );
    }

    return AceScaffoldWithDrawers(
      titlePage: _titles[_currentIndex],
      borderRadius: 24,
      backgroundColor: Theme.of(context).colorScheme.surface,
      bodyColor: Theme.of(context).colorScheme.surfaceContainer,
      title: "Prism",
      listtile: [
        AceListTiles(
          title: "Home",
          icon: Icons.home,
          onTap: () {
            setState(() {
              _currentIndex = 0;
            });
          },
          isActive: _currentIndex == 0 ? true : false,
          aceIcon: true,
        ),
        AceListTiles(
          title: "Settings",
          icon: Icons.settings,
          onTap: () {
            setState(() {
              _currentIndex = 1;
            });
          },
          isActive: _currentIndex == 1 ? true : false,
          aceIcon: true,
        ),
      ],
      bottomListtile: [
        AceListTiles(
          title: "Exit",
          icon: Icons.logout,
          onTap: () {
            dialogExit(context);
          },
          isActive: false,
          aceIcon: true,
        ),
      ],
      body: _pages[_currentIndex],
    );
  }
}
