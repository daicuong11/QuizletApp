import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // Khai báo một static biến private để lưu trữ thể hiện duy nhất của lớp FirebaseService
  static final FirebaseService _instance = FirebaseService._internal();

  // Thuộc tính private để lưu trữ tham chiếu đến Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm factory để trả về thể hiện duy nhất của lớp FirebaseService
  factory FirebaseService() {
    return _instance;
  }

  // Constructor private
  FirebaseService._internal();

  // Phương thức để thêm một tài liệu vào Firestore
  Future<String> addDocument(
      String collectionName, Map<String, dynamic> data) async {
    try {
      // Thêm tài liệu vào Firestore và lưu trữ DocumentReference
      DocumentReference docRef =
          await _firestore.collection(collectionName).add(data);

      // Lấy id của tài liệu mới được thêm vào
      String docId = docRef.id;

      // Thêm id vào dữ liệu trước khi lưu vào Firestore
      Map<String, dynamic> newData = {...data, 'id': docId};

      // Lưu dữ liệu mới vào Firestore với trường id đã được thêm vào
      await docRef.update(newData);
      return docId;
    } catch (error) {
      print('Error adding document: $error');
      throw error;
    }
  }

  // Phương thức để cập nhật một tài liệu trong Firestore
  Future<void> updateDocument(String collectionName, String documentId,
      Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).update(data);
    } catch (error) {
      print('Error updating document: $error');
      throw error;
    }
  }

  // Phương thức để xóa một tài liệu từ Firestore
  Future<void> deleteDocument(String collectionName, String documentId) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).delete();
    } catch (error) {
      print('Error deleting document: $error');
      throw error;
    }
  }

  // Phương thức để lấy danh sách tài liệu từ một bộ sưu tập trong Firestore
  Future<List<Map<String, dynamic>>> getDocuments(String collectionName) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionName).get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (error) {
      print('Error getting documents: $error');
      throw error;
    }
  }

  // Phương thức để lấy một tài liệu cụ thể từ Firestore
  Future<Map<String, dynamic>> getDocument(
      String collectionName, String documentId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection(collectionName).doc(documentId).get();
      return documentSnapshot.data() as Map<String, dynamic>;
    } catch (error) {
      print('Error getting document: $error');
      throw error;
    }
  }

  // Phương thức để lấy tài liệu từ Firestore dựa trên một trường cụ thể
  Future<List<Map<String, dynamic>>> getDocumentsByField(
      String collectionName, String fieldName, dynamic value) async {
    try {
      // Thực hiện truy vấn để lấy tài liệu có trường fieldName có giá trị là value
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionName)
          .where(fieldName, isEqualTo: value)
          .get();

      // Chuyển đổi kết quả truy vấn thành danh sách các Map<String, dynamic>
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (error) {
      print('Error getting documents by field: $error');
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> getDocumentsByDocumentIds(
      String collectionName, List<String> documentIds) async {
    if (documentIds.isEmpty) {
      return [];
    }
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where(FieldPath.documentId, whereIn: documentIds)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting documents by documentIds: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getDocumentsByFields(
      String collectionName, Map<String, dynamic> fieldValues) async {
    try {
      Query query = _firestore.collection(collectionName);
      fieldValues.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });
      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (error) {
      print('Error getting documents by fields: $error');
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> searchByField(
      String collection, String field, String query) async {
    final firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot snapshot = await firestore
          .collection(collection)
          .where(field, isGreaterThanOrEqualTo: query)
          .where(field, isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      List<Map<String, dynamic>> results = snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      return results;
    } catch (e) {
      print('Error searching by field: $e');
      return [];
    }
  }
}
