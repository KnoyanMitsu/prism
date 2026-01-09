import 'package:aceui/aceui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/icons/logo.svg', width: 200, height: 200),
          const SizedBox(height: 20),
          const Text(
            "Welcome to Prism",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            "This app about to post your photo or caption to Facebook and Twitter (API access)",
          ),
          const Text(
            "Please login to your Facebook and Twitter account on settings in sidebar ",
          ),
          const SizedBox(height: 20),
          AceButton(
            color: Theme.of(context).colorScheme.primary,
            label: "Post it",
            onPressed: () {},
            colorText: Colors.white,
          ),
        ],
      ),
    );
  }
}
