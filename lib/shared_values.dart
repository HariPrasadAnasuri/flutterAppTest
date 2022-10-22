class AppValues {
  static int index = 0;
  static String createdDate = "2015-08-11 22:26:34";
  static String host = 'http://[2405:201:c018:4016:b24a:eaf9:f5d2:b35]:7000';
  //static String host = 'http://[2405:201:c018:4016:7e67:1e67:4cc5:d0fd]:7000';

  // static String host = 'http://192.168.29.49:7000';
  static String imagesUrl = '$host/photos/$index';
  static String getFileInfoUrl = '$host/photos/$index/fileInfo';
  static String myName = "Hari";

  static String getImageUrl() {
    return '$host/photos/$index';
  }

  static String getMarkImportantUrl() {
    return '$host/photos/$index/important?name=$myName';
  }

  static String getMarkAsRemoveUrll() {
    return '$host/photos/$index/remove?name=$myName';
  }

  static String getMarkAsVisitedUrl() {
    return '$host/photos/$index/visited?name=$myName';
  }

  static void setIndex(int indexValue) {
    index = indexValue;
  }

  static String getCurrentIndexUrl() {
    return '$host/getMyProgress?name=$myName';
  }

  static void setDate(String date) {
    createdDate = date;
  }

  static String getLastDateUrl() {
    return '$host/getMyProgress?name=$myName';
  }

  static String getSetLastDateUrl() {
    return '$host/saveProgress?name=$myName&createdDate=$createdDate';
  }

  static String getSetCurrentIndexUrl() {
    return '$host/saveProgress?name=$myName&index=$index';
  }

  static String getNextSetOfImagesInfo() {
    return '$host/photos/getNextSet?name=$myName';
  }

  static String getImageShrunkUrlUsingIndex(imageId) {
    return '$host/photos/$imageId/shrink';
  }
}
