import 'package:flutter/material.dart';

class AceCard extends StatelessWidget {
  // 1. Ganti jadi Stateless & Ganti nama
  final Widget child;
  final EdgeInsetsGeometry?
  padding; // 2. Opsional: biar padding bisa diatur dari luar

  const AceCard({
    super.key,
    required this.child,
    this.padding, // Default null
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 8,
      ), // Margin Luar
      // 3. Dekorasi (Background & Shadow)
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // Warna Kartu
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow lebih soft
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      // 4. PADDING: Ini jarak antara Tepi Kartu dengan Isinya (child)
      // Jika di sini diset, isinya pasti akan menjorok ke dalam.
      padding: padding ?? const EdgeInsets.all(16),

      child: child,
    );
  }
}
