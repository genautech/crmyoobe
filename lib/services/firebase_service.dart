import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Serviço centralizado para operações Firebase Firestore
class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Verifica se o Firebase está disponível
  static bool get isAvailable {
    try {
      // Tenta acessar o Firestore
      _firestore.settings;
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Firebase não disponível: $e');
      }
      return false;
    }
  }

  /// Obtém referência para uma coleção
  static CollectionReference collection(String collectionName) {
    return _firestore.collection(collectionName);
  }

  /// Obtém todos os documentos de uma coleção
  static Future<List<Map<String, dynamic>>> getAll(String collectionName) async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao buscar $collectionName: $e');
      }
      return [];
    }
  }

  /// Obtém um documento específico
  static Future<Map<String, dynamic>?> getOne(
      String collectionName, String docId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(docId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao buscar documento $docId: $e');
      }
      return null;
    }
  }

  /// Adiciona um novo documento
  static Future<String?> add(
      String collectionName, Map<String, dynamic> data) async {
    try {
      // Adiciona timestamp de criação
      data['created_at'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore.collection(collectionName).add(data);
      if (kDebugMode) {
        debugPrint('✅ Documento criado em $collectionName: ${docRef.id}');
      }
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao adicionar em $collectionName: $e');
      }
      return null;
    }
  }

  /// Atualiza um documento existente
  static Future<bool> update(
      String collectionName, String docId, Map<String, dynamic> data) async {
    try {
      // Adiciona timestamp de atualização
      data['updated_at'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(collectionName).doc(docId).update(data);
      if (kDebugMode) {
        debugPrint('✅ Documento atualizado em $collectionName: $docId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao atualizar $docId em $collectionName: $e');
      }
      return false;
    }
  }

  /// Define (cria ou substitui) um documento
  static Future<bool> set(
      String collectionName, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).doc(docId).set(data);
      if (kDebugMode) {
        debugPrint('✅ Documento definido em $collectionName: $docId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao definir $docId em $collectionName: $e');
      }
      return false;
    }
  }

  /// Deleta um documento
  static Future<bool> delete(String collectionName, String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
      if (kDebugMode) {
        debugPrint('✅ Documento deletado de $collectionName: $docId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao deletar $docId de $collectionName: $e');
      }
      return false;
    }
  }

  /// Escuta mudanças em uma coleção em tempo real
  static Stream<List<Map<String, dynamic>>> watchCollection(
      String collectionName) {
    return _firestore.collection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Escuta mudanças em um documento específico
  static Stream<Map<String, dynamic>?> watchDocument(
      String collectionName, String docId) {
    return _firestore
        .collection(collectionName)
        .doc(docId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        data['id'] = snapshot.id;
        return data;
      }
      return null;
    });
  }

  /// Query com filtro
  static Future<List<Map<String, dynamic>>> query(
    String collectionName, {
    String? field,
    dynamic isEqualTo,
    dynamic isGreaterThan,
    dynamic isLessThan,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);

      if (field != null && isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      if (field != null && isGreaterThan != null) {
        query = query.where(field, isGreaterThan: isGreaterThan);
      }
      if (field != null && isLessThan != null) {
        query = query.where(field, isLessThan: isLessThan);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro na query de $collectionName: $e');
      }
      return [];
    }
  }

  /// Batch write (várias operações atômicas)
  static Future<bool> batchWrite(
      List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();

      for (final op in operations) {
        final type = op['type'] as String;
        final collection = op['collection'] as String;
        final data = op['data'] as Map<String, dynamic>;

        switch (type) {
          case 'add':
            final docRef = _firestore.collection(collection).doc();
            batch.set(docRef, data);
            break;
          case 'update':
            final docId = op['docId'] as String;
            final docRef = _firestore.collection(collection).doc(docId);
            batch.update(docRef, data);
            break;
          case 'delete':
            final docId = op['docId'] as String;
            final docRef = _firestore.collection(collection).doc(docId);
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
      if (kDebugMode) {
        debugPrint('✅ Batch de ${operations.length} operações executado');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro no batch write: $e');
      }
      return false;
    }
  }
}
