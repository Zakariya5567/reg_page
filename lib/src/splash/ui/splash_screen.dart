// // ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:reg_page/reg_page.dart';
// import 'package:reg_page/src/colors.dart';
// import 'package:reg_page/src/models/user.dart';
// import 'package:reg_page/src/models/user_session.dart';
// import 'package:reg_page/src/repositories/repo.dart';
// import 'package:reg_page/src/utils/nav.dart';
// import 'package:reg_page/src/utils/urls.dart';
// import 'package:reg_page/src/utils/utils.dart';

// var globalNextPage;

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({
//     super.key,
//     required this.yearlySubscriptionId,
//     required this.monthlySubscriptionId,
//     required this.appName,
//     required this.appVersion,
//     required this.featuresList,
//     required this.nextPage,
//     required this.navKey,
//   });

//   final String yearlySubscriptionId;
//   final String monthlySubscriptionId;
//   final String appName;
//   final String appVersion;
//   final List<String> featuresList;
//   final GlobalKey<NavigatorState> navKey;
//   final Widget Function() nextPage;
//   static UserSession session = UserSession(url: BaseUrl.jhg, user: null);
//   static GlobalKey<NavigatorState>? staticNavKey;

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     SplashScreen.staticNavKey = widget.navKey;
//     Nav.key = widget.navKey;
//     globalNextPage = widget.nextPage;
//     routes();
//     animate();
//   }

//   double logoSize = 1;

//   animate() {
//     Future.delayed(const Duration(milliseconds: 500), () {
//       setState(() {
//         logoSize = 1.1;
//       });
//     });
//   }

//   routes() async {
//     animate();
//     Timer(const Duration(seconds: 3), () async {
//       String? endDate = await LocalDB.getEndDate;
//       DateTime currentDate = DateTime.now();
//       if (endDate != null) {
//         DateTime expiryDate = DateTime.parse(endDate);
//         if (currentDate.isAfter(expiryDate)) {
//           {
//             await LocalDB.clearLocalDB();
//           }
//         }
//       }
//       bool isFreePlan = await LocalDB.getIsFreePlan();
//       // print('is Free Plan $isFreePlan');
//       if (isFreePlan) {
//         Nav.offAll(widget.nextPage());
//         return;
//       }
//       String? token = await LocalDB.getBearerToken;
//       final url = await LocalDB.getBaseurl;
//       final appUser = await LocalDB.getAppUser;
//       if (kDebugMode) {
//         print('token $token');
//         print('token appUser $appUser');
//       }
//       Urls.base = BaseUrl.fromString(url ?? '');
//       SplashScreen.session = UserSession(url: Urls.base, user: null);
//       if (token == null) {
//         Nav.offAll(Welcome(
//           yearlySubscriptionId: widget.yearlySubscriptionId,
//           monthlySubscriptionId: widget.monthlySubscriptionId,
//           appName: widget.appName,
//           appVersion: widget.appVersion,
//           featuresList: widget.featuresList,
//           nextPage: () => widget.nextPage(),
//         ));
//       } else {
//         loaderDialog(context);
//         final productIds = await LocalDB.getproductIds;
//         final baseUrl = await LocalDB.getBaseurl;
//         if (productIds == null) return;
//         //  if (widget.appName == "JHG Course Hub") {
//         final res =
//             await Repo().checkSubscription(productIds, baseUrl: baseUrl);

//         //  print("response is ${response?.data}");
//         if (res == null) {
//           if (await LocalDB.isLoginTimeExpired) {
//             elseFunction();
//           } else {
//             successFunction(appUser);
//           }
//         } else {
//           // subscriptionModel = SubscriptionModel.fromJson(res);
//           setState(() {});

//           final isActive = Utils.isSubscriptionActive(res,
//               isCourseHubApp: widget.appName == "JHG Course Hub");
//           if (isActive) {
//             successFunction(appUser);
//           } else {
//             elseFunction();
//           }
//         }
//       }
//     });
//   }

//   successFunction(User? user) async {
//     await LocalDB.storeSubscriptionPurchase(true);
//     SplashScreen.session.user = user;
//     if (user != null) {
//       Nav.offAll(widget.nextPage());
//       return;
//     }
//     Utils.handleNextScreenOnSuccess(widget.appName);
//   }

//   elseFunction() async {
//     await LocalDB.clearLocalDB();
//     Nav.offAll(Welcome(
//       yearlySubscriptionId: widget.yearlySubscriptionId,
//       monthlySubscriptionId: widget.monthlySubscriptionId,
//       appName: widget.appName,
//       appVersion: widget.appVersion,
//       featuresList: widget.featuresList,
//       nextPage: () => widget.nextPage(),
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Container(
//       height: MediaQuery.of(context).size.height * 1,
//       width: MediaQuery.of(context).size.width * 1,
//       color: AppColor.primaryBlack,
//       child: Center(
//           child: AnimatedScale(
//         scale: logoSize,
//         duration: const Duration(milliseconds: 2000),
//         curve: Curves.linearToEaseOut,
//         child: Image.asset(
//           "assets/images/jhg_logo.png",
//           package: 'reg_page',
//           height: MediaQuery.of(context).size.height * 0.30,
//           width: MediaQuery.of(context).size.height * 0.30,
//           fit: BoxFit.cover,
//         ),
//       )),
//     ));
//   }
// }

import 'package:flutter/material.dart';
import 'package:reg_page/reg_page.dart';
import 'package:reg_page/src/splash/controllers/splash_controller.dart';
import 'package:reg_page/src/colors.dart';
import 'package:reg_page/src/models/user_session.dart';

var globalNextPage;

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.yearlySubscriptionId,
    required this.monthlySubscriptionId,
    required this.appName,
    required this.appVersion,
    required this.featuresList,
    required this.nextPage,
    required this.navKey,
  });

  final String yearlySubscriptionId;
  final String monthlySubscriptionId;
  final String appName;
  final String appVersion;
  final List<String> featuresList;
  final GlobalKey<NavigatorState> navKey;
  final Widget Function() nextPage;

  static UserSession session = UserSession(url: BaseUrl.jhg, user: null);
  static GlobalKey<NavigatorState>? staticNavKey;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashController? viewModel;
  double logoSize = 1;

  @override
  void initState() {
    super.initState();
    animate();
    viewModel = SplashController(
      yearlySubscriptionId: widget.yearlySubscriptionId,
      monthlySubscriptionId: widget.monthlySubscriptionId,
      appName: widget.appName,
      appVersion: widget.appVersion,
      featuresList: widget.featuresList,
      nextPage: widget.nextPage,
      navKey: widget.navKey,
      onUpdateUI: onUpdateUI,
    );
    viewModel!.initializeSplash();
    animate();
  }

  animate() async {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        logoSize = 1.1;
      });
    });
  }

  // Callback function that calls setState
  void onUpdateUI() {
    setState(() {
      logoSize = 1.1; // Update the logo size
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height * 1,
        width: MediaQuery.of(context).size.width * 1,
        color: AppColor.primaryBlack,
        child: Center(
          child: AnimatedScale(
            scale: logoSize,
            duration: const Duration(milliseconds: 2000),
            curve: Curves.linearToEaseOut,
            child: Image.asset(
              "assets/images/jhg_logo.png",
              package: 'reg_page',
              height: MediaQuery.of(context).size.height * 0.30,
              width: MediaQuery.of(context).size.height * 0.30,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}