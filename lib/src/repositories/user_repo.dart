import 'package:reg_page/reg_page.dart';
import 'package:reg_page/src/models/result.dart';
import 'package:reg_page/src/models/user.dart';
import 'package:reg_page/src/services/base_service.dart';
import 'package:reg_page/src/utils/app_urls.dart';

class UserRepo extends BaseService with BaseController {
  //User

  Future<Result?> registerUser(Map<String, dynamic> userData) async {
    try {
      final res = await post(
        AppUrls.register,
        userData,
      ).catchError((error) => handleError(error));
      // print('res in repo ==> $res');
      if (res == null) return null;
      return Result.fromMap(res);
    } catch (e) {
      print('exception on  register user repo $e');
      return null;
    }
  }

  Future<Result> loginUser(Map<String, dynamic> userData) async {
    Result result = Result(code: 0, message: '');
    try {
      final res = await post(
        AppUrls.login,
        userData,
      ).catchError((error) {
        print('error in loginUser ${error.errorCode} $error');
        if (error is UnAutthorizedException) {
          if (error.errorCode == null) return handleError(error);
          if (error.errorCode!.contains('incorrect_password')) {
            print('password is wrong');
            result = Result(code: error.errorCode, message: error.message);
            return null;
          } else if (error.errorCode!.contains('invalid_username')) {
            print('Username and password is wrong');
            result = Result(code: error.errorCode, message: error.message);
            return null;
          }
        }
        // return handleError(error);
      });
      print('res in repo ==> $res');
      if (res == null) return result;

      return Result(code: 1, message: 'success', data: User.fromMap(res));
    } catch (e) {
      print('exception on  login user repo $e');
      return result;
    }
  }
}
