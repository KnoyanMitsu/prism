import 'package:aceui/aceui.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return AceFormLayoutWithoutScarf(
      title: "Settings",
      subtitle: "Settings for Prism",
      titleColor: Theme.of(context).colorScheme.primary,
      children: [
        AceListTiles(
          title: 'Account',
          icon: Icons.account_circle,
          onTap: () {},
          isActive: false,
          aceIcon: false,
        ),
        AceListTiles(
          title: 'About',
          icon: Icons.info,
          onTap: () {},
          isActive: false,
          aceIcon: false,
        ),
      ],
    );
  }
}
