import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TwitterApiNotice extends StatelessWidget {
  const TwitterApiNotice({super.key});

  // Fungsi helper untuk membuka link
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Style dasar untuk teks biasa
    final TextStyle defaultStyle = TextStyle(
      fontSize: 14,
      color: Theme.of(context).colorScheme.onSurface,
      height: 1.5, // Spasi antar baris biar enak dibaca
    );

    // Style untuk Link (Biru & Underline)
    final TextStyle linkStyle = TextStyle(
      fontSize: 14,
      color: Colors.blue,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Menggunakan warna surface atau sedikit berbeda untuk warning
        color: Theme.of(context).colorScheme.surfaceContainerHighest, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kecil (Opsional)
          Row(
            children: [
              Icon(Icons.vpn_key, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                "API Setup Required",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ISI KONTEN (RichText)
          RichText(
            text: TextSpan(
              style: defaultStyle,
              children: [
                const TextSpan(
                  text: "Please enter your Twitter API keys. Since the API crackdown in March 2023 (thanks, Elon... I seriously hate that guy), this app requires your own Developer credentials to work.\n\nDon't worry, ",
                ),
                
                // BAGIAN BOLD: Privacy Assurance
                TextSpan(
                  text: "I don't collect your data",
                  style: defaultStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                
                const TextSpan(
                  text: ". You can verify the code yourself here:\n",
                ),

                // BAGIAN LINK: Source Code
                TextSpan(
                  text: "https://github.com/KnoyanMitsu/prism",
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _launchUrl("https://github.com/KnoyanMitsu/prism"),
                ),

                const TextSpan(
                  text: ".\n\nNeed keys? Get them here:\n",
                ),

                // BAGIAN LINK: Developer Portal
                TextSpan(
                  text: "https://developer.twitter.com/en/portal/dashboard",
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _launchUrl("https://developer.twitter.com/en/portal/dashboard"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}