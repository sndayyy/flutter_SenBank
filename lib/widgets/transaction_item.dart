// transaction_item.dart

import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  
  // 🛑 PROPERTI BARU UNTUK SELEKSI 🛑
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TransactionItem({
    super.key, 
    required this.transaction,
    required this.isSelectionMode, // Tambah properti ini
    required this.isSelected,     // Tambah properti ini
    required this.onTap,          // Tambah properti ini
    required this.onLongPress,    // Tambah properti ini
  });
  
  // Fungsi untuk mendapatkan ikon berdasarkan kategori (Tidak diubah)
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Food': return Icons.fastfood;
      case 'Travel': return Icons.travel_explore;
      case 'Health': return Icons.health_and_safety;
      case 'Income': return Icons.trending_up;
      case 'Cash In': return Icons.arrow_circle_up;
      // 🔥 Perubahan Ikon untuk Cash Out (Tarik Tunai)
      case 'Cash Out': return Icons.local_atm; 
      case 'Service': return Icons.receipt_long;
      // 🔥 Penambahan Ikon untuk Shopping (Book Store)
      case 'Shopping': return Icons.shopping_bag; 
      case 'Event': return Icons.event;
      // Ikon default yang sebelumnya muncul di Cash Out/Shopping
      default: return Icons.category; 
    }
  }

  // Fungsi untuk mendapatkan warna berdasarkan kategori (Tidak diubah)
  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Food': return Colors.orange.shade700;
      case 'Travel': return Colors.blue.shade700;
      case 'Health': return Colors.red.shade700;
      case 'Income': return Colors.green.shade700;
      case 'Cash In': return Colors.teal.shade600;
      // 🔥 PASTIKAN PENULISAN 'Cash Out' SAMA PERSIS
      case 'Cash Out': return const Color.fromARGB(255, 255, 0, 0); 
      case 'Service': return Colors.indigo.shade600;
      // 🔥 WARNA UNTUK SHOPPING (Book Store)
      case 'Shopping': return Colors.purple.shade700;
      case 'Event': return Colors.pink.shade700;
      default: return Colors.grey.shade600; 
    }
  }

  // Fungsi untuk menampilkan detail transaksi dalam dialog (Dipertahankan)
  void _showTransactionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jumlah: ${transaction.amount}', 
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: transaction.amount.startsWith('-') ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text('Kategori: ${transaction.category}'),
              const SizedBox(height: 4),
              // Gunakan data statis/dummy untuk waktu dan status 
              // karena TransactionModel Anda tidak menyimpannya
              const Text('Waktu: 6 November 2025, 18:55'), 
              const SizedBox(height: 4),
              const Text('Status: Selesai'), 
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconForCategory(transaction.category);
    final iconColor = _getColorForCategory(transaction.category);
    
    // Warna untuk visual seleksi
    final selectionColor = isSelected ? Colors.lightBlue.shade50 : Colors.white;

    return Card(
      elevation: 0, 
      color: selectionColor, // 🛑 Ganti warna saat dipilih
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isSelected ? BorderSide(color: Colors.blue.shade300, width: 2) : BorderSide.none, // 🛑 Tambah border saat dipilih
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0), // Tambah margin vertikal sedikit
      // 🛑 GUNAKAN INKWELL UNTUK ONTAP DAN ONLONGPRESS 🛑
      child: InkWell(
        // Perilaku Tap:
        // Jika dalam mode seleksi, panggil onTap (untuk toggle seleksi).
        // Jika tidak, tampilkan detail transaksi.
        onTap: isSelectionMode ? onTap : () => _showTransactionDetails(context), 
        onLongPress: onLongPress, // Panggil callback long press untuk mengaktifkan selection mode
        borderRadius: BorderRadius.circular(10), 
        child: ListTile(
          // 🛑 LEADING: Tampilkan checkbox jika dalam selection mode
          leading: isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (val) {
                    onTap(); // Panggil onTap untuk toggle selection
                  },
                )
              : Container( // Tampilkan ikon kategori jika tidak dalam selection mode
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
          
          title: Text(
            transaction.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            transaction.category,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          trailing: Text(
            transaction.amount,
            style: TextStyle(
              color: transaction.amount.startsWith('-')
                  ? Colors.red.shade700 
                  : Colors.green.shade700, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}