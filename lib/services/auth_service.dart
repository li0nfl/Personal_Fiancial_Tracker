import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Stream status login
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register
  Future<UserCredential?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Simpan data profil ke koleksi users (sesuai modul 1)
    if (credential.user != null) {
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  // Login
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Ambil data profil user aktif
  Future<DocumentSnapshot> getUserProfile() async {
    return await _firestore.collection('users').doc(currentUser!.uid).get();
  }
}
