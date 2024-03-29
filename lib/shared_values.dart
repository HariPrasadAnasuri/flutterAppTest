class AppValues {
  static int fileId = 0;
  static String uuid = "";
  static bool fromQrScreen = false;
  static bool fromToMarkForPrint = false;
  static String createdDate = "2015-08-11 22:26:34";
  static String dateForVideos = "2015-08-11 22:26:34";
  // LENOVO
  static String ipv6Address = "2409:40f0:11c8:f6eb:beaf:b733:f864:9bb6";
  static String host = 'http://[$ipv6Address]:8071/manage-photos';
  static String voiceMonkeyAppHost = 'http://[$ipv6Address]:8085';

  // static String host = 'http://[2405:201:c018:4016:7e67:1e67:4cc5:d0fd]:7000';

  // ASUS
  // static String host = 'http://[2405:201:c018:417d:8726:89d1:da29:fb18]:7000';

  // TERMUX
  // static String host = 'http://[2405:201:c018:4016:dcdc:1d96:b90c:59bd]:7000';

  // KL
  //static String url = 'http://[2405:201:c018:4016:2dff:23a:f623:9d59]:7000';

  // static String host = 'http://192.168.29.49:7000';
  static String imagesUrl = '$host/photos/$fileId';
  static String getFileInfoUrl = '$host/photos/$fileId/fileInfo';
  static String userName = "Hari";
  static String siteUrl = "";
  static String importantPhotosDate = "2016-02-29 14:22:22.0";

  static void setSiteUrl(domain) {
    host = 'http://[$domain]:8071';
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
  static void setImportantPhotosDate(String dateInString) {
    importantPhotosDate = dateInString;
  }
  static String getImportantPhotosDate() {
    return importantPhotosDate;
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

  static String getNextSetOfVideosInfo() {
    return '$host/videos/getNextSet?createdDate=$dateForVideos';
  }

  static String getUrlForVideo(id) {
    return '$host/videos/$id';
  }

  static String getNextSetOfImportantImagesInfo() {
    return '$host/important/photos/getNextSet?createdDate=$importantPhotosDate';
  }

  static String getTheLastSelectedPhotoInfoForPrint() {
    return '$host/important/photos/getTheLastSelectedPhotoInfoForPrint';
  }

  static String getImageShrunkUrlUsingIdForImportantPhotos(imageId) {
    return '$host/important/photos/$imageId/shrink?userName=$userName';
  }

  static String getImageShrunkUrlUsingIndex(imageId) {
    return '$host/photos/$imageId/shrink?userName=$userName';
  }

  static String getUrlForToGetFileByUuid(){
    return '$host/photos/fileInfoByUuid/$uuid';
  }

  static String getFileStructureForPhotos(){
    return '$host/photos/getFileStructureForPhotos';
  }

  static String getNgrokApiUrl(){
    return 'https://api.ngrok.com/tunnels';
  }

  static String getTvControlNextApiUrl(){
    return '$voiceMonkeyAppHost/alexa-voice-monkey/tv/controller/updateControl?control=next';
  }

  static String getTvControlPreviousApiUrl(){
    return '$voiceMonkeyAppHost/alexa-voice-monkey/tv/controller/updateControl?control=previous';
  }
  static String getTvControlPauseApiUrl(){
    return '$voiceMonkeyAppHost/alexa-voice-monkey/tv/controller/updateControl?control=pause';
  }
  static String setTvControlDateApiUrl(){
    return '$voiceMonkeyAppHost/alexa-voice-monkey/tv/controller/setDate?date=$dateForVideos';
  }
}
