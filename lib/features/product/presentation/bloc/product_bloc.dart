import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/features/product/domain/usecases/activate_product_usecase.dart';
import 'package:golds_nuts/features/product/domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/deactivate_product_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeactivateProductUseCase deactivateProductUseCase;
  final ActivateProductUseCase activateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.activateProductUseCase,
    required this.deactivateProductUseCase,
    required this.deleteProductUseCase,
  }) : super(const ProductInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeactivateProductEvent>(_onDeactivateProduct);
    on<ActivateProductEvent>(_onActivateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  // Get Products
  Future<void> _onGetProducts(
    GetProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await getProductsUseCase(activeOnly: event.activeOnly);

    result.fold(
      (failure) => emit(ProductFailure(failure.message)),
      (products) => emit(ProductsLoaded(products: products)),
    );
  }

  // Start an operation without hiding products
  void _startProcessing(Emitter<ProductState> emit) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;

      emit(ProductsLoaded(products: currentState.products, isProcessing: true));
    } else {
      emit(const ProductLoading());
    }
  }

  // Finish operation
  void _finishProcessing(Emitter<ProductState> emit, String message) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;

      emit(
        ProductsLoaded(
          products: currentState.products,
          operationMessage: message,
        ),
      );
    }
  }

  // Add Product
  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    _startProcessing(emit);

    final result = await addProductUseCase(
      name: event.name,
      pricePerCarton: event.pricePerCarton,
    );

    result.fold((failure) {
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        emit(
          ProductsLoaded(
            products: currentState.products,
            operationError: failure.message,
          ),
        );
      } else {
        emit(ProductFailure(failure.message));
      }
    }, (_) => _finishProcessing(emit, 'Product added successfully'));
  }

  // Update Product
  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    _startProcessing(emit);

    final result = await updateProductUseCase(
      productId: event.productId,
      name: event.name,
      pricePerCarton: event.pricePerCarton,
    );

    result.fold((failure) {
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        emit(
          ProductsLoaded(
            products: currentState.products,
            operationError: failure.message,
          ),
        );
      } else {
        emit(ProductFailure(failure.message));
      }
    }, (_) => _finishProcessing(emit, 'Product updated successfully'));
  }

  // Deactivate Product
  Future<void> _onDeactivateProduct(
    DeactivateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    _startProcessing(emit);

    final result = await deactivateProductUseCase(event.productId);

    result.fold((failure) {
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        emit(
          ProductsLoaded(
            products: currentState.products,
            operationError: failure.message,
          ),
        );
      } else {
        emit(ProductFailure(failure.message));
      }
    }, (_) => _finishProcessing(emit, 'Product deactivated successfully'));
  }

  // Activate Product
  Future<void> _onActivateProduct(
    ActivateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    _startProcessing(emit);

    final result = await activateProductUseCase(event.productId);

    result.fold((failure) {
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        emit(
          ProductsLoaded(
            products: currentState.products,
            operationError: failure.message,
          ),
        );
      } else {
        emit(ProductFailure(failure.message));
      }
    }, (_) => _finishProcessing(emit, 'Product activated successfully'));
  }

  // Delete Product (Not enabled in UI yet)
  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    _startProcessing(emit);

    final result = await deleteProductUseCase(event.productId);

    result.fold((failure) {
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        emit(
          ProductsLoaded(
            products: currentState.products,
            operationError: failure.message,
          ),
        );
      } else {
        emit(ProductFailure(failure.message));
      }
    }, (_) => _finishProcessing(emit, 'Product deleted successfully'));
  }
}
