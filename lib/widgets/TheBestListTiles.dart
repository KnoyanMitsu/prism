import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TheBestListTiles extends StatelessWidget {
  const TheBestListTiles({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isActive,
    this.aceIcon = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final bool aceIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Margin antar item biar tidak mepet
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      // Material & InkWell agar ada efek "percikan air" (Ripple) saat diklik
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15), // Ripple ikut melengkung
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                if (aceIcon) ...[
                  SvgPicture.asset(
                    'assets/icons/ace.svg',
                    width: 15,
                    height: 15,
                    colorFilter: ColorFilter.mode(
                      isActive ? Colors.white : Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 9),
                ],

                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.black,
                  size: 24,
                ),

                const SizedBox(width: 9), // Jarak ikon ke teks
                // 2. TEKS JUDUL
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins', // Sesuaikan font Anda
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? Colors.white : Colors.black87,
                    ),
                  ),
                ),

                // 3. (Opsional) Indikator panah kecil di kanan
                if (!isActive)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
