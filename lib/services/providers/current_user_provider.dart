import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:quizletapp/models/user.dart';
import 'package:quizletapp/services/firebase.dart';
import 'package:quizletapp/services/firebase_auth.dart';
import 'package:quizletapp/services/models_services/user_service.dart';

class CurrentUserProvider extends ChangeNotifier {
  FirebaseAuthService firebaseAuthService = FirebaseAuthService();
  FirebaseService firebaseService = FirebaseService();
  UserService userService = UserService();
  UserModel? _currentUser;

  CurrentUserProvider() {
    initCurrentUser();
  }

  UserModel? get currentUser => _currentUser;

  set setCurrentUser(UserModel? newCurrentUser) {
    _currentUser = newCurrentUser;
    notifyListeners();
  }

  Future<void> initCurrentUser() async {
    if (firebaseAuthService.getCurrentUser() == null) {
      _currentUser = null;
    } else {
      _currentUser = await userService
          .getUserByUid(firebaseAuthService.getCurrentUser()!.uid);
    }
    notifyListeners();
  }

  Future<void> changeUserName(String newUserName) async {
    try {
      currentUser!.username = newUserName;
      await firebaseService.updateDocument(
          'users', currentUser!.id, currentUser!.toMap());
      notifyListeners();
    } catch (e) {
      print('UserService: lỗi update user: $e');
    }
  }

  bool get isNotEmpty => _currentUser != null;
}
