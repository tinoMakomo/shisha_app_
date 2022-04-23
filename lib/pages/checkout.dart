import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import '/utils/globals.dart' as globals;

class checkoutPage extends StatefulWidget {
  @override
  checkoutPageState createState() => checkoutPageState();
}

class checkoutPageState extends State<checkoutPage> {
  late InAppWebViewController _controller;
  var cartProducts;
  var productCount = <double>[];
  var flavourCount = <double>[];
  var charcoalCount = <double>[];
  String docId = "";
  double totalPrice = 0;
  var totalPriceString = "";
  bool showlist = false;
  bool showPayfast = false;
  bool signedIn = false;
  String userid = "";
  String userEmail = "";
  String userPhone = "";
  String username = "";
  String customer_address = "";
  String address = "";
  String user_snapshot_id = "";
  final GlobalKey webViewKey = GlobalKey();
  static const kGoogleApiKey = "AIzaSyAzQfpl9v3WGa2dH867TEWAL4U9jG025cg";
  final controller = TextEditingController();
  var orderItems = [];
  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  late Uint8List postData;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  final databaseReference = FirebaseFirestore.instance;
  var overlayLoader;

  showLoader(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);
    overlayLoader = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.4),
        child: const Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
      ),
    );
    overlayState?.insert(overlayLoader);
  }

  dismissLoader() {
    try {
      overlayLoader.remove();
    } catch (ex) {}
  }

  /* var overlayMaps;
  showMapsOverlay(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);
    overlayMaps = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.4),
        child: Stack(children: [

         GoogleMap(
          onMapCreated: (GoogleMapController controller) =>
              _googleMapController.complete(controller),
          initialCameraPosition: CameraPosition(
            target: LatLng(0.0, 0.0),
          ),
        ),
        Positioned(
          top: 10.0,

          child: Container(
            child: AddressSearchBox(
              controller: TextEditingController(),
              country: String,
              city: String,
              hintText: String,
              noResultText: String,
              exceptions: <String>[],
              coordForRef: bool,
              onDone: (AddressPoint point) {},
              onCleaned: () {},
            );
          ),
        ),
        ],)
      ),
    );
    overlayState?.insert(overlayMaps);
  }

  dismissMapsOverlay() {
    try {
      overlayMaps.remove();
    } catch (ex) {}
  }*/
  var overlayConfirmPayment;

  loadCart() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = Path.join(databasesPath, 'tables');

    Database database = await openDatabase(dbPath, version: 1);

    var result = await database.rawQuery('SELECT * FROM cart');
    setState(() {
      cartProducts = result.toList();
    });
    await Future.delayed(Duration(milliseconds: 700));
    setState(() {
      showlist = true;
    });
  }

  updateCartCount() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = Path.join(databasesPath, 'tables');

    Database database = await openDatabase(dbPath, version: 1);

    var result = await database.rawQuery('SELECT * FROM cart');
    setState(() {
      globals.cartCount = Sqflite.firstIntValue(result);
    });
    print(globals.cartCount);
  }

  getTotal() async {
    await Future.delayed(Duration(milliseconds: 600));
    for (int i = 0; i < cartProducts.length; i++) {
      totalPrice = totalPrice + double.parse(cartProducts[i]['total_price']);
    }
  }

  getId() async {
    if (await FirebaseAuth.instance.currentUser != null) {
      print('signed in');
      setState(() {
        signedIn = true;
        userid = FirebaseAuth.instance.currentUser!.uid;
      });
    }
    print(userid);
  }

  getData() async {
    getId();
    await Future.delayed(Duration(milliseconds: 2000));
    if (signedIn) {
      User? user = FirebaseAuth.instance.currentUser;
      var user_snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('user_id', isEqualTo: user?.uid)
          .limit(1)
          .get();

      setState(() {
        user_snapshot_id = user_snapshot.docs[0].id;
        username = user_snapshot.docs[0]['username'];
        userEmail = user_snapshot.docs[0]['email'];
        userPhone = user_snapshot.docs[0]['Mobile_number'];
        customer_address = user_snapshot.docs[0]['address'];
      });
    }
  }

  @override
  void initState() {
    getId();
    loadCart();
    getTotal();
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return showPayfast
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                'Order Payment',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.yellow[800],
              elevation: 0.5,
              leading: IconButton(
                  onPressed: () {
                    setState(() {
                      showPayfast = false;
                    });
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.white,
                  )),
            ),
            body: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.4),
                child: Stack(
                  children: [
                    Positioned(
                        top: 0,
                        left: 0,
                        child: Center(
                          child: Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(
                                        child: InAppWebView(
                                          key: webViewKey,
                                          initialUrlRequest: URLRequest(
                                              url: Uri.parse(
                                                  'https://www.payfast.co.za/eng/process'),
                                              method: 'POST',
                                              body: Uint8List.fromList(utf8.encode("amount=${totalPrice.toString()}&item_name=${docId}&merchant_id=${'10243252'}&merchant_key=${'da2q1n7etobw0'}&notify_url=${'https://europe-west2-smoke-24.cloudfunctions.net/payfast_notification'}")),
                                              headers: {
                                                'Content-Type':
                                                    'application/x-www-form-urlencoded'
                                              }),
                                          initialOptions: options,
                                          onWebViewCreated: (controller) {
                                            _controller = controller;
                                          },
                                          onLoadStart: (controller, url) {
                                            showLoader(context);
                                          },
                                          androidOnPermissionRequest:
                                              (controller, origin,
                                                  resources) async {
                                            return PermissionRequestResponse(
                                                resources: resources,
                                                action:
                                                    PermissionRequestResponseAction
                                                        .GRANT);
                                          },
                                          shouldOverrideUrlLoading: (controller,
                                              navigationAction) async {
                                            return NavigationActionPolicy.ALLOW;
                                            // var uri = navigationAction.request.url!;

                                            // if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
                                            //   if (await canLaunch(url)) {
                                            //     // Launch the App
                                            //     await launch(
                                            //       url,
                                            //     );
                                            //     // and cancel the request
                                            //     return NavigationActionPolicy.CANCEL;
                                            //   }
                                            // }

                                            // return NavigationActionPolicy.ALLOW;
                                          },
                                          onLoadStop: (controller, url) async {
                                            dismissLoader();
                                            if (url
                                                .toString()
                                                .contains('finish')) {
                                              await Future.delayed(
                                                  Duration(milliseconds: 2000));
                                              setState(() {
                                                showPayfast = false;
                                              });
                                              await Future.delayed(
                                                  Duration(milliseconds: 2000));
                                              Fluttertoast.showToast(
                                                  msg:
                                                      'Please wait while we check your payment status',
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      Colors.black54,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);
                                            }
                                            print(url);
                                          },
                                          onLoadError:
                                              (controller, url, code, message) {
                                            dismissLoader();
                                            Fluttertoast.showToast(
                                                msg: message,
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.black54,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          },
                                          onProgressChanged:
                                              (controller, progress) {
                                            if (progress == 100) {
                                              // pullToRefreshController.endRefreshing();
                                            }
                                            setState(() {
                                              //this.progress = progress / 100;
                                            });
                                          },
                                          onUpdateVisitedHistory: (controller,
                                              url, androidIsReload) {
                                            setState(() {
                                              //this.url = url.toString();
                                            });
                                          },
                                          onConsoleMessage:
                                              (controller, consoleMessage) {
                                            print(consoleMessage);
                                          },
                                        ),
                                        //child:  Html(
                                        // data: htmlData,)
                                      )),
                                ],
                              )),
                        )),
                  ],
                )),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            key: homeScaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              title: Text(
                'Total Price  R' + totalPrice.toStringAsFixed(2),
                style: TextStyle(fontSize: 17),
              ),
              iconTheme: IconThemeData(color: Colors.yellow[800]),
            ),
            body: Container(
              child: !showlist
                  ? Container()
                  : Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Card(
                            color: Colors.white,
                            elevation: 2,
                            child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * 0.85,
                                color: Colors.white,
                                child: TextButton(
                                  child: customer_address == ""
                                      ? Text(
                                          'Delivery Address',
                                          style: TextStyle(
                                              color: Colors.yellow[800],
                                              fontWeight: FontWeight.bold),
                                        )
                                      : Text(
                                          customer_address,
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                  onPressed: () async {
                                    Prediction? p =
                                        await PlacesAutocomplete.show(
                                            offset: 0,
                                            radius: 100000,
                                            types: [],
                                            strictbounds: false,
                                            region: "",
                                            context: context,
                                            apiKey: kGoogleApiKey,
                                            mode:
                                                Mode.overlay, // Mode.fullscreen
                                            language: "en",
                                            components: [
                                              Component(
                                                Component.country,
                                                "za",
                                              ),
                                              Component(
                                                Component.country,
                                                "zw",
                                              )
                                            ]);

                                    displayPrediction(p!);
                                  },
                                ))),
                        SizedBox(
                          height: 10,
                        ),
                        cartProducts.length == 0
                            ? Center(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Center(
                                      child: Text(
                                    'Your cart is empty!',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black45,
                                        fontSize: 15),
                                  )),
                                ),
                              )
                            : Expanded(
                                child: showlist
                                    ? ListView.separated(
                                        itemCount: cartProducts.length,
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return Center(
                                              child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 12,
                                                ),
                                                Container(
                                                  color: Colors.black12,
                                                  height: 1.8,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.85,
                                                ),
                                                SizedBox(
                                                  height: 12,
                                                )
                                              ],
                                            ),
                                          ));
                                        },
                                        itemBuilder: (context, int index) {
                                          productCount.add(1);
                                          flavourCount.add(1);
                                          charcoalCount.add(1);

                                          Future.delayed(
                                              Duration(milliseconds: 500),
                                              () async {
                                            if (!mounted) {
                                              setState(() {
                                                totalPrice = totalPrice +
                                                    double.parse(
                                                        cartProducts[index]
                                                            ['productPrice']) +
                                                    double.parse(
                                                        cartProducts[index]
                                                            ['charcoalPrice']) +
                                                    double.parse(
                                                        cartProducts[index]
                                                            ['flavourPrice']);
                                              });
                                            }
                                          });

                                          return GestureDetector(
                                              onTap: () {},
                                              child: Center(
                                                  child: Container(
                                                      color: Colors.white12,
                                                      //height: 170,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.95,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Card(
                                                              elevation: 0,
                                                              child: Container(
                                                                  margin: new EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          10.0,
                                                                      vertical:
                                                                          5),
                                                                  height: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                40,
                                                                            height:
                                                                                40,
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              imageUrl: cartProducts[index]['productPic'],
                                                                              imageBuilder: (context, imageProvider) => Container(
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                  image: DecorationImage(
                                                                                    image: imageProvider,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              placeholder: (context, url) => const Icon(
                                                                                Icons.image,
                                                                                size: 60,
                                                                                color: Colors.grey,
                                                                              ),
                                                                              errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            cartProducts[index]['productName'],
                                                                            style: TextStyle(
                                                                                color: Colors.blueGrey[800],
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: 14),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Container(
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            Text('R' + (((double.parse(cartProducts[index]['productPrice']) * productCount[index])) + ((double.parse(cartProducts[index]['flavourPrice']) * flavourCount[index])) + ((double.parse(cartProducts[index]['charcoalPrice']) * charcoalCount[index]))).toStringAsFixed(2),
                                                                                style: TextStyle(color: Colors.yellow[800], fontWeight: FontWeight.w900, fontSize: 16)),
                                                                            SizedBox(
                                                                                width: 103,
                                                                                height: 25,
                                                                                child: Container(
                                                                                    decoration: BoxDecoration(
                                                                                      color: Colors.transparent,
                                                                                      border: Border.all(color: Colors.white),
                                                                                      borderRadius: BorderRadius.circular(1),
                                                                                    ),
                                                                                    child: Row(
                                                                                      children: <Widget>[
                                                                                        GestureDetector(
                                                                                            onTap: () async {
                                                                                              if (productCount[index] > 1) {
                                                                                                setState(() {
                                                                                                  totalPrice = (totalPrice - double.parse(cartProducts[index]['productPrice']) * 1);
                                                                                                  productCount[index] = productCount[index] - 1;
                                                                                                });
                                                                                              } else {
                                                                                                setState(() {
                                                                                                  totalPrice = (totalPrice - double.parse(cartProducts[index]['productPrice']) * 1);
                                                                                                  productCount[index] = productCount[index] - 1;
                                                                                                });
                                                                                                String databasesPath = await getDatabasesPath();
                                                                                                String dbPath = Path.join(databasesPath, 'tables');

                                                                                                Database database = await openDatabase(dbPath, version: 1);
                                                                                                await database.transaction((txn) async {
                                                                                                  int id1 = await txn.rawDelete('DELETE FROM cart WHERE product_id = ?', [
                                                                                                    cartProducts[index]['product_id']
                                                                                                  ]);
                                                                                                  print('deleted: $id1');
                                                                                                }).then((value) {
                                                                                                  cartProducts.remove(cartProducts[index]);
                                                                                                  productCount.removeAt(index);
                                                                                                });
                                                                                              }
                                                                                              updateCartCount();
                                                                                            },
                                                                                            child: Container(
                                                                                              width: 33,
                                                                                              child: Icon(Icons.remove),
                                                                                            )),
                                                                                        Container(
                                                                                          width: 1,
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                        GestureDetector(
                                                                                            onTap: () {},
                                                                                            child: Card(
                                                                                              elevation: 3,
                                                                                              child: Container(
                                                                                                width: 24,
                                                                                                height: 30,
                                                                                                child: Center(child: Text(productCount[index].toStringAsFixed(0))),
                                                                                              ),
                                                                                            )),
                                                                                        Container(
                                                                                          width: 1,
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                        GestureDetector(
                                                                                            onTap: () {
                                                                                              setState(() {
                                                                                                totalPrice = (totalPrice - double.parse(cartProducts[index]['productPrice']) * productCount[index]);
                                                                                                productCount[index] = productCount[index] + 1;
                                                                                                totalPrice = totalPrice + double.parse(cartProducts[index]['productPrice']) * productCount[index];
                                                                                              });
                                                                                              updateCartCount();
                                                                                            },
                                                                                            child: Container(
                                                                                              width: 33,
                                                                                              child: Icon(Icons.add),
                                                                                            )),
                                                                                      ],
                                                                                    ))),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ))),
                                                          cartProducts[index][
                                                                      'flavourName'] ==
                                                                  ""
                                                              ? Container()
                                                              : SizedBox(
                                                                  height: 10,
                                                                ),
                                                          cartProducts[index][
                                                                      'flavourName'] ==
                                                                  ""
                                                              ? Container()
                                                              : Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 14,
                                                                    ),
                                                                    Text(
                                                                      'Flavour',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.yellow[800]),
                                                                    ),
                                                                  ],
                                                                ),
                                                          cartProducts[index][
                                                                      'flavourName'] ==
                                                                  ""
                                                              ? Container()
                                                              : Card(
                                                                  elevation: 0,
                                                                  child:
                                                                      Container(
                                                                    //height: 20,
                                                                    margin: new EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            10.0,
                                                                        vertical:
                                                                            1),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          cartProducts[index]
                                                                              [
                                                                              'flavourName'],
                                                                          style: TextStyle(
                                                                              color: Colors.blueGrey[800],
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 14),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                103,
                                                                            height:
                                                                                25,
                                                                            child: Container(
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.transparent,
                                                                                  border: Border.all(color: Colors.white),
                                                                                  borderRadius: BorderRadius.circular(1),
                                                                                ),
                                                                                child: Row(
                                                                                  children: <Widget>[
                                                                                    GestureDetector(
                                                                                        onTap: () {
                                                                                          if (flavourCount[index] > 0) {
                                                                                            setState(() {
                                                                                              totalPrice = (totalPrice - double.parse(cartProducts[index]['flavourPrice']) * 1);
                                                                                              flavourCount[index] = flavourCount[index] - 1;
                                                                                            });
                                                                                          }
                                                                                        },
                                                                                        child: Container(
                                                                                          width: 33,
                                                                                          child: Icon(Icons.remove),
                                                                                        )),
                                                                                    Container(
                                                                                      width: 1,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    GestureDetector(
                                                                                        onTap: () {},
                                                                                        child: Card(
                                                                                          elevation: 3,
                                                                                          child: Container(
                                                                                            width: 24,
                                                                                            height: 30,
                                                                                            child: Center(child: Text(flavourCount[index].toStringAsFixed(0))),
                                                                                          ),
                                                                                        )),
                                                                                    Container(
                                                                                      width: 1,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    GestureDetector(
                                                                                        onTap: () {
                                                                                          setState(() {
                                                                                            totalPrice = (totalPrice - double.parse(cartProducts[index]['flavourPrice']) * flavourCount[index]);
                                                                                            flavourCount[index] = flavourCount[index] + 1;
                                                                                            totalPrice = totalPrice + double.parse(cartProducts[index]['flavourPrice']) * flavourCount[index];
                                                                                          });
                                                                                        },
                                                                                        child: Container(
                                                                                          width: 33,
                                                                                          child: Icon(Icons.add),
                                                                                        )),
                                                                                  ],
                                                                                ))),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                          cartProducts[index][
                                                                      'charcoalName'] ==
                                                                  ""
                                                              ? Container()
                                                              : SizedBox(
                                                                  height: 10,
                                                                ),
                                                          cartProducts[index][
                                                                      'charcoalName'] ==
                                                                  ""
                                                              ? Container()
                                                              : Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 14,
                                                                    ),
                                                                    Text(
                                                                      'Charcoal',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.yellow[800]),
                                                                    ),
                                                                  ],
                                                                ),
                                                          cartProducts[index][
                                                                      'charcoalName'] ==
                                                                  ""
                                                              ? Container()
                                                              : Card(
                                                                  elevation: 0,
                                                                  child:
                                                                      Container(
                                                                    //height: 20,
                                                                    margin: new EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            10.0,
                                                                        vertical:
                                                                            1),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          cartProducts[index]
                                                                              [
                                                                              'charcoalName'],
                                                                          style: TextStyle(
                                                                              color: Colors.blueGrey[800],
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 14),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                103,
                                                                            height:
                                                                                25,
                                                                            child: Container(
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.transparent,
                                                                                  border: Border.all(color: Colors.white),
                                                                                  borderRadius: BorderRadius.circular(1),
                                                                                ),
                                                                                child: Row(
                                                                                  children: <Widget>[
                                                                                    GestureDetector(
                                                                                        onTap: () {
                                                                                          if (charcoalCount[index] > 0) {
                                                                                            setState(() {
                                                                                              totalPrice = (totalPrice - double.parse(cartProducts[index]['charcoalPrice']) * 1);
                                                                                              charcoalCount[index] = charcoalCount[index] - 1;
                                                                                            });
                                                                                          }
                                                                                        },
                                                                                        child: Container(
                                                                                          width: 33,
                                                                                          child: Icon(Icons.remove),
                                                                                        )),
                                                                                    Container(
                                                                                      width: 1,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    GestureDetector(
                                                                                        onTap: () {},
                                                                                        child: Card(
                                                                                          elevation: 5,
                                                                                          child: Container(
                                                                                            width: 24,
                                                                                            height: 30,
                                                                                            child: Center(child: Text(charcoalCount[index].toStringAsFixed(0))),
                                                                                          ),
                                                                                        )),
                                                                                    Container(
                                                                                      width: 1,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    GestureDetector(
                                                                                        onTap: () {
                                                                                          setState(() {
                                                                                            totalPrice = (totalPrice - double.parse(cartProducts[index]['charcoalPrice']) * charcoalCount[index]);
                                                                                            charcoalCount[index] = charcoalCount[index] + 1;
                                                                                            totalPrice = totalPrice + double.parse(cartProducts[index]['charcoalPrice']) * charcoalCount[index];
                                                                                          });
                                                                                        },
                                                                                        child: Container(
                                                                                          width: 33,
                                                                                          child: Icon(Icons.add),
                                                                                        )),
                                                                                  ],
                                                                                ))),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                        ],
                                                      ))));
                                        },
                                        shrinkWrap: true,
                                      )
                                    : Container(),
                              )
                      ],
                    ),
            ),
            bottomNavigationBar: BottomAppBar(
                color: Colors.transparent,
                elevation: 0,
                shape: const AutomaticNotchedShape(
                  RoundedRectangleBorder(),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 63,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.transparent),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 65,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.yellow[800]),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            child: Text(
                              'PROCEED TO PAYMENT',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              if (signedIn) {
                                if (customer_address == "") {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Please enter your Delivery Address.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black54,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  showLoader(context);
                                  try {
                                    orderItems.clear();
                                    for (int x = 0;
                                        x < cartProducts.length;
                                        x++) {
                                      var product =
                                          '${cartProducts[x]['productName']} R${cartProducts[x]['productPrice']} x ${productCount[x].toStringAsFixed(0)}';
                                      var flavour =
                                          '${cartProducts[x]['flavourName'] != '' ? '+' : ''} ${cartProducts[x]['flavourName'] != '' ? cartProducts[x]['flavourName'] : ''} ${cartProducts[x]['flavourName'] != '' ? 'R' : ''}${cartProducts[x]['flavourName'] != '' ? cartProducts[x]['flavourPrice'] : ''} ${cartProducts[x]['flavourName'] != '' ? 'x' : ''}  ${cartProducts[x]['flavourName'] != '' ? flavourCount[x].toStringAsFixed(0) : ''}';
                                      var charcoal =
                                          '${cartProducts[x]['charcoalName'] != '' ? '+' : ''} ${cartProducts[x]['charcoalName'] != '' ? cartProducts[x]['charcoalName'] : ''} ${cartProducts[x]['charcoalName'] != '' ? 'R' : ''}${cartProducts[x]['charcoalName'] != '' ? cartProducts[x]['charcoalPrice'] : ''} ${cartProducts[x]['charcoalName'] != '' ? 'x' : ''}  ${cartProducts[x]['charcoalName'] != '' ? charcoalCount[x].toStringAsFixed(0) : ''}';
                                      orderItems.add(
                                          '${product.trim()} ${flavour.trim()} ${charcoal.trim()}');
                                      // '';
                                    }
                                    print(orderItems);
                                    getData();
                                    await Future.delayed(
                                        Duration(milliseconds: 1000));
                                    String? token = await FirebaseMessaging
                                        .instance
                                        .getToken();
                                    DocumentReference docRef =
                                        await databaseReference
                                            .collection("orders")
                                            .add({
                                      'order_total': totalPrice,
                                      'created': DateTime.now(),
                                      'status': 'processing',
                                      'paid': false,
                                      'channel': 'smoke24_app',
                                      'device_id': token,
                                      'customer_email': userEmail,
                                      'customer_phone': userPhone,
                                      'customer_username': username,
                                      'customer_address': customer_address,
                                      'order_list': orderItems,
                                    }).then((value) async {
                                      docId = await value.id;
                                      setState(() {
                                        showPayfast = true;
                                      });
                                      return value;
                                    });
                                  } catch (e) {
                                    dismissLoader();
                                    print(e.toString());
                                  }
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Login first to complete your order.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black54,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString(
                                    'loginRemoveMethod', 'checkout');
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            loginPage()));
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                    )
                  ],
                )));
  }

  Future<Null> displayPrediction(Prediction p) async {
    await Future.delayed(Duration(milliseconds: 1000));
    var address = await p.description.toString();
    setState(() {
      customer_address = address;
    });
    await Future.delayed(Duration(milliseconds: 500));
    FirebaseFirestore.instance.collection('users').doc(user_snapshot_id).set(
        {'address': customer_address}, SetOptions(merge: true)).then((value) {
      //Do your stuff.
    });
  }
}
