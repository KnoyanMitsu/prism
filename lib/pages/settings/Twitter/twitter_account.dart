import 'package:aceui/aceui.dart';
import 'package:flutter/material.dart';
import 'package:prism/controller/twitter_controller.dart';
import 'package:prism/pages/settings/Twitter/twitter_api.dart';
import 'package:prism/services/API/X/api_storage.dart';
import 'package:prism/widget/card.dart';

class TwitterAccount extends StatefulWidget {
  const TwitterAccount({super.key});

  @override
  State<TwitterAccount> createState() => _TwitterAccountState();
}

class _TwitterAccountState extends State<TwitterAccount> {
  @override
  final TwitterStorage _storage = TwitterStorage();
  final TwitterController _controller = TwitterController();
  String _name = "Guest";
  String _username = "Guest";
  String _avatar = "https://i.imgur.com/tdi3NGa.png";
  String _usage = "";
  String _limit = "";
  String _bio = "";
  int _followers = 0;

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
            _name = "${cache['name']}";
            _username = "${cache['username']}";
            _avatar = "${cache['avatar']}";
            _bio = "${cache['bio']}";
            _followers = cache['followers'];
          });
        }

        _controller.checkUser().then((user) {
          if (user != null && mounted) {
            setState(() {
              // Timpa tampilan lama dengan data terbaru dari internet
              _name = "${user.name}";
              _username = "${user.username}";
              _avatar = "${user.profileImageUrl}";
              _bio = "${user.description}";
              _followers = user.publicMetrics?.followersCount ?? 0;
            });
          }
        });
      } else {
        // Kalau token tidak ada
        if (mounted) {
          setState(() {
            _name = "Guest";
            _username = "Guest";
            _avatar = "https://i.imgur.com/tdi3NGa.png";
            _bio = "";
            _followers = 0;
          });
        }
      }
      {
        _controller.usageMonthly().then((usage) async {
          final cache = await _storage.getUsageMonthly();
          if (cache['used'] != null && cache['limit'] != null) {
            setState(() {
              _usage = "${cache['used']}";
              _limit = "${cache['limit']}";
            });
          }
          if (usage != null && mounted) {
            print(usage['data']);
            setState(() {
              _usage = "${usage['data']['project_usage']}";
              _limit = "${usage['data']['project_cap']}";
            });
            _storage.saveUsageMonthly(
              usage['data']['project_usage'],
              usage['data']['project_cap'],
            );
          }
        });
      }
    });
  }

  double get _progressValue {
    // Ubah string ke double, kalau gagal jadi 0.0
    double used = double.tryParse(_usage) ?? 0.0;
    // Ubah string ke double, kalau gagal atau 0 jadi 1.0 (cegah error bagi 0)
    double cap = double.tryParse(_limit) ?? 1.0;

    if (cap <= 0) return 0.0; // Safety check

    // Hitung persen dan kunci biar gak lebih dari 1.0
    return (used / cap).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    void apiPage() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TwitterApi()),
      );
    }

    void logout() {
      _storage.clearSession();
      setState(() {
        _name = "Guest";
        _username = "Guest";
        _avatar = "https://i.imgur.com/tdi3NGa.png";
        _bio = "";
        _followers = 0;
      });
    }

    return AceSimpleLayout(
      title: 'Twitter Account',
      childern: [
        AceCard(
          child: Row(
            children: [
              CircleAvatar(radius: 25, backgroundImage: NetworkImage(_avatar)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _name == "Guest" && _username == "Guest"
                    ? [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ]
                    : [
                        Text(
                          _name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("@$_username"),
                        Text("$_followers followers"),
                      ],
              ),
            ],
          ),
        ),
        AceCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Monthly Post cap usage"),

              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.grey.withOpacity(
                        0.3,
                      ), // Warna track kosong
                      color: _progressValue > 0.9
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      minHeight: 8, // Sedikit lebih tebal biar kelihatan
                      borderRadius: BorderRadius.circular(4), // Ujung tumpul
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text("$_usage/$_limit"),
                ],
              ),
            ],
          ),
        ),
        AceListTiles(
          title: "API Twitter",
          icon: Icons.api,
          onTap: () => apiPage(),
          isActive: false,
        ),
        AceListTiles(
          title: "Logout",
          icon: Icons.logout,
          onTap: () => logout(),
          isActive: false,
        ),
      ],
    );
  }
}
