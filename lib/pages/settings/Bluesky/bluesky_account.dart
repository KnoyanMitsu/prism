import 'package:aceui/aceui.dart';
import 'package:flutter/material.dart';
import 'package:prism/controller/bluesky_controller.dart';
import 'package:prism/pages/settings/Bluesky/bluesky_login.dart';
import 'package:prism/services/API/Bluesky/api_storage.dart';

class BlueskyAccount extends StatefulWidget {
  const BlueskyAccount({super.key});

  @override
  State<BlueskyAccount> createState() => _BlueskyAccountState();
}

class _BlueskyAccountState extends State<BlueskyAccount> {
  // Setup data default
  String _avatar = "https://i.imgur.com/tdi3NGa.png"; // Placeholder
  String _name = "";
  String _username = "";
  String _followers = "0";

  // Flag untuk loading
  bool _isLoading = true;

  final BlueskyController _controller = BlueskyController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _controller.init().then((isLogin) {
      if (isLogin) {
        _controller.getProfile().then((value) {
          setState(() {
            _name = value.displayName ?? "Unknown";
            _username = value.handle;
            _avatar = value.avatar ?? "https://i.imgur.com/tdi3NGa.png";
            _followers = value.followersCount.toString();
            _isLoading = false;
          });
        });
      } else {
        setState(() {
          _name = "Guest";
          _username = "Not Logged In";
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final BlueskyStorage _storage = BlueskyStorage();
    void logout() {
      _storage.clearSession();
      setState(() {
        _name = "Guest";
        _username = "Guest";
        _avatar = "https://i.imgur.com/tdi3NGa.png";
        _followers = "0";
      });
    }

    void logoutDialog() {
      AceAlertPopup.show(
        context,
        title: "Logout",
        btnText: "Yes, Logout",
        color: Colors.red,
        isCancel: true,
        message: "Are you sure you want to logout?",
        onPressed: () {
          logout();
          Navigator.pop(context);
        },
      );
    }

    return AceSimpleLayout(
      title: "Bluesky Account",
      childern: [
        AceCard(
          child: Row(
            children: [
              CircleAvatar(radius: 25, backgroundImage: NetworkImage(_avatar)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // 2. LOGIKA LOADING YANG BENAR
                children: _isLoading
                    ? [
                        // Tampilan Skeleton (Loading)
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
                        // Tampilan Data Asli
                        Text(
                          _name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("@$_username"), // Tambah @ biar keren
                        Text("$_followers followers"),
                      ],
              ),
            ],
          ),
        ),

        AceListTiles(
          title: "Login / Switch Account", // Ubah text biar jelas
          icon: Icons.login,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BlueskyLogin()),
            ).then((_) {
              // Opsional: Reload profil setelah balik dari halaman login
              _loadProfile();
            });
          },
          isActive: false,
        ),
        AceListTiles(
          title: "Logout",
          icon: Icons.logout,
          onTap: () => logoutDialog(),
          isActive: false,
        ),
      ],
    );
  }
}
