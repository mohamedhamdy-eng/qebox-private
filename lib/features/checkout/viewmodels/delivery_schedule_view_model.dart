import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliveryTimeSlot {
  final String id;
  final int startHour;
  final int endHour;

  const DeliveryTimeSlot({
    required this.id,
    required this.startHour,
    required this.endHour,
  });

  String get label {
    return '${_formatHour(startHour)} – ${_formatHour(endHour)}';
  }

  static String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';

    var displayHour = hour % 12;

    if (displayHour == 0) {
      displayHour = 12;
    }

    return '$displayHour:00 $period';
  }
}

class DeliveryScheduleState {
  final DateTime? selectedDate;
  final DeliveryTimeSlot? selectedTimeSlot;

  const DeliveryScheduleState({
    this.selectedDate,
    this.selectedTimeSlot,
  });

  bool get isComplete {
    return selectedDate != null && selectedTimeSlot != null;
  }

  DateTime? get deliveryStartDateTime {
    if (selectedDate == null || selectedTimeSlot == null) {
      return null;
    }

    return DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTimeSlot!.startHour,
    );
  }

  DateTime? get deliveryEndDateTime {
    if (selectedDate == null || selectedTimeSlot == null) {
      return null;
    }

    return DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTimeSlot!.endHour,
    );
  }

  DeliveryScheduleState copyWith({
    DateTime? selectedDate,
    DeliveryTimeSlot? selectedTimeSlot,
    bool clearDate = false,
    bool clearTimeSlot = false,
  }) {
    return DeliveryScheduleState(
      selectedDate: clearDate ? null : selectedDate ?? this.selectedDate,
      selectedTimeSlot:
          clearTimeSlot ? null : selectedTimeSlot ?? this.selectedTimeSlot,
    );
  }
}

class DeliveryScheduleViewModel extends StateNotifier<DeliveryScheduleState> {
  DeliveryScheduleViewModel()
      : super(
          const DeliveryScheduleState(),
        );

  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: DateTime(
        date.year,
        date.month,
        date.day,
      ),
      clearTimeSlot: true,
    );
  }

  void selectTimeSlot(
    DeliveryTimeSlot timeSlot,
  ) {
    state = state.copyWith(
      selectedTimeSlot: timeSlot,
    );
  }

  void clearSchedule() {
    state = const DeliveryScheduleState();
  }
}

final deliveryScheduleProvider =
    StateNotifierProvider<DeliveryScheduleViewModel, DeliveryScheduleState>(
  (ref) {
    return DeliveryScheduleViewModel();
  },
);
