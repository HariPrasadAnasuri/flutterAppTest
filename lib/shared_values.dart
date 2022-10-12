class AppValues {
  static int index = 0;
  static String host = 'http://[2405:201:c018:4016:ccf9:19b1:49dc:b1f4]:7000';
  static String imagesUrl = '$host/photos/$index';
  static String markAsImportantUrl = '$host/photos/$index/important';
  static String markAsVisitedUrl = '$host/photos/$index/visited';
  static String markAsRemoveUrl = '$host/photos/$index/remove';
}
