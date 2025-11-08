// all_cards_screen.dart

import 'package:flutter/material.dart';
import '../widgets/atm_card.dart';

class AllCardsScreen extends StatelessWidget {
  // 🔥 TERIMA allCards DARI HOME SCREEN
  final List<Map<String, dynamic>> allCards;
  
  const AllCardsScreen({
    super.key, 
    required this.allCards, // 🔥 Parameter wajib
  });

  // 🔥 FUNGSI HELPER UNTUK FORMAT ANGKA
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Kartu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allCards.length,
        itemBuilder: (context, index) {
          final card = allCards[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                // Kirim data kartu yang dipilih kembali ke HomeScreen
                Navigator.pop(context, card);
              },
              child: AtmCard(
                bankName: card['bankName'],
                cardNumber: card['cardNumber'],
                balance: 'Rp${_formatNumber(card['balance'])}', // 🔥 Format balance
                color1: card['color1'],
                color2: card['color2'],
              ),
            ),
          );
        },
      ),
    );
  }
}