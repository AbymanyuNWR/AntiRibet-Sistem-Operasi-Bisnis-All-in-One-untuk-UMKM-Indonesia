import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// --- Events ---
abstract class PosCartEvent extends Equatable {
  const PosCartEvent();
  @override
  List<Object> get props => [];
}

class AddProductToCart extends PosCartEvent {
  final Map<String, dynamic> product;
  const AddProductToCart(this.product);
  @override
  List<Object> get props => [product];
}

class RemoveProductFromCart extends PosCartEvent {
  final int productId;
  const RemoveProductFromCart(this.productId);
  @override
  List<Object> get props => [productId];
}

class ClearCart extends PosCartEvent {}

// --- State ---
class PosCartState extends Equatable {
  final List<Map<String, dynamic>> items;
  final double total;

  const PosCartState({this.items = const [], this.total = 0});

  PosCartState copyWith({List<Map<String, dynamic>>? items, double? total}) {
    return PosCartState(
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }

  @override
  List<Object> get props => [items, total];
}

// --- BLoC ---
class PosCartBloc extends Bloc<PosCartEvent, PosCartState> {
  PosCartBloc() : super(const PosCartState()) {
    on<AddProductToCart>((event, emit) {
      final updatedItems = List<Map<String, dynamic>>.from(state.items);
      // Logic sederhana: cek apakah barang sudah ada
      final existingIndex = updatedItems.indexWhere((i) => i['id'] == event.product['id']);
      if (existingIndex >= 0) {
        updatedItems[existingIndex]['qty'] += 1;
      } else {
        updatedItems.add({...event.product, 'qty': 1});
      }
      
      final newTotal = _calculateTotal(updatedItems);
      emit(state.copyWith(items: updatedItems, total: newTotal));
    });

    on<RemoveProductFromCart>((event, emit) {
      final updatedItems = List<Map<String, dynamic>>.from(state.items)..removeWhere((i) => i['id'] == event.productId);
      emit(state.copyWith(items: updatedItems, total: _calculateTotal(updatedItems)));
    });

    on<ClearCart>((event, emit) {
      emit(const PosCartState(items: [], total: 0));
    });
  }

  double _calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(0, (sum, item) => sum + (item['price'] * item['qty']));
  }
}
