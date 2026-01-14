import 'package:aceui/aceui.dart';
import 'package:flutter/material.dart';
import 'package:prism/controller/bluesky_controller.dart';

class BlueskyLogin extends StatefulWidget {
  const BlueskyLogin({super.key});

  @override
  State<BlueskyLogin> createState() => _BlueskyLoginState();
}

class _BlueskyLoginState extends State<BlueskyLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  String _status = "";

  @override
  void initState() {
    super.initState();
    BlueskyController controller = BlueskyController();
    controller.init().then((isLogin) async {
      if (isLogin) {
        setState(() {
          _status = "Already logged in";
        });
      } else {
        setState(() {
          _status = "Not logged in";
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void login() async {
    BlueskyController controller = BlueskyController();
    if (_urlController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      String result = await controller.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        _urlController.text.trim(),
      );
      if (result == "Success") {
        setState(() {
          _isLoading = false;
          _status = result;
        });
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
          _status = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AceSimpleLayout(
      childern: [
        AceTextFieldWithLabel(
          label: "Services URL",
          type: TypeField.text,
          controller: _urlController,
          required: true,
        ),
        const SizedBox(height: 16),
        AceTextFieldWithLabel(
          label: "Username",
          type: TypeField.text,
          controller: _usernameController,
          required: true,
        ),
        const SizedBox(height: 16),
        AceTextFieldWithLabel(
          label: "App Password",
          type: TypeField.password,
          controller: _passwordController,
          required: true,
        ),
        const SizedBox(height: 16),
        Text(_status),
        const Spacer(),
        AceButton(
          color: Theme.of(context).colorScheme.primary,
          colorText: Theme.of(context).colorScheme.onPrimary,
          label: "Login",
          isLoading: _isLoading,
          onPressed: () {
            login();
          },
        ),
      ],
      title: "Bluesky Login",
    );
  }
}
