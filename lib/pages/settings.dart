import 'package:aceui/aceui.dart';
import 'package:flutter/material.dart';
import 'package:prism/pages/settings/main_accounts.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  void account() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainAccounts()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AceSimpleLayoutWithoutScarf(
      title: "Settings",
      childern: [
        AceListTiles(
          title: 'Account',
          icon: Icons.account_circle,
          onTap: () {
            account();
          },
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
