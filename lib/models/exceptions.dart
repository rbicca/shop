class HtpException implements Exception {
  final String message;

  HtpException(this.message);

  @override
  String toString() {
    return message;
  }

}