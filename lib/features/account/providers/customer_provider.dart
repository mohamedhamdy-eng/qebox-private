import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer.dart';

class CustomerState {
  final Customer? customer;

  // مؤقتًا:
  // الحسابات دي محفوظة أثناء تشغيل التطبيق فقط.
  // بعدين الـBackend / Firebase هيكون هو مصدر الحسابات الحقيقي.
  final Map<String, Customer> registeredCustomers;

  const CustomerState({
    this.customer,
    this.registeredCustomers = const {},
  });

  // =====================================================
  // AUTH STATUS
  // =====================================================

  bool get isLoggedIn => customer != null;

  bool get isGuest => customer == null;

  // =====================================================
  // CUSTOMER LOOKUP
  // =====================================================

  bool isPhoneRegistered(String phone) {
    final normalizedPhone = phone.trim();

    return registeredCustomers.containsKey(
      normalizedPhone,
    );
  }

  Customer? getCustomerByPhone(String phone) {
    final normalizedPhone = phone.trim();

    return registeredCustomers[
        normalizedPhone];
  }

  // =====================================================
  // COPY
  // =====================================================

  CustomerState copyWith({
    Customer? customer,
    Map<String, Customer>? registeredCustomers,
    bool clearCustomer = false,
  }) {
    return CustomerState(
      customer:
          clearCustomer
              ? null
              : customer ?? this.customer,
      registeredCustomers:
          registeredCustomers ??
              this.registeredCustomers,
    );
  }
}

class CustomerNotifier
    extends StateNotifier<CustomerState> {
  CustomerNotifier()
      : super(
          const CustomerState(),
        );

  // =====================================================
  // SET CUSTOMER
  //
  // بنسيبها لأن في أجزاء حالية في المشروع
  // بتستخدمها بالفعل.
  // =====================================================

  void setCustomer(Customer customer) {
    final updatedCustomers =
        Map<String, Customer>.from(
      state.registeredCustomers,
    );

    updatedCustomers[customer.phone.trim()] =
        customer;

    state = CustomerState(
      customer: customer,
      registeredCustomers:
          updatedCustomers,
    );
  }

  // =====================================================
  // SIGN UP
  //
  // يرجع null لو الرقم مسجل بالفعل.
  // =====================================================

  Customer? signUp({
    required String name,
    required String phone,
  }) {
    final normalizedName = name.trim();
    final normalizedPhone = phone.trim();

    if (state.isPhoneRegistered(
      normalizedPhone,
    )) {
      return null;
    }

    final customer = Customer(
      id:
          'CUST-${DateTime.now().millisecondsSinceEpoch}',
      name: normalizedName,
      phone: normalizedPhone,
    );

    final updatedCustomers =
        Map<String, Customer>.from(
      state.registeredCustomers,
    );

    updatedCustomers[normalizedPhone] =
        customer;

    state = CustomerState(
      customer: customer,
      registeredCustomers:
          updatedCustomers,
    );

    return customer;
  }

  // =====================================================
  // SIGN IN
  //
  // يرجع null لو مفيش حساب بالرقم ده.
  // =====================================================

  Customer? signIn({
    required String phone,
  }) {
    final normalizedPhone = phone.trim();

    final existingCustomer =
        state.getCustomerByPhone(
      normalizedPhone,
    );

    if (existingCustomer == null) {
      return null;
    }

    state = CustomerState(
      customer: existingCustomer,
      registeredCustomers:
          state.registeredCustomers,
    );

    return existingCustomer;
  }

  // =====================================================
  // CHECK PHONE
  // =====================================================

  bool isPhoneRegistered(
    String phone,
  ) {
    return state.isPhoneRegistered(
      phone,
    );
  }

  // =====================================================
  // UPDATE CUSTOMER NAME
  // =====================================================

  void updateName(String name) {
    final currentCustomer =
        state.customer;

    if (currentCustomer == null) {
      return;
    }

    final updatedCustomer =
        currentCustomer.copyWith(
      name: name.trim(),
    );

    final updatedCustomers =
        Map<String, Customer>.from(
      state.registeredCustomers,
    );

    updatedCustomers[
            updatedCustomer.phone] =
        updatedCustomer;

    state = CustomerState(
      customer: updatedCustomer,
      registeredCustomers:
          updatedCustomers,
    );
  }

  // =====================================================
  // UPDATE CUSTOMER PHONE
  // =====================================================

  void updatePhone(String phone) {
    final currentCustomer =
        state.customer;

    if (currentCustomer == null) {
      return;
    }

    final oldPhone =
        currentCustomer.phone.trim();

    final newPhone = phone.trim();

    final updatedCustomer =
        currentCustomer.copyWith(
      phone: newPhone,
    );

    final updatedCustomers =
        Map<String, Customer>.from(
      state.registeredCustomers,
    );

    updatedCustomers.remove(
      oldPhone,
    );

    updatedCustomers[newPhone] =
        updatedCustomer;

    state = CustomerState(
      customer: updatedCustomer,
      registeredCustomers:
          updatedCustomers,
    );
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  void logout() {
    // بنخرج العميل من الحساب
    // لكن بنحتفظ بالحسابات مؤقتًا أثناء تشغيل التطبيق
    // عشان نقدر نجرب Sign In مرة أخرى.

    state = CustomerState(
      registeredCustomers:
          state.registeredCustomers,
    );
  }
}

final customerProvider =
    StateNotifierProvider<
        CustomerNotifier,
        CustomerState>(
  (ref) {
    return CustomerNotifier();
  },
);