import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

enum UserRole { student, lecturer, admin }

class AppUser {
  final String dbId;   // Firestore document ID
  final String uid;    // Firebase Auth UID
  final String email;
  final String name;
  final UserRole role;

  const AppUser({
    required this.dbId,
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });
}

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '538559006995-nn1d7e2moo2l7un5t3j6ubifkbnd14do.apps.googleusercontent.com'
        : null,
  );
  final _api = ApiService();

  AppUser? currentAppUser;

  User? get currentUser => _auth.currentUser;

  static bool get supportsGoogle =>
      kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  static UserRole _roleFor(String email) {
    final emailLower = email.toLowerCase();
    if (emailLower.contains('admin')) return UserRole.admin;
    if (emailLower.contains('lecturer')) return UserRole.lecturer;
    return UserRole.student;
  }

  // Fetch or create the DB user profile after Firebase Auth login
  Future<AppUser> _loadOrCreateDbUser(User firebaseUser) async {
    try {
      // Intentar obtener el usuario del backend
      final result = await _api.getUser(firebaseUser.uid);
      final u = result['user'];

      UserRole role = UserRole.student;
      if (u['role'] == 'admin') {
        role = UserRole.admin;
      } else if (u['role'] == 'lecturer') {
        role = UserRole.lecturer;
      }

      return AppUser(
        dbId: u['id'] ?? firebaseUser.uid,
        uid: u['uid'],
        email: u['email'],
        name: u['name'],
        role: role,
      );
    } catch (e) {
      // Usuario no existe en el backend — crear
      final role = _roleFor(firebaseUser.email ?? '');
      String roleStr = 'student';
      if (role == UserRole.admin) {
        roleStr = 'admin';
      } else if (role == UserRole.lecturer) {
        roleStr = 'lecturer';
      }

      await _api.createUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? firebaseUser.email ?? 'User',
        role: roleStr,
      );

      // Obtener el usuario recién creado
      final created = await _api.getUser(firebaseUser.uid);
      final u = created['user'];

      return AppUser(
        dbId: u['id'] ?? firebaseUser.uid,
        uid: u['uid'],
        email: u['email'],
        name: u['name'],
        role: role,
      );
    }
  }

  Future<AppUser> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    currentAppUser = await _loadOrCreateDbUser(cred.user!);
    return currentAppUser!;
  }

  Future<AppUser> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    currentAppUser = await _loadOrCreateDbUser(cred.user!);
    return currentAppUser!;
  }

  Future<AppUser> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    currentAppUser = await _loadOrCreateDbUser(cred.user!);
    return currentAppUser!;
  }

  Future<void> signOut() async {
    currentAppUser = null;
    if (supportsGoogle) await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
