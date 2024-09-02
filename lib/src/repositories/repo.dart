import 'package:reg_page/reg_page.dart';
import 'package:reg_page/src/services/base_service.dart';
import 'package:reg_page/src/utils/res/constants.dart';
import 'package:reg_page/src/utils/url/urls.dart';

class Repo extends BaseService with BaseController {
  Future<String?> getProductIds(String appName, {String? baseUrl}) async {
    try {
      final res = await get(Urls.productIds,
              queryParams: {'app_name': _formatAppName(appName)},
              baseUrl: baseUrl)
          .catchError((error) => handleError(error));
      if (res == null) return null;
      return res['product_ids'];
    } catch (e) {
      exceptionLog('exception on  get product ids $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkSubscription(String productIds,
      {String? baseUrl}) async {
    try {
      final token = await LocalDB.getBearerToken;
      final res = await get(
        Urls.checkSub,
        baseUrl: baseUrl,
        queryParams: {"product_ids": productIds},
        headers: {'Authorization': 'Bearer $token'},
      ).catchError((error) => handleError(error));
      return res;
    } catch (e) {
      exceptionLog('exception on  check subscription $e');
      return null;
    }
  }

  dynamic postBug(Map<String, dynamic> requestData) async {
    try {
      final token = await LocalDB.getBearerToken;
      final response = await post(
        Urls.report,
        requestData,
        headers: {'Authorization': 'Bearer $token'},
      ).catchError((error) => handleError(error));
      return response;
    } catch (e) {
      exceptionLog('exception on  post bug $e');
      return null;
    }
  }

  String _formatAppName(String input) {
    if (input.toLowerCase().startsWith('jhg')) {
      input = input.substring(3);
    }
    input = input.toLowerCase().trim();
    input = input.replaceAll(' ', '-');
    return input;
  }

  marketingAPi(String email, String appName) async {
    try {
      final res = await post(
          Urls.marketingUrl,
          baseUrl: Urls.base.url,
          {
            "subscribers": [
              {"email": email, "tag_as_event": "$appName User"}
            ]
          },
          headers: Constants.marketingHeaders);
      return res;
    } catch (e) {
      exceptionLog('exception on  marketing api $e');
      return null;
    }
  }
}
