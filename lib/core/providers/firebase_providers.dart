import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final realtimeDatabaseProvider = Provider((ref) => FirebaseDatabase.instance);
final authProvider = Provider((ref) => FirebaseAuth.instance);
