class Response {
  bool isSuccess;
  String message;
  dynamic result;
  int totalCount;

  Response({required this.isSuccess, this.message="",this.result, this.totalCount = 0});

}