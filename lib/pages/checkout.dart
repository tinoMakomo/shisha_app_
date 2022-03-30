import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class checkoutPage extends StatefulWidget {
  @override
  checkoutPageState createState() => checkoutPageState();
}

class checkoutPageState extends State<checkoutPage> {
  late WebViewController _controller;
  var cartProducts;
  var productCount = <double>[];
  var flavourCount = <double>[];
  var charcoalCount = <double>[];
  String docId ="";
  double totalPrice = 0;
  var totalPriceString = "";
  bool showlist = false;
  bool showPayfast = false;
  bool signedIn = false;
  String userid = "";

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

  getTotal()async{
    await Future.delayed(Duration(milliseconds: 600));
    for(int i = 0; i < cartProducts.length; i ++){
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

  @override
  void initState() {
    loadCart();
    getTotal();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return showPayfast? Scaffold(
      appBar: AppBar(
        title: Text('Order Payment',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.yellow[800],
        elevation: 0.5,
        leading: IconButton(onPressed: (){
          setState(() {
            showPayfast =  false;
          });
        }, icon: Icon(Icons.cancel, color: Colors.white,)),
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.4),
          child:Stack(
            children: [

              Positioned(
                  top:0,
                  left:0,
                  child:
                  Center(
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child:
                        Row(
                          children: [

                            Container(
                                width: MediaQuery.of(context).size.width,
                                child:Center(
                                  child: WebView(
                                    initialUrl: 'about:blank',
                                    javascriptMode: JavascriptMode.unrestricted,
                                    onWebViewCreated: (WebViewController webViewController) {
                                      _controller = webViewController;
                                      _loadHtmlFromAssets();
                                    },

                                  ),
                                  //child:  Html(
                                  // data: htmlData,)
                                )),
                          ],
                        )
                    ),
                  )),
            ],
          )
      ),
    ): Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Text('Total Price  R' + totalPrice.toStringAsFixed(2), style: TextStyle(fontSize: 17),),
          iconTheme: IconThemeData(color: Colors.yellow[800]),
        ),
        body: Container(
          child: !showlist ? Container() : Column(
            children: [
              cartProducts.length == 0? Center( child: Container(
                height: MediaQuery.of(context).size.height*0.5,
                child:Center(child: Text('Your cart is empty!',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 15),)),
              ), ): Expanded(
                child: showlist?ListView.separated(
                  itemCount: cartProducts.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Center(
                        child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                            color: Colors.black12,
                            height: 1.8,
                            width: MediaQuery.of(context).size.width * 0.85,
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

                    Future.delayed(Duration(milliseconds: 500), () async {
                      if (!mounted) {
                       setState(() {
                          totalPrice = totalPrice +
                              double.parse(cartProducts[index]['productPrice']) +
                              double.parse(cartProducts[index]['charcoalPrice']) +
                              double.parse(cartProducts[index]['flavourPrice']);
                       });
                     }
                    });

                    return GestureDetector(
                        onTap: () {},
                        child: Center(
                            child: Container(
                                color: Colors.white12,
                                //height: 170,
                                width: MediaQuery.of(context).size.width * 0.95,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Card(
                                      elevation: 0,
                                        child: Container(
                                            margin: new EdgeInsets.symmetric(
                                                horizontal: 10.0, vertical: 5),
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            cartProducts[index]
                                                                ['productPic'],
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        placeholder:
                                                            (context, url) =>
                                                                const Icon(
                                                          Icons.image,
                                                          size: 60,
                                                          color: Colors.grey,
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(
                                                                Icons.error),
                                                      ),
                                                    ),
                                                    Text(
                                                      cartProducts[index]
                                                          ['productName'],
                                                      style: TextStyle(
                                                          color: Colors
                                                              .blueGrey[800],
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                          'R' +
                                                              (((double.parse(
                                                                              cartProducts[index][
                                                                                  'productPrice']) *
                                                                          productCount[
                                                                              index])) +
                                                                      ((double.parse(cartProducts[index]
                                                                              [
                                                                              'flavourPrice']) *
                                                                          flavourCount[
                                                                              index])) +
                                                                      ((double.parse(cartProducts[index]
                                                                              [
                                                                              'charcoalPrice']) *
                                                                          charcoalCount[
                                                                              index])))
                                                                  .toStringAsFixed(2),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .yellow[800],
                                                              fontWeight:
                                                                  FontWeight.w900,
                                                              fontSize: 16)),
                                                      SizedBox(
                                                          width: 103,
                                                          height: 25,
                                                          child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .transparent,
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .white),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            1),
                                                              ),
                                                              child: Row(
                                                                children: <
                                                                    Widget>[
                                                                  GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        if (productCount[index] >
                                                                            0) {
                                                                          setState(
                                                                              () {
                                                                            totalPrice =
                                                                                (totalPrice - double.parse(cartProducts[index]['productPrice']) * 1);
                                                                            productCount[index] =
                                                                                productCount[index] - 1;
                                                                          });
                                                                        }
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            33,
                                                                        child: Icon(
                                                                            Icons.remove),
                                                                      )),
                                                                  Container(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  GestureDetector(
                                                                      onTap:
                                                                          () {},
                                                                      child:
                                                                          Card(
                                                                        elevation:
                                                                            3,
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              24,
                                                                          height:
                                                                              30,
                                                                          child:
                                                                              Center(child: Text(productCount[index].toStringAsFixed(0))),
                                                                        ),
                                                                      )),
                                                                  Container(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          totalPrice =
                                                                              (totalPrice - double.parse(cartProducts[index]['productPrice']) * productCount[index]);
                                                                          productCount[index] =
                                                                              productCount[index] + 1;
                                                                          totalPrice =
                                                                              totalPrice + double.parse(cartProducts[index]['productPrice']) * productCount[index];
                                                                        });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            33,
                                                                        child: Icon(
                                                                            Icons.add),
                                                                      )),
                                                                ],
                                                              ))),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ))),
                                    cartProducts[index]['flavourName'] == ""
                                        ? Container()
                                        :SizedBox(
                                      height: 10,
                                    ),
                                    cartProducts[index]['flavourName'] == ""
                                        ? Container()
                                        :Row(
                                      children: [
                                        SizedBox(width: 14,),
                                        Text('Flavour',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow[800]),),
                                      ],
                                    ),

                                    cartProducts[index]['flavourName'] == ""
                                        ? Container()
                                        : Card(
                                      elevation: 0,
                                            child: Container(
                                              //height: 20,
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 10.0,
                                                  vertical: 1),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    cartProducts[index]
                                                        ['flavourName'],
                                                    style: TextStyle(
                                                        color: Colors
                                                            .blueGrey[800],
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14),
                                                  ),
                                                  SizedBox(
                                                      width: 103,
                                                      height: 25,
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .transparent,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1),
                                                          ),
                                                          child: Row(
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    if (flavourCount[
                                                                            index] >
                                                                        0) {
                                                                      setState(
                                                                          () {
                                                                            totalPrice =
                                                                            (totalPrice - double.parse(cartProducts[index]['flavourPrice']) * 1);
                                                                        flavourCount[
                                                                            index] = flavourCount[
                                                                                index] -
                                                                            1;
                                                                      });
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 33,
                                                                    child: Icon(
                                                                        Icons
                                                                            .remove),
                                                                  )),
                                                              Container(
                                                                width: 1,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              GestureDetector(
                                                                  onTap: () {},
                                                                  child: Card(
                                                                    elevation:
                                                                        3,
                                                                    child:
                                                                        Container(
                                                                      width: 24,
                                                                      height:
                                                                          30,
                                                                      child: Center(
                                                                          child:
                                                                              Text(flavourCount[index].toStringAsFixed(0))),
                                                                    ),
                                                                  )),
                                                              Container(
                                                                width: 1,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                          totalPrice =
                                                                          (totalPrice - double.parse(cartProducts[index]['flavourPrice']) * flavourCount[index]);
                                                                      flavourCount[
                                                                              index] =
                                                                          flavourCount[index] +
                                                                              1;
                                                                          totalPrice =
                                                                              totalPrice + double.parse(cartProducts[index]['flavourPrice']) * flavourCount[index];
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 33,
                                                                    child: Icon(
                                                                        Icons
                                                                            .add),
                                                                  )),
                                                            ],
                                                          ))),
                                                ],
                                              ),
                                            ),
                                          ),
                                    cartProducts[index]['charcoalName'] == ""
                                        ? Container()
                                        :SizedBox(
                                      height: 10,
                                    ),
                                    cartProducts[index]['charcoalName'] == ""
                                        ? Container()
                                        :Row(
                                      children: [
                                        SizedBox(width: 14,),
                                        Text('Charcoal',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow[800]),),
                                      ],
                                    ),
                                    cartProducts[index]['charcoalName'] == ""
                                        ? Container()
                                        : Card(
                                      elevation: 0,
                                            child: Container(
                                              //height: 20,
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 10.0,
                                                  vertical: 1),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    cartProducts[index]
                                                        ['charcoalName'],
                                                    style: TextStyle(
                                                        color: Colors
                                                            .blueGrey[800],
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14),
                                                  ),
                                                  SizedBox(
                                                      width: 103,
                                                      height: 25,
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .transparent,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1),
                                                          ),
                                                          child: Row(
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    if (charcoalCount[
                                                                            index] >
                                                                        0) {
                                                                      setState(
                                                                          () {
                                                                            totalPrice =
                                                                            (totalPrice - double.parse(cartProducts[index]['charcoalPrice']) * 1);
                                                                        charcoalCount[
                                                                            index] = charcoalCount[
                                                                                index] -
                                                                            1;
                                                                      });
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 33,
                                                                    child: Icon(
                                                                        Icons
                                                                            .remove),
                                                                  )),
                                                              Container(
                                                                width: 1,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              GestureDetector(
                                                                  onTap: () {},
                                                                  child: Card(
                                                                    elevation:
                                                                        5,
                                                                    child:
                                                                        Container(
                                                                      width: 24,
                                                                      height:
                                                                          30,
                                                                      child: Center(
                                                                          child:
                                                                              Text(charcoalCount[index].toStringAsFixed(0))),
                                                                    ),
                                                                  )),
                                                              Container(
                                                                width: 1,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                          totalPrice =
                                                                          (totalPrice - double.parse(cartProducts[index]['charcoalPrice']) * charcoalCount[index]);
                                                                      charcoalCount[
                                                                              index] =
                                                                          charcoalCount[index] +
                                                                              1;
                                                                          totalPrice =
                                                                              totalPrice + double.parse(cartProducts[index]['charcoalPrice']) * charcoalCount[index];
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 33,
                                                                    child: Icon(
                                                                        Icons
                                                                            .add),
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
                ):Container(),
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
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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
                          showLoader(context);
                          try{
                           String? token = await FirebaseMessaging.instance.getToken();

                            DocumentReference docRef = await databaseReference
                                    .collection("orders")
                                    .add({
                                  'order_total': totalPrice,
                                  'created': DateTime.now(),
                                  'status':'processing',
                                  'paid': false,
                                  'channel':'smoke24_app',
                                  'device_id':token,
                                }).then((value) async{

                              docId = await value.id;
                              print(docId);

                              setState(() {
                                showPayfast =  true;
                              });
                              Future.delayed(const Duration(milliseconds: 1000), () {
                                _controller.runJavascript(
                                    'document.getElementById("item_id").value = "${value.id}"');
                                _controller.runJavascript('document.getElementById("order_amount").value = ${totalPrice.toString()}');

                              });
                              Future.delayed(const Duration(milliseconds: 1500), () {
                                _controller.runJavascript('document.payForm.submit()');
                              });
                              return value;
                            });

                          }catch(e){
                            dismissLoader();
                            print(e.toString());
                          }
                            dismissLoader();
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
  _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString('assets/webPages/payfast.html');
    _controller.loadUrl( Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }
}
