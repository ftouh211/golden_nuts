
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:golds_nuts/features/product/data/models/product_model.dart';

class ProductRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductRemoteDataSource({
    required this.firestore,
  });

  // Get Products
  Future<List<ProductModel>> getProducts({
    bool activeOnly = false,
  }) async {
    Query<Map<String, dynamic>> query =
    firestore.collection('products');

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  // Add Product
  Future<void> addProduct({
    required String name,
    required double pricePerCarton,
  }) async {
    await firestore.collection('products').add({
      'name': name,
      'pricePerCarton': pricePerCarton,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
