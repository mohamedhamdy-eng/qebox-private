import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/delivery_schedule_view_model.dart';

class DeliveryScheduleScreen
    extends ConsumerWidget {
  const DeliveryScheduleScreen({
    super.key,
  });

  static const List<DeliveryTimeSlot> _allSlots = [
    DeliveryTimeSlot(
      id: '10_12',
      startHour: 10,
      endHour: 12,
    ),
    DeliveryTimeSlot(
      id: '12_14',
      startHour: 12,
      endHour: 14,
    ),
    DeliveryTimeSlot(
      id: '14_16',
      startHour: 14,
      endHour: 16,
    ),
    DeliveryTimeSlot(
      id: '16_18',
      startHour: 16,
      endHour: 18,
    ),
    DeliveryTimeSlot(
      id: '18_20',
      startHour: 18,
      endHour: 20,
    ),
    DeliveryTimeSlot(
      id: '20_22',
      startHour: 20,
      endHour: 22,
    ),
  ];

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final scheduleState =
        ref.watch(deliveryScheduleProvider);

    final now = DateTime.now();

    final availableDays = List.generate(
      3,
      (index) {
        final date = now.add(
          Duration(days: index),
        );

        return DateTime(
          date.year,
          date.month,
          date.day,
        );
      },
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFFF9F7F3),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF9F7F3),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Delivery time',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171717),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            120,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // =========================================
              // INTRO
              // =========================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6D5),
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFFEE7424),
                      size: 28,
                    ),

                    SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose your delivery time',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  Color(0xFF171717),
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Select an available delivery slot for today or up to 3 days ahead.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color:
                                  Color(0xFF777777),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =========================================
              // DAYS
              // =========================================

              const Text(
                'Choose a day',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171717),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,

                  itemCount: availableDays.length,

                  separatorBuilder: (
                    context,
                    index,
                  ) {
                    return const SizedBox(
                      width: 10,
                    );
                  },

                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final date =
                        availableDays[index];

                    final selected =
                        _isSameDay(
                      scheduleState.selectedDate,
                      date,
                    );

                    return _DayCard(
                      title: index == 0
                          ? 'Today'
                          : index == 1
                              ? 'Tomorrow'
                              : _weekdayName(
                                  date,
                                ),
                      date:
                          '${date.day} ${_monthName(date.month)}',
                      selected: selected,

                      onTap: () {
                        ref
                            .read(
                              deliveryScheduleProvider
                                  .notifier,
                            )
                            .selectDate(date);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // =========================================
              // TIME
              // =========================================

              const Text(
                'Available times',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171717),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Choose the time window that works best for you.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),

              const SizedBox(height: 16),

              if (scheduleState.selectedDate == null)
                _ChooseDayFirst()
              else
                _buildAvailableSlots(
                  ref: ref,
                  scheduleState: scheduleState,
                  now: now,
                ),

              if (scheduleState.isComplete) ...[
                const SizedBox(height: 30),

                // =========================================
                // SELECTED SLOT SUMMARY
                // =========================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFFE6D5),
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons
                              .check_circle_outline_rounded,
                          color:
                              Color(0xFFEE7424),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected delivery',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Color(0xFF777777),
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              _selectedDeliveryText(
                                scheduleState,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w800,
                                color:
                                    Color(0xFF171717),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      // =========================================
      // CONFIRM BUTTON
      // =========================================

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            18,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 15,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed:
                  scheduleState.isComplete
                      ? () {
                          Navigator.pop(context);
                        }
                      : null,

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF171717),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFFCCCCCC),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(28),
                ),
              ),

              child: const Text(
                'Confirm delivery time',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableSlots({
    required WidgetRef ref,
    required DeliveryScheduleState scheduleState,
    required DateTime now,
  }) {
    final selectedDate =
        scheduleState.selectedDate!;

    final isToday =
        _isSameDay(
      selectedDate,
      now,
    );

    final availableSlots =
        _allSlots.where(
      (slot) {
        if (!isToday) {
          return true;
        }

        final slotStart = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          slot.startHour,
        );

        // Temporary operational buffer.
        // Later this will come from Dashboard.
        final earliestAllowed =
            now.add(
          const Duration(hours: 1),
        );

        return slotStart.isAfter(
          earliestAllowed,
        );
      },
    ).toList();

    if (availableSlots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(22),
        ),
        child: const Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.schedule_outlined,
              color: Color(0xFFEE7424),
            ),

            SizedBox(width: 12),

            Expanded(
              child: Text(
                'Today\'s delivery slots are finished. Please choose tomorrow or the next available day.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF777777),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,

      children: availableSlots.map(
        (slot) {
          final selected =
              scheduleState
                      .selectedTimeSlot
                      ?.id ==
                  slot.id;

          return InkWell(
            onTap: () {
              ref
                  .read(
                    deliveryScheduleProvider
                        .notifier,
                  )
                  .selectTimeSlot(slot);
            },

            borderRadius:
                BorderRadius.circular(18),

            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFFE6D5)
                    : Colors.white,

                borderRadius:
                    BorderRadius.circular(18),

                border: Border.all(
                  color: selected
                      ? const Color(0xFFEE7424)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .access_time_rounded,
                    size: 17,
                    color: selected
                        ? const Color(
                            0xFFEE7424,
                          )
                        : const Color(
                            0xFF777777,
                          ),
                  ),

                  const SizedBox(width: 7),

                  Text(
                    slot.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w700,
                      color: selected
                          ? const Color(
                              0xFFEE7424,
                            )
                          : const Color(
                              0xFF171717,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  static String _selectedDeliveryText(
    DeliveryScheduleState state,
  ) {
    if (!state.isComplete) {
      return '';
    }

    final date =
        state.selectedDate!;

    final dateText =
        '${_weekdayName(date)}, '
        '${date.day} ${_monthName(date.month)}';

    return '$dateText • ${state.selectedTimeSlot!.label}';
  }

  static bool _isSameDay(
    DateTime? first,
    DateTime second,
  ) {
    if (first == null) {
      return false;
    }

    return first.year ==
            second.year &&
        first.month ==
            second.month &&
        first.day ==
            second.day;
  }

  static String _weekdayName(
    DateTime date,
  ) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return names[
        date.weekday - 1];
  }

  static String _monthName(
    int month,
  ) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[
        month - 1];
  }
}

// =====================================================
// CHOOSE DAY FIRST
// =====================================================

class _ChooseDayFirst
    extends StatelessWidget {
  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(
            Icons
                .calendar_month_outlined,
            color:
                Color(0xFF999999),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'Choose a delivery day first.',
              style: TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF777777),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// DAY CARD
// =====================================================

class _DayCard
    extends StatelessWidget {
  final String title;
  final String date;
  final bool selected;
  final VoidCallback onTap;

  const _DayCard({
    required this.title,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        width: 112,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFE6D5)
              : Colors.white,

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color: selected
                ? const Color(0xFFEE7424)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w700,
                color: selected
                    ? const Color(
                        0xFFEE7424,
                      )
                    : const Color(
                        0xFF777777,
                      ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              date,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w800,
                color: selected
                    ? const Color(
                        0xFFEE7424,
                      )
                    : const Color(
                        0xFF171717,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
