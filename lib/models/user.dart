class UserModel {
  String id;
  String userId;
  String username;
  String email;

  UserModel(this.id, this.userId, this.email, this.username);

  static List<UserModel> fromListMap(List<Map<String, dynamic>> listMap) {
    return listMap.map((map) => UserModel.fromMap(map)).toList();
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      map['id'],
      map['userId'],
      map['email'],
      map['username'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'email': email,
      'username': username,
    };
  }

  static List<Map<String, dynamic>> toListMap(List<UserModel> users) {
    return users.map((user) => user.toMap()).toList();
  }

  static String createUsernameFromEmail(String email) {
    return email.split('@')[0];
  }

  // Phương thức để hiển thị thông tin của đối tượng dưới dạng chuỗi
  @override
  String toString() {
    return 'UserModel{id: $id, userId: $userId, email: $email, username: $username}';
  }
}
