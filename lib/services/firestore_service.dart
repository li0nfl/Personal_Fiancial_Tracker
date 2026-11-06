import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;

  // Reference ke sub-koleksi transactions milik user
  CollectionReference get _transactionRef =>
      _firestore.collection('users').doc(userId).collection('transactions');

  // Create Transaksi
  Future<void> addTransaction(String title, double amount, String type) async {
    await _transactionRef.add({
      'title': title,
      'amount': amount,
      'type': type,
      'date': Timestamp.now(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Read Stream (Real-time & diurutkan dari transaksi terbaru)
  Stream<List<TransactionModel>> getTransactions() {
    return _transactionRef.orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    });
  }

  // Update Transaksi
  Future<void> updateTransaction(
    String id,
    String title,
    double amount,
    String type,
  ) async {
    await _transactionRef.doc(id).update({
      'title': title,
      'amount': amount,
      'type': type,
    });
  }

  // Delete Transaksi
  Future<void> deleteTransaction(String id) async {
    await _transactionRef.doc(id).delete();
  }
}
