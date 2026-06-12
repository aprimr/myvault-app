import 'package:intl/intl.dart';

class DateFormatter {
  /// Converts full timestamp → readable date
  /// Example: 2026-06-10 07:43:02.055242+00 → 10 Jun 2026
  static String toSimpleDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr; // fallback if parsing fails
    }
  }

  /// Converts to date + time
  /// Example: 10 Jun 2026, 7:43 AM
  static String toDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  /// Relative time (optional bonus)
  /// Example: "2 hours ago"
  static String toRelative(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);

      if (diff.inDays > 0) return '${diff.inDays} day(s) ago';
      if (diff.inHours > 0) return '${diff.inHours} hour(s) ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} minute(s) ago';
      return 'just now';
    } catch (e) {
      return dateStr;
    }
  }
}
