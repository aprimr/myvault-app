import 'package:intl/intl.dart';

class DateFormatter {
  // Converts full timestamp → readable local date
  // Example:
  // 10 Jun 2026
  static String toSimpleDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();

      return DateFormat('yyyy MMM dd').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // Converts to local date + time
  // Example:
  // 10 Jun 2026, 1:28 PM
  static String toDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();

      return DateFormat('dd MMM yyyy, h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // Relative time based on local time
  // Example:
  // "2 hours ago"
  static String toRelative(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 365) {
        return '${(diff.inDays / 365).floor()} year(s) ago';
      }

      if (diff.inDays > 30) {
        return '${(diff.inDays / 30).floor()} month(s) ago';
      }

      if (diff.inDays > 0) {
        return '${diff.inDays} day(s) ago';
      }

      if (diff.inHours > 0) {
        return '${diff.inHours} hour(s) ago';
      }

      if (diff.inMinutes > 0) {
        return '${diff.inMinutes} minute(s) ago';
      }

      return 'just now';
    } catch (e) {
      return dateStr;
    }
  }
}
