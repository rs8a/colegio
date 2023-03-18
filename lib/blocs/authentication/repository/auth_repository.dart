import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as fir_store;
import 'package:colegio/class/alumno.dart';
import 'package:firebase_auth/firebase_auth.dart' as fir_auth;

import '../../../class/user.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository();
  static AuthRepository get instance => _instance;

  AuthRepository({
    fir_auth.FirebaseAuth? firebaseAuth,
    /*GoogleSignIn? googleSignIn*/
  }) : _firebaseAuth = firebaseAuth ?? fir_auth.FirebaseAuth.instance;
  // _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  final fir_auth.FirebaseAuth _firebaseAuth;
  // final GoogleSignIn _googleSignIn;

  Stream<User> get userFir => _firebaseAuth.authStateChanges().map(
        (firUser) {
          if (firUser == null) {
            return User.empty;
          } else {
            return firUser.toUser;
          }
        },
      );

  Future<User?> getUserFromDB(String documentId) {
    return fir_store.FirebaseFirestore.instance
        .collection('users')
        .doc(documentId)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        return User(
          documentId: snapshot.id,
          data: snapshot.data(),
        );
      }
      return null;
    });
  }

  Future<List<Alumno>> getAlumnos() {
    print('entra aqui??');
    try {
      return fir_store.FirebaseFirestore.instance
          .collection('alumnos')
          .get()
          .then((snapshot) {
        print('snapshot:$snapshot');
        return snapshot.docs
            .map((e) => Alumno(documentId: e.id, data: e.data()))
            .toList();
      });
    } catch (e) {
      print(e);
      return Future.value([]);
    }
  }

  Stream<User> userData(User firUser) => fir_store.FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: firUser.email)
          .limit(1)
          .snapshots()
          .map(
        (data) {
          if (data.docs.isNotEmpty) {
            User user = User(
              documentId: data.docs[0].id,
              data: data.docs[0].data(),
            );
            return user;
          } else {
            return firUser;
          }
        },
      );

  Future<void> sendPasswordResetWithEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(
      email: email,
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Future<void> signInWithGoogle() async {
  //   final googleUser = await _googleSignIn.signIn();
  //   final googleAuth = await googleUser!.authentication;
  //   final credential = firAuth.GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
  //   await _firebaseAuth.signInWithCredential(credential);
  // }

  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      // _googleSignIn.signOut(),
    ]);
  }
}

extension on fir_auth.User {
  User get toUser {
    // ignore: prefer_const_literals_to_create_immutables
    User user = User(data: {}, documentId: uid);
    user.email = email ?? '';
    user.displayName = displayName ?? '';
    user.photoURL = photoURL ?? '';
    return user;
  }
}
