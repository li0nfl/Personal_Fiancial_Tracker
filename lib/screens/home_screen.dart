import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Konfirmasi Dialog Logout (Sesuai Modul 1)
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah kamu yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Ucapan & Nama User
          FutureBuilder<DocumentSnapshot>(
            future: AuthService().getUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                );
              }
              String name = 'Pengguna';
              if (snapshot.hasData && snapshot.data!.exists) {
                name = snapshot.data!['name'] ?? 'Pengguna';
              }
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Colors.blue.shade50,
                child: Text(
                  'Selamat datang, $name!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),

          // Real-time StreamBuilder Transaksi & Ringkasan Statistik
          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              stream: firestoreService.getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<TransactionModel> transactions = snapshot.data ?? [];

                // Hitung Statistik Total Transaksi
                double totalPemasukan = 0;
                double totalPengeluaran = 0;

                for (var t in transactions) {
                  if (t.type == 'pemasukan') {
                    totalPemasukan += t.amount;
                  } else {
                    totalPengeluaran += t.amount;
                  }
                }

                double saldo = totalPemasukan - totalPengeluaran;

                return Column(
                  children: [
                    // Card Ringkasan Statistik
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Pemasukan',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  Text(
                                    currencyFormatter.format(totalPemasukan),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Pengeluaran',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  Text(
                                    currencyFormatter.format(totalPengeluaran),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Saldo',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  Text(
                                    currencyFormatter.format(saldo),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // List Riwayat Transaksi Real-time
                    Expanded(
                      child: transactions.isEmpty
                          ? const Center(child: Text('Belum ada transaksi.'))
                          : ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final item = transactions[index];
                                bool isPemasukan = item.type == 'pemasukan';

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isPemasukan
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    child: Icon(
                                      isPemasukan
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color: isPemasukan
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  title: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    DateFormat(
                                      'dd MMM yyyy, HH:mm',
                                    ).format(item.date),
                                  ),
                                  trailing: Text(
                                    '${isPemasukan ? "+" : "-"} ${currencyFormatter.format(item.amount)}',
                                    style: TextStyle(
                                      color: isPemasukan
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    // Detail & Edit Transaksi
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditTransactionScreen(
                                              transaction: item,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
