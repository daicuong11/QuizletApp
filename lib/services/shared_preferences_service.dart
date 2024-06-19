import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();

  factory SharedPreferencesService() {
    return _instance;
  }

  SharedPreferencesService._internal();

  // Key để lưu trữ UID của người dùng
  static const String _uidKey = 'uid';

  // Phương thức để lấy SharedPreferences instance
  Future<SharedPreferences> getSharedPreferencesInstance() async {
    return await SharedPreferences.getInstance();
  }

  // Lưu UID vào SharedPreferences
  Future<void> saveUID(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uidKey, uid);
  }

  // Lấy UID từ SharedPreferences
  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uidKey);
  }

  // Xóa UID khỏi SharedPreferences
  Future<void> removeUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_uidKey);
  }

}
