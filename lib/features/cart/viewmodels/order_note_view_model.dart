import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderNoteViewModel extends StateNotifier<String> {
  OrderNoteViewModel() : super('');

  void updateNote(String note) => state = note;

  void clear() => state = '';
}

final orderNoteProvider = StateNotifierProvider<OrderNoteViewModel, String>(
  (ref) => OrderNoteViewModel(),
);
