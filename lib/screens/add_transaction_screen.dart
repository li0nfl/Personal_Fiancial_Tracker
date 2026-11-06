import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'pengeluaran';
  final FirestoreService _firestoreService = FirestoreService();

  void _saveTransaction() async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap isi semua bidang!')));
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus berupa angka!')),
      );
      return;
    }

    await _firestoreService.addTransaction(title, amount, _selectedType);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul Transaksi'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nominal Angka'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: 'pemasukan', child: Text('Pemasukan')),
                DropdownMenuItem(
                  value: 'pengeluaran',
                  child: Text('Pengeluaran'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
              decoration: const InputDecoration(labelText: 'Tipe Transaksi'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTransaction,
              child: const Text('Simpan Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}
