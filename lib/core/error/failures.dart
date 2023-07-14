import 'package:mpac_app/core/utils/constants/error_codes.dart';

abstract class Failure {}

class ServerFailure implements Failure {
  final ErrorCodes errorCode;
  final String? errorMessage;

  ServerFailure(this.errorCode, {this.errorMessage});

  @override
  String toString() => 'ServerFailure(errorCode: $errorCode)';
}

class CacheFailure implements Failure {}
