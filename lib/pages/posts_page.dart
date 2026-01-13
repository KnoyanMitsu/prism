import 'package:aceui/aceui.dart';
import 'package:flutter/material.dart';
import 'package:prism/controller/twitter_controller.dart';
import 'package:prism/widget/four_upload_photo.dart';
import 'package:prism/widget/pill_count.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  // Controller
  final TwitterController _controller = TwitterController();
  final TextEditingController _text = TextEditingController();
  final FourUploadPhotoController _controllerUpload =
      FourUploadPhotoController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  // Wajib dispose controller biar memori HP gak bocor
  @override
  void dispose() {
    _text.dispose();
    _controller.dispose();
    _controllerUpload.dispose();
    super.dispose();
  }

  // --- PERBAIKAN UTAMA DI SINI ---
  Future<void> _postTweet() async {
    // 1. Validasi: Jangan kirim kalau teks kosong DAN gambar kosong
    if (_text.text.trim().isEmpty && _controllerUpload.images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tulis sesuatu atau upload gambar dulu!")),
      );
      return;
    }

    // 2. Mulai Loading
    setState(() {
      _isLoading = true;
    });

    String result;

    // 3. Eksekusi Logic (Pakai await supaya ditungguin)
    if (_controllerUpload.images.isNotEmpty) {
      result = await _controller.postTweetWithImages(
        _text.text,
        _controllerUpload.images,
      );
    } else {
      result = await _controller.postTweet(_text.text);
    }

    // 4. Selesai Loading & Tampilkan Hasil
    if (mounted) {
      // Cek mounted biar gak error kalau user udah pindah halaman
      setState(() {
        _isLoading = false;
      });

      // Tampilkan notifikasi hasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: result.contains("Berhasil")
              ? Colors.green
              : Colors.red,
        ),
      );

      // Kalau berhasil, bersihkan form
      if (result.contains("Berhasil")) {
        _text.clear();
        // Anda mungkin perlu nambahin fungsi clear() di FourUploadPhotoController juga
        // _controllerUpload.clearImages();
        Navigator.pop(context); // Opsional: Tutup halaman posting
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AceSimpleLayout(
      title: "Posts",
      childern: [
        // Typo di library AceUI? biasanya 'children'
        AceTextFieldWithLabel(
          controller: _text,
          label: "Tell me what your story...", // Titik diperbaiki dikit
          type: TypeField.text,
          required: true,
          maxLine: 6,
          border: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainer,
        ),

        const SizedBox(height: 10), // Jarak dikit

        FourUploadPhoto(controller: _controllerUpload),

        // HATI-HATI: Spacer() hanya jalan kalau AceSimpleLayout pakai Column dengan fix height.
        // Kalau AceSimpleLayout pakai ListView (Scrollable), Spacer() akan bikin ERROR.
        // Jika error, ganti Spacer() dengan SizedBox(height: 50).
        const Spacer(),

        Row(
          children: [
            // Logic PillCount nanti bisa disambungin ke _text.text.length
            PillCount(icon: "assets/icons/X.svg", count: "1", limit: "1"),
            const SizedBox(width: 10),
            PillCount(icon: "assets/icons/X.svg", count: "1", limit: "1"),
          ],
        ),
        const SizedBox(height: 20),
        AceButton(
          color: Theme.of(context).colorScheme.primary,
          label: "Post it",
          onPressed: _isLoading
              ? null
              : _postTweet, // Disable tombol saat loading
          isLoading: _isLoading,
          colorText: Theme.of(context).colorScheme.onPrimary,
        ),
      ],
    );
  }
}
