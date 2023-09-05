import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class InAppPurchaseSystem extends StatefulWidget {
  //final AnimationController _animationController;
  const InAppPurchaseSystem({super.key});

  @override
  State<InAppPurchaseSystem> createState() => _InAppPurchaseSystemState();
}

class _InAppPurchaseSystemState extends State<InAppPurchaseSystem> {
  purchaseConfigure() async {
    var authId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (authId != "") {
      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(
          PurchasesConfiguration("goog_YGwsrYGePglbcfONwkYxAIPrsEL")
            ..appUserID = authId
            ..observerMode = false);
    } else {
      print("Auth Id not found during purchase");
    }
  }

  Future<List<Package>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current != null) {
        if (offerings.current!.availablePackages.isNotEmpty) {
          return offerings.current!.availablePackages;
        }
      }
      return [];
    } on PlatformException catch (err) {
      return [];
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> didCustomerExist() async {
    final customInfo = await Purchases.getCustomerInfo();
    if (customInfo.entitlements.active['pro'] != null) {
      return customInfo.entitlements.active['pro']!.isActive;
    }
    return false;
  }

  @override
  void initState() {
    purchaseConfigure();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchOffers(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? CircularProgressIndicator()
              : SingleChildScrollView(
                  child: (snapshot.data == null)
                      ? Center(
                          child: Text("Something Wrong! Try Again"),
                        )
                      : Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Colors.black,
                            Theme.of(context).colorScheme.primary
                          ])),
                          child: Column(
                            children: [
                              Text(
                                "Premium Membership",
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoCRegular',
                                    fontSize: 24),
                              ),
                              FutureBuilder(
                                future: didCustomerExist(),
                                builder: (context, didExistSnapshot) =>
                                    (didExistSnapshot.connectionState ==
                                            ConnectionState.waiting)
                                        ? CircularProgressIndicator()
                                        : Container(
                                            decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 87, 79, 4),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: ListTile(
                                              titleAlignment:
                                                  ListTileTitleAlignment.center,
                                              contentPadding: EdgeInsets.all(8),
                                              title: Text(
                                                (snapshot.data!.isNotEmpty)
                                                    ? (didExistSnapshot.data !=
                                                                null &&
                                                            didExistSnapshot
                                                                    .data ==
                                                                true)
                                                        ? "You have already purchased this item"
                                                        : "All Features - Receipt Scanner, Spending Patterns, Saving Opportunities, Backup, Restore"
                                                    : "No Package Available",
                                                style: TextStyle(
                                                    color: Colors.white),
                                                textAlign: TextAlign.center,
                                              ),
                                              onTap: (didExistSnapshot.data !=
                                                          null &&
                                                      didExistSnapshot.data ==
                                                          true)
                                                  ? null
                                                  : () => {
                                                        purchasePackage(
                                                            snapshot.data![0])
                                                      },
                                            ),
                                          ),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Close"))
                            ],
                          ),
                        ),
                );
        });
  }
}
