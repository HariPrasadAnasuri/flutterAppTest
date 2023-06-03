class AppValues {
  static int fileId = 0;
  static String createdDate = "2015-08-11 22:26:34";
  // LENOVO
  // static String host = 'http://[2405:201:c018:4016:b23a:51eb:4995:9b65]:7000';

  // static String host = 'http://[2405:201:c018:4016:7e67:1e67:4cc5:d0fd]:7000';

  // ASUS
  // static String host = 'http://[2405:201:c018:4016:b24a:eaf9:f5d2:b35]:7000';

  // TERMUX
  // static String host = 'http://[2405:201:c018:4016:dcdc:1d96:b90c:59bd]:7000';

  // KL
  static String url = 'http://[2405:201:c018:4016:2dff:23a:f623:9d59]:7000';

  // static String host = 'http://192.168.29.49:7000';
  static String imagesUrl = '$url/photos/$fileId';
  static String getFileInfoUrl = '$url/photos/$fileId/fileInfo';
  static String userName = "Hari";
  static String siteUrl = "";

  static void setSiteUrl(host) {
    url = 'http://[$host]:7000';
  }

  static String getImageUrl() {
    return '$url/photos/$fileId';
  }

  static String getMarkImportantUrl() {
    return '$url/photos/$fileId/important?name=$userName';
  }

  static String getMarkAsRemoveUrll() {
    return '$url/photos/$fileId/remove?name=$userName';
  }

  static String getMarkAsVisitedUrl() {
    return '$url/photos/$fileId/visited?name=$userName';
  }

  static void setFileId(int fileIdInput) {
    fileId = fileIdInput;
  }

  static String getFileIdUrl() {
    return '$url/getMyProgress?name=$userName';
  }

  static void setLastVisitedDate(String date) {
    createdDate = date;
  }

  static String getLastVisitedDateUrl() {
    return '$url/getMyProgress?name=$userName';
  }

  static String getSaveLastVisitedDateUrl() {
    return '$url/saveProgress?name=$userName&createdDate=$createdDate';
  }

  static String gettSaveFileIdIndexUrl() {
    return '$url/saveProgress?name=$userName&index=$fileId';
  }

  static String getNextSetOfImagesInfo() {
    return '$url/photos/getNextSet?name=$userName';
  }

  static String getImageShrunkUrlUsingIndex(imageId) {
    return '$url/photos/$imageId/shrink?userName=$userName';
  }
}
