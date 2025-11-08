// home_screen.dart

import 'package:flutter/material.dart';
import '../widgets/transaction_item.dart'; 
import '../models/transaction.dart'; 
import '../widgets/grid_menu_item.dart'; 
import 'all_cards_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ===================================
  // 🔥 DATA STATE
  // ===================================
  
  // DATA KARTU YANG DIPILIH (default Bank A) - DENGAN BALANCE NUMERIK
  Map<String, dynamic> _kartuTerpilih = {
    'bankName': 'snday1',
    'cardNumber': '8765 2345',
    'balance': 12500000, 
    'color1': const Color(0xFF7B68EE),
    'color2': const Color(0xFF6A5ACD),
  };
  
  // DAFTAR SEMUA KARTU DENGAN BALANCE YANG BISA DIUPDATE
  final List<Map<String, dynamic>> _semuaKartu = [
    {
      'bankName': 'snday1',
      'cardNumber': '8765 2345',
      'balance': 12500000,
      'color1': const Color(0xFF7B68EE),
      'color2': const Color(0xFF6A5ACD),
    },
    {
      'bankName': 'snday2',
      'cardNumber': '9988 8765',
      'balance': 5350000,
      'color1': const Color(0xFF6A5ACD),
      'color2': const Color(0xFF8A2BE2),
    },
    {
      'bankName': 'snday3',
      'cardNumber': '1122 9988',
      'balance': 9750000,
      'color1': const Color(0xFF8A2BE2),
      'color2': const Color(0xFF9370DB),
    },
    {
      'bankName': 'snday4',
      'cardNumber': '2345 1122',
      'balance': 2150000,
      'color1': const Color(0xFF9370DB),
      'color2': const Color(0xFFBA55D3),
    },
  ];
  
  // DATA TRANSAKSI STATEFUL
  final List<TransactionModel> _transaksi = [
    TransactionModel('Gaji', '+Rp5.000.000', 'Income'), 
    TransactionModel('Setor Tunai (ATM)', '+Rp800.000', 'Cash In'), 
    TransactionModel('Tarik Tunai (ATM)', '-Rp200.000', 'Cash Out'), 
    TransactionModel('Tarik Tunai (Teller)', '-Rp500.000', 'Cash Out'), 
    TransactionModel('Warung Kopi', '-Rp35.000', 'Food'),
    TransactionModel('Pemasaran Digital', '-Rp175.000', 'Service'),
    TransactionModel('Transfer (Rudi)', '+Rp500.000', 'Income'), 
    TransactionModel('Grab Ride', '-Rp25.000', 'Travel'),
    TransactionModel('Toko Buku', '-Rp95.000', 'Shopping'),
    TransactionModel('Membership Gym', '-Rp150.000', 'Health'),
    TransactionModel('Tiket Bioskop', '-Rp60.000', 'Event'),
  ];

  // STATE UNTUK SELEKSI MULTIPLE
  bool _modeSeleksi = false;
  final List<TransactionModel> _transaksiTerpilih = [];

  // STATE DAN LOGIKA FILTER KATEGORI
  String _kategoriTerpilih = 'Semua';

  // ===================================
  // LOGIKA DATA & SELEKSI MULTIPLE
  // ===================================

  List<TransactionModel> _transaksiTerfilter() {
    if (_kategoriTerpilih == 'Semua') return _transaksi;

    if (_kategoriTerpilih == 'Top Up') {
      return _transaksi.where((t) => t.title.contains('Top Up')).toList();
    } else if (_kategoriTerpilih == 'Transfer') {
      return _transaksi.where((t) => t.title.toLowerCase().contains('transfer')).toList();
    } else if (_kategoriTerpilih == 'Setor/Tarik Tunai') {
      return _transaksi.where((t) => 
        t.title.toLowerCase().contains('setor') || 
        t.title.toLowerCase().contains('tarik')
      ).toList();
    } else {
      return _transaksi.where((t) => 
        t.category.toLowerCase() == _kategoriTerpilih.toLowerCase()
      ).toList();
    }
  }

  void _selectCategory(String category) {
    if (category == 'Lainnya') {
      _showOtherCategoriesDialog();
    } else {
      setState(() {
        _kategoriTerpilih = category;
      });
    }
  }

  void _toggleSelectionMode(TransactionModel transaction) {
    setState(() {
      _modeSeleksi = true;
      _toggleSelection(transaction);
    });
  }

  void _toggleSelection(TransactionModel transaction) {
    setState(() {
      if (_transaksiTerpilih.contains(transaction)) {
        _transaksiTerpilih.remove(transaction);
      } else {
        _transaksiTerpilih.add(transaction);
      }
      
      if (_transaksiTerpilih.isEmpty) {
        _modeSeleksi = false;
      }
    });
  }

  void _deleteSelectedTransactions() {
    final deletedCount = _transaksiTerpilih.length;
    setState(() {
      _transaksi.removeWhere((t) => _transaksiTerpilih.contains(t));
      _transaksiTerpilih.clear();
      _modeSeleksi = false;
    });
    

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCustomNotificationDialogWithImage(
        context, 
        'Penghapusan Berhasil', 
        '$deletedCount transaksi telah dihapus.', 
        'assets/images/delete_history.png', 
        isSuccess: true
      );
    });
  }
  
  void _updateCardBalance(int amount) {
    setState(() {
      // Update balance kartu yang dipilih
      _kartuTerpilih['balance'] = _kartuTerpilih['balance'] + amount;
      
      // Update di list allCards
      final cardIndex = _semuaKartu.indexWhere(
        (card) => card['cardNumber'] == _kartuTerpilih['cardNumber']
      );
      if (cardIndex != -1) {
        _semuaKartu[cardIndex]['balance'] = _kartuTerpilih['balance'];
      }
    });
  }


  // ===================================
  //DIALOGS (Top Up, Transfer, Lainnya, Notifikasi)
  // ===================================

  void _showOtherCategoriesDialog() {
    final List<String> otherCategories = [
      'Tagihan',
      'Kartu',
      'Donasi',
      'Health', 
      'Travel',
      'Food',
      'Event',
      'Shopping',
      'Service',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Kategori Lainnya'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: otherCategories.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(otherCategories[index]),
                onTap: () {
                  setState(() {
                    _kategoriTerpilih = otherCategories[index];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  //DIALOG TOP UP DENGAN PILIHAN METODE
  void _showTopUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Metode Top Up'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaymentMethodOption(
              context,
              'Dana',
              Icons.account_balance_wallet,
              Colors.blue,
              'Dana',
            ),
            const SizedBox(height: 8),
            _buildPaymentMethodOption(
              context,
              'GoPay',
              Icons.credit_card,
              Colors.green,
              'GoPay',
            ),
            const SizedBox(height: 8),
            _buildPaymentMethodOption(
              context,
              'OVO',
              Icons.payment,
              Colors.purple,
              'OVO',
            ),
            const SizedBox(height: 8),
            _buildPaymentMethodOption(
              context,
              'ShopeePay',
              Icons.shopping_bag,
              Colors.orange,
              'ShopeePay',
            ),
            const SizedBox(height: 8),
            _buildPaymentMethodOption(
              context,
              'LinkAja',
              Icons.link,
              Colors.red,
              'LinkAja',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
    String method,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _showTopUpAmountDialog(context, method);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _showTopUpAmountDialog(BuildContext context, String method) {
    TextEditingController amountController = TextEditingController();
    TextEditingController accountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Top Up via $method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: accountController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Nomor Tujuan $method',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone_android),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Masukkan Jumlah Top Up (Rp)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final amountText = amountController.text.trim();
              final accountText = accountController.text.trim();
              Navigator.pop(context);

              final amount = double.tryParse(amountText);
              bool isValidAmount = amount != null && amount > 0 && amount.toInt() <= (_kartuTerpilih['balance'] as int);
              bool isValidAccount = accountText.length >= 10;
              
              if (amount == null || amount <= 0) {
                _showCustomNotificationDialogWithImage(
                  context,
                  'Top Up Gagal',
                  'Mohon masukkan jumlah Top Up yang valid (harus lebih dari Rp0).',
                  'assets/images/topup_failed.png',
                  isSuccess: false,
                );
              } else if (!isValidAccount) {
                _showCustomNotificationDialogWithImage(
                  context,
                  'Top Up Gagal',
                  'Mohon masukkan nomor tujuan yang valid (min. 10 digit).',
                  'assets/images/topup_failed.png',
                  isSuccess: false,
                );
              } else if (!isValidAmount) {
                _showCustomNotificationDialogWithImage(
                  context,
                  'Top Up Gagal',
                  'Saldo tidak mencukupi untuk Top Up sebesar Rp${_formatNumber(amount.toInt())}.',
                  'assets/images/topup_failed.png',
                  isSuccess: false,
                );
              } else {
                // UPDATE BALANCE KARTU (KURANGI SALDO)
                _updateCardBalance(-amount.toInt());
                
                // TAMBAHKAN TRANSAKSI BARU KE DAFTAR
                setState(() {
                  _transaksi.insert(0, TransactionModel(
                    'Top Up $method ($accountText)',
                    '-Rp${_formatNumber(amount.toInt())}',
                    'Service'
                  ));
                });
                
                _showCustomNotificationDialogWithImage(
                  context,
                  'Top Up Berhasil',
                  'Top Up sebesar Rp${_formatNumber(amount.toInt())} ke $method ($accountText) berhasil.',
                  'assets/images/topup_success.png',
                  isSuccess: true,
                );
              }
            },
            child: const Text('Top Up', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // DIALOG TRANSFER DENGAN PILIHAN METODE
  void _showTransferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Metode Transfer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTransferMethodOption(
              context,
              'ke Bank',
              Icons.account_balance,
              Colors.blue,
              'Bank',
            ),
            const SizedBox(height: 8),
            _buildTransferMethodOption(
              context,
              'E-Wallet',
              Icons.account_balance_wallet,
              Colors.green,
              'E-Wallet',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferMethodOption(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
    String method,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _showTransferDetailsDialog(context, method);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _showTransferDetailsDialog(BuildContext context, String method) {
    TextEditingController amountController = TextEditingController();
    TextEditingController recipientController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer ke $method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: recipientController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: method == 'Bank' ? 'Nomor Rekening Tujuan' : 'Nomor E-Wallet',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Transfer (Rp)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final amountText = amountController.text.trim();
              final recipientText = recipientController.text.trim();
              Navigator.pop(context);

              final amount = double.tryParse(amountText);
              bool isValidAmount = amount != null && amount > 0 && amount.toInt() <= (_kartuTerpilih['balance'] as int);
              bool isValidRecipient = recipientText.length >= 5;
              
              if (!isValidAmount || !isValidRecipient) {
                String errorMessage = '';
                if (!isValidAmount) {
                  errorMessage = 'Mohon periksa kembali jumlah transfer (harus > Rp0 dan tidak melebihi saldo).';
                } else if (!isValidRecipient) {
                  errorMessage = 'Mohon periksa nomor tujuan (min. 5 digit).';
                } else {
                  errorMessage = 'Mohon periksa kembali jumlah transfer dan nomor tujuan.';
                }

                _showCustomNotificationDialogWithImage(
                  context,
                  'Transfer Gagal',
                  errorMessage,
                  'assets/images/transfer_failed.png',
                  isSuccess: false,
                );
              } else {
                // UPDATE BALANCE KARTU (KURANGI)
                _updateCardBalance(-amount.toInt());
                
                // TAMBAHKAN TRANSAKSI BARU KE DAFTAR
                setState(() {
                  _transaksi.insert(0, TransactionModel(
                    'Transfer ke $method ($recipientText)',
                    '-Rp${_formatNumber(amount.toInt())}',
                    'Service'
                  ));
                });
                
                _showCustomNotificationDialogWithImage(
                  context,
                  'Transfer Berhasil',
                  'Rp${_formatNumber(amount.toInt())} berhasil ditransfer ke $method ($recipientText).',
                  'assets/images/transfer_success.png',
                  isSuccess: true,
                );
              }
            },
            child: const Text('Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String menuName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/comingsoon.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.construction,
                  size: 150,
                  color: Colors.orange,
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Fitur Segera Hadir',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mohon maaf, fitur "$menuName" sedang dalam pengembangan. Nantikan pembaruan selanjutnya!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // DIALOG SETOR TUNAI
  void _showSetorTunaiDialog(BuildContext context) {
    TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setor Tunai'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Masukkan Jumlah Setor Tunai (Rp)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final amountText = amountController.text.trim();
              Navigator.pop(context);

              final amount = double.tryParse(amountText);
              
              if (amount == null || amount <= 0) {
                _showCustomNotificationDialogWithImage(
                  context,
                  'Setor Tunai Gagal',
                  'Mohon masukkan jumlah setor tunai yang valid (harus lebih dari Rp0).',
                  'assets/images/setortunai_failed.png',
                  isSuccess: false,
                );
              } else {
                // UPDATE BALANCE KARTU (TAMBAH SALDO)
                _updateCardBalance(amount.toInt());
                
                // TAMBAHKAN TRANSAKSI BARU KE DAFTAR
                setState(() {
                  _transaksi.insert(0, TransactionModel(
                    'Setor Tunai (Teller)',
                    '+Rp${_formatNumber(amount.toInt())}',
                    'Cash In'
                  ));
                });
                
                _showCustomNotificationDialogWithImage(
                  context,
                  'Setor Tunai Berhasil',
                  'Saldo Anda telah bertambah sebesar Rp${_formatNumber(amount.toInt())}.',
                  'assets/images/setortunai_success.png',
                  isSuccess: true,
                );
              }
            },
            child: const Text('Setor', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCustomNotificationDialogWithImage(
    BuildContext context, 
    String title, 
    String message, 
    String imagePath,
    {bool isSuccess = true}
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  size: 150,
                  color: isSuccess ? Colors.green : Colors.red,
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  
  // ===================================
  // HELPER FUNCTIONS & WIDGETS
  // ===================================

  // FUNGSI HELPER UNTUK FORMAT ANGKA
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
  
  Widget _buildCategoryChip(String category) {
    final bool isSelected = _kategoriTerpilih == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        selectedColor: Colors.deepPurple.shade100,
        onSelected: (_) => _selectCategory(category),
      ),
    );
  }

  // ===================================
  // WIDGET BUILD
  // ===================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SenBank'),
        backgroundColor: const Color.fromARGB(255, 0, 142, 203),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //  KOTAK KARTU
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage( 
                        image: AssetImage('assets/images/atm.png'), 
                        fit: BoxFit.cover, 
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_kartuTerpilih['color2'] as Color).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect( 
                      borderRadius: BorderRadius.circular(16),
                      child: Stack( 
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _kartuTerpilih['bankName'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Rp${_formatNumber(_kartuTerpilih['balance'])}', 
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _kartuTerpilih['cardNumber'],
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                    
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllCardsScreen(allCards: _semuaKartu), 
                        ),
                      );
                      
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _kartuTerpilih = result;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Semua Kartu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // MENU LAYANAN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      GridMenuItem(
                          icon: Icons.mobile_friendly,
                          label: 'Top Up', 
                          onTap: () => _showTopUpDialog(context)),
                      GridMenuItem(
                          icon: Icons.sync_alt,
                          label: 'Transfer',
                          onTap: () => _showTransferDialog(context)),
                      GridMenuItem(
                          icon: Icons.arrow_circle_up,
                          label: 'Setor Tunai',
                          onTap: () => _showSetorTunaiDialog(context)),
                      GridMenuItem(
                          icon: Icons.receipt_long,
                          label: 'Tagihan',
                          onTap: () => _showComingSoonDialog(context, 'Tagihan')),
                      GridMenuItem(
                          icon: Icons.credit_card,
                          label: 'Kartu',
                          onTap: () => _showComingSoonDialog(context, 'Layanan Kartu')),
                      GridMenuItem(
                          icon: Icons.local_atm,
                          label: 'Tarik Tunai',
                          onTap: () => _showComingSoonDialog(context, 'Tarik Tunai')),
                      GridMenuItem(
                          icon: Icons.trending_up,
                          label: 'Investasi',
                          onTap: () => _showComingSoonDialog(context, 'Investasi')),
                      GridMenuItem(
                          icon: Icons.volunteer_activism,
                          label: 'Donasi',
                          onTap: () => _showComingSoonDialog(context, 'Donasi')),
                      GridMenuItem(
                          icon: Icons.health_and_safety,
                          label: 'Kesehatan', 
                          onTap: () => _showComingSoonDialog(context, 'Kesehatan')),
                      GridMenuItem(
                          icon: Icons.travel_explore,
                          label: 'Perjalanan', 
                          onTap: () => _showComingSoonDialog(context, 'Perjalanan')),
                      GridMenuItem(
                          icon: Icons.fastfood,
                          label: 'Makanan',
                          onTap: () => _showComingSoonDialog(context, 'Makanan')),
                      GridMenuItem(
                          icon: Icons.event,
                          label: 'Acara', 
                          onTap: () => _showComingSoonDialog(context, 'Acara')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // transaksi terbaru
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _modeSeleksi
                            ? '${_transaksiTerpilih.length} Dipilih'
                            : 'Transaksi Terbaru', 
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_modeSeleksi)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: _transaksiTerpilih.isNotEmpty
                                  ? _deleteSelectedTransactions
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _modeSeleksi = false;
                                  _transaksiTerpilih.clear();
                                });
                              },
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // FILTER KATEGORI TRANSAKSI
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('Semua'),
                        _buildCategoryChip('Top Up'),
                        _buildCategoryChip('Transfer'),
                        _buildCategoryChip('Setor/Tarik Tunai'),
                        _buildCategoryChip('Lainnya'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // LIST TRANSAKSI DENGAN FILTER
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _transaksiTerfilter().length,
                    itemBuilder: (context, index) {
                      final transaction = _transaksiTerfilter()[index];
                      final isSelected = _transaksiTerpilih.contains(transaction);

                      return TransactionItem(
                        transaction: transaction,
                        isSelectionMode: _modeSeleksi,
                        isSelected: isSelected,
                        onTap: () {
                          if (_modeSeleksi) {
                            _toggleSelection(transaction);
                          }
                        },
                        onLongPress: () {
                          _toggleSelectionMode(transaction);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // ======================================
      // bottom navigatin bar
      // ======================================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 142, 203),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Beranda
            Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.home_rounded, size: 28, color: Colors.white),
                SizedBox(height: 4),
                Text(
                  'Beranda',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(width: 60),

            // Akun
            InkWell(
              onTap: () {
                _showComingSoonDialog(context, 'Menu Akun');
              },
              borderRadius: BorderRadius.circular(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.person_rounded, size: 28, color: Colors.white70),
                  SizedBox(height: 4),
                  Text(
                    'Akun',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Scan
      floatingActionButton: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF7B68EE), Color(0xFF6A5ACD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: RawMaterialButton(
          shape: const CircleBorder(),
          onPressed: () {
            _showComingSoonDialog(context, 'Scan QR');
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
              SizedBox(height: 2),
              Text(
                'Scan',
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}