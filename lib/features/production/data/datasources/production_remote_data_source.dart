import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:golds_nuts/features/production/data/models/production_model.dart';

class ProductionRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions firebaseFunctions;

  ProductionRemoteDataSource({
    required this.firestore,
    required this.firebaseFunctions,
  });

  Future<String> addProduction({required ProductionModel production}) async {
    final callable = firebaseFunctions.httpsCallable('createProductionRecord');

    final result = await callable.call({
      'workerId': production.workerId,
      'date': production.date.toIso8601String(),
      'items': production.items.map((item) {
        return {'productId': item.productId, 'quantity': item.quantity};
      }).toList(),
    });

    final data = Map<String, dynamic>.from(result.data);

    return data['productionId'] as String;
  }

  Future<List<ProductionModel>> getMonthlyProductions({
    required DateTime month,
    String? workerId,
  }) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final startOfNextMonth = DateTime(month.year, month.month + 1, 1);

    Query<Map<String, dynamic>> query = firestore
        .collection('production_records')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThan: Timestamp.fromDate(startOfNextMonth));

    if (workerId != null) {
      query = query.where('workerId', isEqualTo: workerId);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      return ProductionModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Stream<List<ProductionModel>> watchMonthlyProductions({
    required DateTime month,
    String? workerId,
  }) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final startOfNextMonth = DateTime(month.year, month.month + 1, 1);

    Query<Map<String, dynamic>> query = firestore
        .collection('production_records')
        .where(
      'date',
      isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
    )
        .where(
      'date',
      isLessThan: Timestamp.fromDate(startOfNextMonth),
    );

    if (workerId != null) {
      query = query.where('workerId', isEqualTo: workerId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductionModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }



}
