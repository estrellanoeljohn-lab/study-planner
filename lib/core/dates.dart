const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String formatShortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

String formatWeekdayDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${formatShortDate(d)}';

String formatTime(DateTime d) {
  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final suffix = d.hour < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $suffix';
}

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
    String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}
DateTime startOfWeek(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - 1));

String weekdayShort(int weekday) => _weekdays[weekday - 1];