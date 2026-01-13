import 'package:aceui/aceui.dart';
import 'package:flutter/material.dart';
import 'package:prism/pages/settings/Twitter/twitter_account.dart';

class MainAccounts extends StatelessWidget {
  const MainAccounts({super.key});

  @override
  Widget build(BuildContext context) {
    void twitterPage() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TwitterAccount()),
      );
    }

    return AceSimpleLayout(
      title: 'Account',
      childern: [
        AceListTiles(
          title: "Twitter/X",
          icon: Icons.account_box_outlined,
          onTap: () => twitterPage(),
          isActive: false,
        ),
      ],
    );
  }
}
