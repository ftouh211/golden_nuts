import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_model.dart';

class InventoryRemoteDataSource {
  final FirebaseFirestore firestore;

  InventoryRemoteDataSource({
    required this.firestore,
  });

  Future<List<InventoryModel>> getInventoryBalances() async {
    final snapshot = await firestore
        .collection('inventory_balances')
        .get();

    return snapshot.docs.map((doc) {
      return InventoryModel.fromFirestore(
        doc.data(),
        doc.id,
      );
    }).toList();
  }
}