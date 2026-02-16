// import 'package:flutter/material.dart';
// import 'package:webview_all/webview_all.dart';

// class AceWebviewLogin extends StatefulWidget {
//   final String authUrl;
//   final String callbackScheme; // default: "aceui"

//   const AceWebviewLogin({
//     super.key,
//     required this.authUrl,
//     this.callbackScheme = "aceui",
//   });

//   @override
//   State<AceWebviewLogin> createState() => _AceWebviewLoginState();
// }

// class _AceWebviewLoginState extends State<AceWebviewLogin> {
//   bool _isLoading = true;
//   // WebviewController di package ini beda, dia handle internal state

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Login Twitter"),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.pop(context, null),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Webview(
//             url: widget.authUrl,
//           ),
//           if (_isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }

//   // LOGIKA UTAMA: Cek URL apakah mengandung callback
//   void _checkUrl(String url) {
//     // Cek apakah URL ini adalah callback kita? (misal: aceui://callback)
//     // Atau kadang browser redirect ke localhost/callback
//     if (url.startsWith(widget.callbackScheme) ||
//         url.contains("oauth_verifier")) {
//       print("URL Callback Terdeteksi: $url");

//       try {
//         final uri = Uri.parse(url);
//         final verifier = uri.queryParameters['oauth_verifier'];

//         if (verifier != null) {
//           // SUKSES! Tutup halaman & kirim verifier
//           // Kita beri delay sedikit agar redirect browser tuntas
//           Future.delayed(const Duration(milliseconds: 500), () {
//             if (mounted) Navigator.pop(context, verifier);
//           });
//         }
//       } catch (e) {
//         print("Error parsing URL: $e");
//       }
//     }
//   }
// }
