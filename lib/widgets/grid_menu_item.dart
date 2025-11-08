import 'package:flutter/material.dart';

class GridMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  // 🛑 PERBAIKAN: Menambahkan properti onTap 🛑
  final VoidCallback? onTap; 

  const GridMenuItem({
    super.key, 
    required this.icon, 
    required this.label,
    this.onTap, // onTap sekarang opsional
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( // Menggunakan InkWell agar item bisa diklik
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple.shade100, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: const Color.fromARGB(255, 0, 142, 203)),
            const SizedBox(height: 8),
            // Memastikan teks rata tengah dan tidak overflow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2, 
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}