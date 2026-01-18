import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class AvailableRidesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obter corridas disponíveis próximas ao motorista (stream em tempo real)
  Stream<List<Map<String, dynamic>>> getAvailableRidesStream(double driverLat, double driverLng, {double radiusKm = 5.0}) {
    return _firestore
        .collection('rides')
        .where('status', isEqualTo: 'pending')
        .where('driverId', isNull: true)
        .snapshots()
        .map((snapshot) {
      final rides = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final rideData = doc.data();
        final destinationLat = rideData['destinationLat'] as double?;
        final destinationLng = rideData['destinationLng'] as double?;

        if (destinationLat != null && destinationLng != null) {
          // Calcular distância entre motorista e origem da corrida
          final distance = _calculateDistance(
            driverLat,
            driverLng,
            rideData['originLat'] as double? ?? 0,
            rideData['originLng'] as double? ?? 0,
          );

          // Filtrar apenas corridas dentro do raio
          if (distance <= radiusKm) {
            rides.add({
              ...rideData,
              'id': doc.id,
              'distance': distance, // Distância do motorista até a origem
            });
          }
        }
      }

      // Ordenar por distância (mais perto primeiro)
      rides.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      return rides;
    });
  }

  /// Aceitar uma corrida específica
  Future<void> acceptRide(String rideId, double driverLat, double driverLng) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    try {
      await _firestore.collection('rides').doc(rideId).update({
        'driverId': userId,
        'status': 'assigned',
        'updatedAt': DateTime.now(),
        'driverAcceptedAt': DateTime.now(),
        'driverLatAtAcceptance': driverLat,
        'driverLngAtAcceptance': driverLng,
      });

      // Atualizar contador de corridas do motorista
      await _firestore.collection('drivers').doc(userId).update({
        'totalRides': FieldValue.increment(1),
        'lastRideAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Erro ao aceitar corrida: $e');
    }
  }

  /// Obter corrida ativa do motorista
  Stream<Map<String, dynamic>?> getActiveRideStream(String driverId) {
    return _firestore
        .collection('rides')
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: ['assigned', 'in_progress'])
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return {
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      };
    });
  }

  /// Atualizar status da corrida
  Future<void> updateRideStatus(String rideId, String newStatus) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': newStatus,
        'updatedAt': DateTime.now(),
        if (newStatus == 'in_progress') 'startedAt': DateTime.now(),
        if (newStatus == 'completed') 'completedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar status da corrida: $e');
    }
  }

  /// Atualizar localização do motorista durante a corrida
  Future<void> updateDriverLocation(String driverId, double latitude, double longitude) async {
    try {
      await _firestore.collection('drivers').doc(driverId).update({
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar localização: $e');
    }
  }

  /// Recusar uma corrida (para futuro uso)
  Future<void> declineRide(String rideId) async {
    try {
      // Por enquanto, apenas não fazer nada
      // Futuramente: registrar recusa, calcular taxa de aceitação, etc.
    } catch (e) {
      throw Exception('Erro ao recusar corrida: $e');
    }
  }

  /// Calcular distância entre dois pontos (Haversine)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }
}
