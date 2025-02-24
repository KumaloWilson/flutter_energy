
class APIResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  APIResponse({this.data, this.message, this.success = false});
}

