String formatTimeAgo(int time) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time * 1000);
  Duration difference = DateTime.now().difference(dateTime);
  if (difference.inMinutes < 60) {
    if (difference.inMinutes == 1) {
      return "${difference.inMinutes} minute ago";
    }
    return "${difference.inMinutes} minutes ago";
  } else {
    int hours = difference.inHours;
    if (hours == 1) {
      return "$hours hour ago";
    }
    return "$hours hours ago";
  }
}

String truncateText(String text) {
  if (text.length <= 10) {
    return text; // No truncation needed
  } else {
    return "${text.substring(0, 10)} ...";
  }
}
