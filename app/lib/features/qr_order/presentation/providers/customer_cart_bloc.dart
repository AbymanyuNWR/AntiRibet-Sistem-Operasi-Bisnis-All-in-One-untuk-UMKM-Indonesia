import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// --- Events ---
abstract class CustomerCartEvent extends Equatable {
  const CustomerCartEvent();
  @override
  List<Object> get props => [];
}

class AddItemToCustomerCart extends CustomerCartEvent {
  final Map<String, dynamic> item;
  const AddItemToCustomerCart(this.item);
  @override
  List<Object> get props => [item];
}

class SubmitCustomerOrder extends CustomerCartEvent {
  final String businessSlug;
  final String tableNumber;
  const SubmitCustomerOrder(this.businessSlug, this.tableNumber);
  @override
  List<Object> get props => [businessSlug, tableNumber];
}

// --- State ---
class CustomerCartState extends Equatable {
  final List<Map<String, dynamic>> items;
  final double total;
  final bool isSubmitting;
  final bool isSuccess;

  const CustomerCartState({
    this.items = const [],
    this.total = 0,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  CustomerCartState copyWith({
    List<Map<String, dynamic>>? items,
    double? total,
    bool? isSubmitting,
    bool? isSuccess,
  }) {
    return CustomerCartState(
      items: items ?? this.items,
      total: total ?? this.total,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object> get props => [items, total, isSubmitting, isSuccess];
}

// --- BLoC ---
class CustomerCartBloc extends Bloc<CustomerCartEvent, CustomerCartState> {
  CustomerCartBloc() : super(const CustomerCartState()) {
    on<AddItemToCustomerCart>((event, emit) {
      final updatedItems = List<Map<String, dynamic>>.from(state.items);
      final index = updatedItems.indexWhere((i) => i['id'] == event.item['id']);
      if (index >= 0) {
        updatedItems[index]['qty'] += 1;
      } else {
        updatedItems.add({...event.item, 'qty': 1});
      }
      
      final newTotal = updatedItems.fold(0.0, (sum, i) => sum + (i['price'] * i['qty']));
      emit(state.copyWith(items: updatedItems, total: newTotal));
    });

    on<SubmitCustomerOrder>((event, emit) async {
      emit(state.copyWith(isSubmitting: true));
      
      try {
        // Simulasi POST request ke /api/public/businesses/{slug}/orders
        await Future.delayed(const Duration(seconds: 2));
        
        emit(const CustomerCartState(isSuccess: true));
      } catch (e) {
        emit(state.copyWith(isSubmitting: false));
        // Error handling
      }
    });
  }
}
