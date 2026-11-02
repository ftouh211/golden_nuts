
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golds_nuts/features/production/data/models/production_model.dart';

class ProductionRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductionRemoteDataSource({
    required this.firestore,
  });

  Future<String> addProduction({
    required ProductionModel production,
  }) async {
    final productionData = production.toMap();

    // Firestore server timestamp
    productionData['createdAt'] = FieldValue.serverTimestamp();

    final document = await firestore
        .collection('production_records')
        .add(productionData);

    return document.id;
  }


  Future<List<ProductionModel>> getMonthlyProductions({
    required DateTime month,
    String? workerId,
  }) async {
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

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      return ProductionModel.fromMap(doc.id, doc.data());
    }).toList();
  }

}
