import 'package:aceui/aceui.dart';
import 'package:flutter/material.dart';
import 'package:prism/controller/twitter_controller.dart';
import 'package:prism/pages/settings/Twitter/twitter_api_notice.dart';
import 'package:prism/services/API/X/api_storage.dart';

class TwitterApi extends StatefulWidget {
  const TwitterApi({super.key});

  @override
  State<TwitterApi> createState() => _TwitterApiState();
}

class _TwitterApiState extends State<TwitterApi> {
  final TwitterStorage _storage = TwitterStorage();
  // 1. INSTANCE CONTROLLER
  final TwitterController _controller = TwitterController();

  // Controller untuk Input Text
  final _apiKeyCtrl = TextEditingController();
  final _apiSecretCtrl = TextEditingController();
  final _BearerTokenCtrl = TextEditingController();

  String _status = "Ready";
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi Controller
    _controller.init().then((isLoginSuccess) async {
      // Tambahkan 'async' di sini
      if (isLoginSuccess) {
        // --- STEP A: LOAD CACHE (Tampilkan Instan) ---
        // Kita butuh instansi storage di sini atau buat fungsi getter di controller
        // Anggap Anda punya _storage instance di halaman ini:
        final cache = await _storage
            .getCachedUserData(); // PENTING: Pakai 'await'

        if (mounted && cache['name'] != null) {
          setState(() {
            _status = "Hello, ${cache['name']}!";
            _isLoggedIn = true;
          });
        }

        _controller.checkUser().then((user) {
          if (user != null && mounted) {
            setState(() {
              // Timpa tampilan lama dengan data terbaru dari internet
              _status = "Hello, ${user.name}!";
              _isLoggedIn = true;
            });
          }
        });
      } else {
        // Kalau token tidak ada
        if (mounted) {
          setState(() {
            _status = "Silakan Login Terlebih Dahulu";
            _apiKeyCtrl.text = "";
            _apiSecretCtrl.text = "";
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller; // Bersihkan memori
    _apiKeyCtrl.dispose();
    _apiSecretCtrl.dispose();
    _BearerTokenCtrl.dispose();
    super.dispose();
  }

  // --- Fungsi Bantuan untuk UI ---
  void _handleLogin() async {
    if (_apiKeyCtrl.text.isEmpty || _apiSecretCtrl.text.isEmpty) {
      setState(() => _status = "API Key & Secret wajib diisi!");
      return;
    }

    setState(() => _status = "Membuka Browser untuk Login...");

    // 3. PANGGIL FUNGSI LOGIN
    String result = await _controller.login(
      _apiKeyCtrl.text.trim(),
      _apiSecretCtrl.text.trim(),
      _BearerTokenCtrl.text.trim(),
    );

    setState(() {
      _status = result;
      // if (result == "Success") {
      //   _isLoggedIn = true;
      //   _status = "Success";
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AceSimpleLayout(
      title: 'API Twitter',
      childern: [
        SingleChildScrollView(
          child: Column(
            children: [
              TwitterApiNotice(),
              SizedBox(height: 30),

              AceTextFieldWithLabel(
                label: 'API Keys',
                type: TypeField.password,
                required: true,
                border: true,
                controller: _apiKeyCtrl,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
              SizedBox(height: 8),
              AceTextFieldWithLabel(
                label: 'API Keys Secret',
                type: TypeField.password,
                required: true,
                controller: _apiSecretCtrl,
                border: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
              SizedBox(height: 8),
              AceTextFieldWithLabel(
                label: 'Bearer Token',
                type: TypeField.password,
                required: true,
                border: true,
                controller: _BearerTokenCtrl,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
              SizedBox(height: 8),
              // AceTextFieldWithLabel(
              //   label: "Bearer Token",
              //   type: TypeField.password,
              //   required: true,
              //   border: true,
              //   fillColor: Theme.of(context).colorScheme.surfaceContainer,
              // ),
              AceButton(
                color: Theme.of(context).colorScheme.primary,
                label: "Login",
                onPressed: _handleLogin,
                colorText: Theme.of(context).colorScheme.onPrimary,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text(_status),
      ],
    );
  }
}
