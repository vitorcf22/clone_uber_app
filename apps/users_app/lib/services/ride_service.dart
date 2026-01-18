import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:users_app/models/ride_request.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar nova solicitação de corrida
  Future<String> createRideRequest(RideRequest rideRequest) async {
    try {
      final docRef = await _firestore.collection('rides').add(rideRequest.toMap());
      return docRef.id;
    } catch (e) {
      print('Erro ao criar solicitação de corrida: $e');
      rethrow;
    }
  }

  // Buscar corrida atual do usuário
  Stream<RideRequest?> getUserActiveRideStream(String userId) {
    return _firestore
        .collection('rides')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'assigned', 'in_progress'])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return RideRequest.fromMap(
        snapshot.docs.first.data() as Map<String, dynamic>,
        snapshot.docs.first.id,
      );
    });
  }

  // Buscar corrida específica
  Future<RideRequest?> getRideRequest(String rideId) async {
    try {
      final doc = await _firestore.collection('rides').doc(rideId).get();
      if (doc.exists) {
        return RideRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar corrida: $e');
      return null;
    }
  }

  // Atualizar status da corrida
  Future<void> updateRideStatus(String rideId, String status) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': status,
        if (status == 'in_progress') 'startedAt': DateTime.now(),
        if (status == 'completed') 'completedAt': DateTime.now(),
      });
    } catch (e) {
      print('Erro ao atualizar status da corrida: $e');
      rethrow;
    }
  }

  // Cancelar corrida
  Future<void> cancelRideRequest(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      print('Erro ao cancelar corrida: $e');
      rethrow;
    }
  }

  // Buscar histórico de corridas do usuário
  Future<List<RideRequest>> getUserRideHistory(String userId, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('rides')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => RideRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar histórico de corridas: $e');
      return [];
    }
  }

  // Atualizar localização do motorista na corrida
  Future<void> updateDriverLocation(String rideId, double latitude, double longitude) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'driverLatitude': latitude,
        'driverLongitude': longitude,
      });
    } catch (e) {
      print('Erro ao atualizar localização do motorista: $e');
    }
  }

  // Enviar notificação para o usuário (via Cloud Messaging)
  Future<void> sendNotificationToUser({
    required String userId,
    required String rideId,
    required String type,
    required String title,
    required String body,
  }) async {
    try {
      // Armazenar notificação no Firestore para Cloud Functions processar
      await _firestore
          .collection('notifications')
          .add({
        'userId': userId,
        'rideId': rideId,
        'type': type,
        'title': title,
        'body': body,
        'sent': false,
        'createdAt': DateTime.now(),
      });

      print('Notificação agendada para usuário: $userId');
    } catch (e) {
      print('Erro ao agendar notificação: $e');
    }
  }
}
