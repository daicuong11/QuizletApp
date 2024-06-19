import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quizletapp/models/user.dart';

class FirebaseAuthService {
  // Khai báo một static biến private để lưu trữ thể hiện duy nhất của lớp FirebaseAuthService
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();

  // Thuộc tính private để lưu trữ tham chiếu đến FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //đăng nhập với GG
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

  // khởi tạo đối tượng từ firebase firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm factory để trả về thể hiện duy nhất của lớp FirebaseAuthService
  factory FirebaseAuthService() {
    return _instance;
  }

  bool isSignInGG = false;
  // Constructor private
  FirebaseAuthService._internal();

  // Phương thức để đăng nhập bằng email và mật khẩu
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      isSignInGG = false;
      return userCredential;
    } catch (error) {
      print('Error signing in: $error');
      rethrow;
    }
  }

  // Phương thức để đăng ký một tài khoản mới bằng email và mật khẩu
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!
          .updateDisplayName(UserModel.createUsernameFromEmail(email));

      return userCredential;
    } catch (error) {
      print('Error signing up: $error');
      rethrow;
    }
  }

  // đăng nhập bằng google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await googleSignIn.signInSilently();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);

      isSignInGG = true;
      return authResult;
    } catch (error) {
      print('Error signing in with Google: $error');
      return null;
    }
  }

  getIsSignInGG() {
    return isSignInGG;
  }

  // Hàm kiểm tra mật khẩu trước khi thay đổi email
  Future<bool> checkPassword(String password) async {
    try {
      // Lấy thông tin người dùng hiện tại
      User? user = getCurrentUser();

      // Xác thực mật khẩu của người dùng hiện tại
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Nếu xác thực thành công, trả về true
      return true;
    } catch (e) {
      // Xử lý lỗi và trả về false nếu mật khẩu không đúng
      print('Lỗi khi xác thực mật khẩu: $e');
      return false;
    }
  }

  // Hàm đổi mật khẩu
  Future<String> changePassword(
      String currentPassword, String newPassword) async {
    try {
      // Lấy thông tin người dùng hiện tại
      User? user = getCurrentUser();

      // Xác thực mật khẩu hiện tại của người dùng
      final AuthCredential credential = EmailAuthProvider.credential(
          email: user!.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);

      // Nếu xác thực thành công, thực hiện quá trình đổi mật khẩu
      await user.updatePassword(newPassword);
      return '';
    } catch (e) {
      // Xử lý các lỗi
      print("Đổi mật khẩu thất bại: $e");
      return "Mật khẩu của bạn không đúng. Vui lòng thử lại!";
    }
  }

  // Phương thức để lấy thông tin người dùng hiện tại
  User? getCurrentUser() {
    try {
      return _auth.currentUser;
    } catch (error) {
      print('Error getting current user: $error');
      rethrow;
    }
  }

  // Phương thức để kiểm tra xem người dùng đã đăng nhập hay chưa
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Phương thức để đăng xuất người dùng
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      print('Error signing out: $error');
      rethrow;
    }
  }

// Hàm để xóa tài khoản người dùng từ Firebase Authentication bằng email
  Future<void> deleteAccount() async {
    try {
      // Lấy thông tin người dùng đã xác thực
      User? user = getCurrentUser();
      // Xóa tài khoản người dùng
      await user!.delete();
    } catch (error) {
      // Xử lý lỗi nếu có
      print('Lỗi xóa tài khoản: $error');
    }
  }

  // Hàm để thay đổi email của người dùng
  Future<String> changeEmail(String newEmail) async {
    try {
      // Lấy thông tin người dùng đã xác thực
      User? user = getCurrentUser();
      // Gửi email xác minh mới đến địa chỉ email mới
      await user!.verifyBeforeUpdateEmail(newEmail);

      return '';
    } catch (error) {
      // Xử lý lỗi nếu có
      print('Lỗi thay đổi email: $error');
      return "Lỗi thay đổi email";
    }
  }

  // Hàm để thay đổi displayName của người dùng
  Future<String> changeUserName(String newUserName) async {
    try {
      // Lấy thông tin người dùng đã xác thực
      User? user = getCurrentUser();
      // Gửi email xác minh mới đến địa chỉ email mới
      await user!.updateDisplayName(newUserName);

      // In ra thông báo khi thay đổi email thành công
      return '';
    } catch (error) {
      // Xử lý lỗi nếu có
      print('Lỗi thay đổi username: $error');
      return "Lỗi thay đổi username";
    }
  }

  // Hàm để gửi email đặt lại mật khẩu
  Future<bool> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (error) {
      print('Lỗi khi gửi email đặt lại mật khẩu: $error');
      return false;
    }
  }

}
