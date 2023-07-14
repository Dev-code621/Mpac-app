class CustomDateTime {
  static String readableDate(String date, {bool full = true}){
    DateTime dateTime = DateTime.parse(date).toUtc();
    DateTime now = DateTime.now().toUtc();
    Duration difference = now.difference(dateTime).abs();

    int days = difference.inDays;
    int years = days ~/ 365;
    int months = days ~/ 30;
    int weeks = days ~/ 7;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;
    int seconds = difference.inSeconds % 60;

    Map<String, int> diffs = {
      'y': years,
      'm': months,
      'w': weeks,
      'd': days,
      'h': hours,
      'i': minutes,
      's': seconds,
    };

    Map<String, String> timeStrings = {
      'y': 'year',
      'm': 'month',
      'w': 'week',
      'd': 'day',
      'h': 'hour',
      'i': 'minute',
      's': 'second',
    };

    List<String> timeParts = [];

    timeStrings.forEach((unit, name) {
      int diff = diffs[unit]!;
      if (diff > 0) {
        String timePart = '$diff $name${diff > 1 ? 's' : ''}';
        timeParts.add(timePart);
      }
    });

    if (timeParts.isEmpty) {
      return 'Just now';
    }

    if (full) {
      String lastTimePart = timeParts.removeLast();
      String timePartsWithAnd = '${timeParts.join(', ')} and $lastTimePart';
      return '$timePartsWithAnd ago';
    } else {
      return '${timeParts[0]} ago';
    }
  }
}