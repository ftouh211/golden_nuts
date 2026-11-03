import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golds_nuts/features/product/data/models/product_model.dart';

class ProductRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductRemoteDataSource({required this.firestore});

  // Get Products
  Future<List<ProductModel>> getProducts({bool activeOnly = false}) async {
    Query<Map<String, dynamic>> query = firestore.collection('products');

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  // // Add Product
  // Future<void> addProduct({
  //   required String name,
  //   required double pricePerCarton,
  // }) async {
  //   await firestore.collection('products').add({
  //     'name': name,
  //     'pricePerCarton': pricePerCarton,
  //     'isActive': true,
  //     'createdAt': FieldValue.serverTimestamp(),
  //   });
  // }

  // Add Product + Initialize Inventory Balance
  Future<void> addProduct({
    required String name,
    required double pricePerCarton,
  }) async {
    if (name.trim().isEmpty || pricePerCarton < 0) {
      throw ArgumentError('Invalid product name or price.');
    }

    // Generate product reference first
    final productRef = firestore.collection('products').doc();

    // Inventory document uses the same product ID
    final inventoryRef = firestore
        .collection('inventory_balances')
        .doc(productRef.id);

    // Create both documents atomically
    final batch = firestore.batch();

    batch.set(productRef, {
      'name': name.trim(),
      'pricePerCarton': pricePerCarton,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(inventoryRef, {
      'productId': productRef.id,
      'productName': name.trim(),
      'totalProduced': 0,
      'totalOutgoing': 0,
      'availableQuantity': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Update Product
  Future<void> updateProduct({
    required String productId,
    required String name,
    required double pricePerCarton,
  }) async {
    await firestore.collection('products').doc(productId).update({
      'name': name,
      'pricePerCarton': pricePerCarton,
    });
  }

  // Deactivate Product
  Future<void> deactivateProduct(String productId) async {
    await firestore.collection('products').doc(productId).update({
      'isActive': false,
    });
  }

  // Activate Product
  Future<void> activateProduct(String productId) async {
    await firestore.collection('products').doc(productId).update({
      'isActive': true,
    });
  }

  // Delete Product
  Future<void> deleteProduct(String productId) async {
    await firestore.collection('products').doc(productId).delete();
  }
}
