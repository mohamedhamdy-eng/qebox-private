part of 'order_details_screen.dart';

// =====================================================
// JOURNEY STEP
// =====================================================

class _JourneyStep extends StatelessWidget {
  final String title;
  final bool completed;
  final bool current;
  final bool isLast;

  const _JourneyStep({
    required this.title,
    required this.completed,
    required this.current,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final active = completed || current;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFEE7424)
                      : const Color(0xFFE5E5E5),
                  shape: BoxShape.circle,
                ),
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      )
                    : current
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 34,
                  color: active
                      ? const Color(0xFFEE7424)
                      : const Color(0xFFE5E5E5),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                color: active
                    ? const Color(0xFF171717)
                    : const Color(0xFF999999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// INFO ROW
// =====================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE6D5),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 21, color: const Color(0xFFEE7424)),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Color(0xFF777777)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171717),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =====================================================
// SUMMARY ROW
// =====================================================

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isTotal;
  final bool isDiscount;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 17 : 13,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              color: isTotal
                  ? const Color(0xFF171717)
                  : const Color(0xFF777777),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 13,
            fontWeight: FontWeight.w800,
            color: isDiscount
                ? const Color(0xFF2E7D32)
                : isTotal
                ? const Color(0xFFEE7424)
                : const Color(0xFF171717),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// STATUS STYLE
// =====================================================

class _StatusStyle {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusStyle({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}
