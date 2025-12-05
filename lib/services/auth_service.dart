import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current Google user (for API calls)
  GoogleSignInAccount? get currentGoogleUser => _googleSignIn.currentUser;

  // Request Calendar Permission
  Future<bool> requestCalendarPermission() async {
    try {
      // Ensure user is signed in to Google
      if (_googleSignIn.currentUser == null) {
        await _googleSignIn.signInSilently();
      }
      
      if (_googleSignIn.currentUser == null) {
        await _googleSignIn.signIn();
      }

      if (_googleSignIn.currentUser == null) {
        return false;
      }

      final result = await _googleSignIn.requestScopes([calendar.CalendarApi.calendarReadonlyScope]);
      return result;
    } catch (e) {
      print("Error requesting calendar permission: $e");
      return false;
    }
  }

  // Try silent sign-in (for auto-connect)
  Future<bool> trySilentSignIn() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        // Check if we already have the scope?
        // google_sign_in doesn't easily let us check granted scopes without requesting.
        // But requesting them if already granted is silent.
        // However, we don't want to trigger a popup.
        // We'll assume if we can sign in silently, we can try to fetch.
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null; // The user canceled the sign-in

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error signing in with Google: $e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
