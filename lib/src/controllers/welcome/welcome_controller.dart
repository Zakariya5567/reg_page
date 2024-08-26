// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:reg_page/reg_page.dart';
import 'package:reg_page/src/controllers/splash/splash_controller.dart';
import 'package:reg_page/src/repositories/repo.dart';
import 'package:reg_page/src/utils/dialogs/restore_popup_dialog.dart';
import 'package:reg_page/src/utils/dialogs/subcription_url_screen.dart';
import 'package:reg_page/src/utils/nav.dart';
import 'package:reg_page/src/utils/res/constant.dart';
import 'package:reg_page/src/utils/res/urls.dart';

class WelcomeController {
  final BuildContext context;
  final String appName;
  final String yearlySubscriptionId;
  final String monthlySubscriptionId;
  final String appVersion;
  final Widget nextPage;
  String? monthlyPrice;
  String? yearlyPrice;
  bool loading = true;
  String? monthlyKey;
  String? yearlyKey;

  Set<String> variant = <String>{};
  int selectedPlan = 2;

  InAppPurchase inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<dynamic> streamSubscription;
  List<ProductDetails> products = [];

  WelcomeController({
    required this.context,
    required this.appName,
    required this.yearlySubscriptionId,
    required this.monthlySubscriptionId,
    required this.appVersion,
    required this.nextPage,
  });

  replaceAppName() {
    // Define the text to remove (uppercase)
    const excludedText = "JHG";

    // Replace the specified text with an empty string
    String result = appName.replaceAll(excludedText, '');

    return result;
  }

  // Initialize data
  Future<void> initializeData() async {
    debugLog(yearlySubscriptionId);
    debugLog(monthlySubscriptionId);

    variant.clear();
    variant.add(yearlySubscriptionId);
    variant.add(monthlySubscriptionId);

    yearlyKey = yearlySubscriptionId;
    monthlyKey = monthlySubscriptionId;

    if (!await inAppPurchase.isAvailable()) {
      loading = false;
      return;
    }

    await _subscriptionStream();
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((_) => _initTrackingTransparency());
  }

  // Subscription stream listener
  Future<void> _subscriptionStream() async {
    debugLog("Subscription stream called");
    products.clear();
    Stream purchaseUpdated = inAppPurchase.purchaseStream;

    streamSubscription = purchaseUpdated.listen((purchaseList) async {
      await _listenToPurchase(purchaseList);
    }, onDone: () {
      streamSubscription.cancel();
    }, onError: (error) {
      exceptionLog("Error $error");
      streamSubscription.cancel();
    });

    await _initStore();
  }

  // Initialize store
  Future<void> _initStore() async {
    ProductDetailsResponse productDetailsResponse =
        await inAppPurchase.queryProductDetails(variant);

    if (productDetailsResponse.error == null) {
      products = productDetailsResponse.productDetails;
      for (var element in products) {
        if (element.id == yearlyKey) {
          yearlyPrice = element.price;
        } else if (element.id == monthlyKey) {
          monthlyPrice = element.price;
        }
      }
      loading = false;
    } else {
      loading = false;
      showToast(
        context: context,
        message: productDetailsResponse.error!.message,
        isError: true,
      );
      debugPrint("Error ${productDetailsResponse.error}");
    }
  }

  // Listen to purchase
  Future<void> _listenToPurchase(
      List<PurchaseDetails> purchaseDetailsList) async {
    if (purchaseDetailsList.isEmpty) {
      _restorePopupDialog(
          Constant.restoreNotFound, Constant.restoreNotFoundDescription);
    } else {
      for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          await _onPurchasedSuccess();
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {
            return nextPage;
          }), (route) => false);
        } else if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // Handle purchased success
  Future<void> _onPurchasedSuccess() async {
    loaderDialog(context);
    await LocalDB.storeSubscriptionPurchase(true);
    await LocalDB.storeInAppSubscriptionPurchase(true);

    final proIds = await Repo().getProductIds(appName, baseUrl: Urls.evoloUrl);
    if (proIds != null) {
      await LocalDB.saveProductIds(proIds);
      await LocalDB.saveBaseUrl(Urls.evoloUrl);
    }
    Navigator.pop(context);
  }

  // Restore purchases
  Future<void> restorePurchase() async {
    try {
      loaderDialog(context);
      await inAppPurchase.restorePurchases();
      Navigator.pop(context);
    } on PlatformException catch (e) {
      exceptionLog(e);
      Navigator.pop(context);
    }
  }

  void onPlanSelect(int plan) {
    selectedPlan = plan;
    LocalDB.setIsFreePlan(plan == 0 ? true : false);
  }

  // Purchase subscription
  Future<void> purchaseSubscription(int plan) async {
    loaderDialog(context);
    debugLog("SELECTED PLAN IS $plan");

    int selectedProductIndex = _getProductIndex(plan);

    final PurchaseParam param =
        PurchaseParam(productDetails: products[selectedProductIndex]);

    try {
      if (await inAppPurchase.isAvailable()) {
        await inAppPurchase.buyNonConsumable(purchaseParam: param);
      }
    } on PlatformException catch (e) {
      Navigator.pop(context);
      showToast(context: context, message: e.message!, isError: true);
    }
  }

  // Helper function to get the index of the selected product
  int _getProductIndex(int plan) {
    for (int i = 0; i < products.length; i++) {
      if (plan == 1 && products[i].id.contains("annual")) {
        return i;
      } else if (plan == 2 && products[i].id.contains("monthly")) {
        return i;
      }
    }
    return 0; // Default to first product if no match is found
  }

  void _restorePopupDialog(String title, String description) {
    restorePopupDialog(context, title, description);
  }

  // Launch next page logic
  Future<void> launchNextPage() async {
    if (Constant.jhgApps.contains(appName)) {
      Urls.base = BaseUrl.jhg;
      loaderDialog();
      final productIds = await Repo().getProductIds(appName);
      if (productIds == null) return;
      getIt<SplashController>().productIds = productIds;
      hideLoading();
      Nav.to(const LoginScreen());
      return;
    }
    Nav.to(SubscriptionUrlScreen(
      yearlySubscriptionId: yearlySubscriptionId,
      monthlySubscriptionId: monthlySubscriptionId,
      appName: appName,
      appVersion: appVersion,
      nextPage: nextPage,
    ));
  }

  // Tracking transparency initialization
  Future<void> _initTrackingTransparency() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;

    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");
  }
}
