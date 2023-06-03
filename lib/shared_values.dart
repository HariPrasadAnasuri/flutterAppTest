class AppValues {
  static int fileId = 0;
  static String createdDate = "2015-08-11 22:26:34";
  // LENOVO
  // static String host = 'http://[2405:201:c018:4016:b23a:51eb:4995:9b65]:7000';

  // static String host = 'http://[2405:201:c018:4016:7e67:1e67:4cc5:d0fd]:7000';

  // ASUS
  static String host = 'http://[2405:201:c018:417d:8726:89d1:da29:fb18]:7000';

  // TERMUX
  // static String host = 'http://[2405:201:c018:4016:dcdc:1d96:b90c:59bd]:7000';

  // KL
  //static String url = 'http://[2405:201:c018:4016:2dff:23a:f623:9d59]:7000';

  // static String host = 'http://192.168.29.49:7000';
  static String imagesUrl = '$host/photos/$fileId';
  static String getFileInfoUrl = '$host/photos/$fileId/fileInfo';
  static String userName = "Hari";
  static String siteUrl = "";

  static void setSiteUrl(domain) {
    host = 'http://[$domain]:7000';
  }

  static String getImageUrl() {
    return '$host/photos/$fileId';
  }

  static String getMarkImportantUrl() {
    return '$host/photos/$fileId/important?name=$userName';
  }

  static String getMarkAsRemoveUrll() {
    return '$host/photos/$fileId/remove?name=$userName';
  }

  static String getMarkAsVisitedUrl() {
    return '$host/photos/$fileId/visited?name=$userName';
  }

  static String getUrlToSetThePhotoPrintStatus(status) {
    return '$host/printPhoto/$fileId/updateStatus?status=$status';
  }

  static void setFileId(int fileIdInput) {
    fileId = fileIdInput;
  }

  static String getFileIdUrl() {
    return '$host/getMyProgress?name=$userName';
  }

  static void setLastVisitedDate(String date) {
    createdDate = date;
  }

  static String getLastVisitedDateUrl() {
    return '$host/getMyProgress?name=$userName';
  }

  static String getSaveLastVisitedDateUrl() {
    return '$host/saveProgress?name=$userName&createdDate=$createdDate';
  }

  static String gettSaveFileIdIndexUrl() {
    return '$host/saveProgress?name=$userName&index=$fileId';
  }

  static String getNextSetOfImagesInfo() {
    return '$host/photos/getNextSet?name=$userName';
  }

  static String getNextSetOfImportantImagesInfo() {
    return '$host/important/photos/getNextSet?createdDate=2008-02-29 14:22:22.0';
  }

  static String getImageShrunkUrlUsingIdForImportantPhotos(imageId) {
    return '$host/important/photos/$imageId/shrink?userName=$userName';
  }

  static String getImageShrunkUrlUsingIndex(imageId) {
    return '$host/photos/$imageId/shrink?userName=$userName';
  }
}
