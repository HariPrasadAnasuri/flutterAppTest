class AppValues {
  static int index = 0;
  //static String host = 'http://[2405:201:c018:4016:b24a:eaf9:f5d2:b35]:7000';
  static String host = 'http://192.168.29.49:7000';
  static String imagesUrl = '$host/photos/$index';
  static String getFileInfoUrl = '$host/photos/$index/fileInfo';
  static String myName = "";
  static String getMarkImportantUrl() {
    return '$host/photos/$index/important';
  }

  static String getMarkAsRemoveUrll() {
    return '$host/photos/$index/remove';
  }

  static String getMarkAsVisitedUrl() {
    return '$host/photos/$index/visited';
  }

  static void setIndex(int indexValue) {
    index = indexValue;
  }

  static String getCurrentIndexUrl() {
    return '$host/getMyProgress?userName=$myName';
  }

  static String getSetCurrentIndexUrl() {
    return '$host/saveProgress?userName=$myName&index=$index';
  }
}
