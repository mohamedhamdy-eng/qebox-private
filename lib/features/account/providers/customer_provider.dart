import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer.dart';

class CustomerState {
  final Customer? customer;

  const CustomerState({
    this.customer,
  });

  bool get isLoggedIn => customer != null;

  CustomerState copyWith({
    Customer? customer,
    bool clearCustomer = false,
  }) {
    return CustomerState(
      customer: clearCustomer ? null : customer ?? this.customer,
    );
  }
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  CustomerNotifier() : super(const CustomerState());

  // =====================================================
  // LOGIN / SET CUSTOMER
  // =====================================================

  void setCustomer(Customer customer) {
    state = CustomerState(
      customer: customer,
    );
  }

  // =====================================================
  // UPDATE CUSTOMER NAME
  // =====================================================

  void updateName(String name) {
    final currentCustomer = state.customer;

    if (currentCustomer == null) {
      return;
    }

    state = CustomerState(
      customer: currentCustomer.copyWith(
        name: name,
      ),
    );
  }

  // =====================================================
  // UPDATE CUSTOMER PHONE
  // =====================================================

  void updatePhone(String phone) {
    final currentCustomer = state.customer;

    if (currentCustomer == null) {
      return;
    }

    state = CustomerState(
      customer: currentCustomer.copyWith(
        phone: phone,
      ),
    );
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  void logout() {
    state = const CustomerState();
  }
}

final customerProvider =
    StateNotifierProvider<CustomerNotifier, CustomerState>(
  (ref) {
    return CustomerNotifier();
  },
);