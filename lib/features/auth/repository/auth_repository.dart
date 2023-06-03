import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smarthomeuione/core/constants/constants.dart';
import 'package:smarthomeuione/core/constants/firebase_constants.dart';
import 'package:smarthomeuione/core/failure.dart';
import 'package:smarthomeuione/core/providers/firebase_providers.dart';
import 'package:smarthomeuione/core/type_defs.dart';
import 'package:smarthomeuione/models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _auth = auth,
        _firestore = firestore;

  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
          (event) => UserModel.fromMap(
            event.data() as Map<String, dynamic>,
          ),
        );
  }

  FutureEither<UserModel> signUpWithEmailPass(String email, String pass, String username) async {
    try {
      if (email.isEmpty || pass.isEmpty || username.isEmpty) {
        throw 'Fill in all the boxes';
      } else if (username.length > 30) {
        throw 'Username length cannot exceed 30 characters';
      }
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      final userModel = UserModel(
        name: username,
        profilePic: Constants.avatarDefault,
        uid: userCredential.user!.uid,
        roomIds: [],
      );
      await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        throw 'The account already exists for that email.';
      } else {
        throw 'Unexpected error occured.';
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInWithEmailPass(String email, String pass) async {
    try {
      if (email.isEmpty || pass.isEmpty) {
        throw 'Fill in all the boxes';
      }
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      final userModel = await getUserData(userCredential.user!.uid).first;
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return left(Failure('No user found for that email.'));
      } else if (e.code == 'wrong-password') {
        return left(Failure('Wrong password provided for that user.'));
      } else if (e.code == 'too-many-requests') {
        return left(Failure('Too many request. Try again later.'));
      } else {
        return left(Failure('Unexpected error occured.'));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void logOut() async {
    await _auth.signOut();
  }
}
