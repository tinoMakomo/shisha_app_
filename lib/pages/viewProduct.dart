import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shisha_app/pages/checkout.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
import '/utils/globals.dart' as globals;

class ViewProduct extends StatefulWidget {
  String productID;
  ViewProduct(this.productID, {Key? key}) : super(key: key);
  @override
  State<ViewProduct> createState() => _ViewProductState(productID);
}

class _ViewProductState extends State<ViewProduct> {
  String productID;
  _ViewProductState(this.productID);
  final GlobalKey _menuKey = GlobalKey();
  String picUrl = "";
  String productName = "";
  String charcoalPrice = "0";
  String charcoalName = "";
  String flavourName = "";
  String flavourPrice = "0";
  String charcoalID = "";
  String flavourID = "";
  String productPrice = "0";
  String rentPrice = "0";
  String productRentPrice = "0";
  String productDescription = "";
  int cartItems = 1;
  String selectedAccessory = "";
  String selectedCharcoal = "";
  double total = 0;
  String selectedMethod = "buy";
  String selectedCigar = "cigar";
  String productCategory = "";
  String selectedCharcoalPrice = "0";
  String selectedFlavourPrice = "0";
  String boxPrice = "0";
  bool isInCart = false;
  var overlayLoader;
  final databaseReference = FirebaseFirestore.instance;

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

  checkFavs() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = Path.join(databasesPath, 'tables');

    Database database = await openDatabase(dbPath, version: 1);

    var favo = await database
        .rawQuery('SELECT * FROM favourites WHERE product_id=?', [productID]);

    if (favo.toString() == '[]') {
      setState(() {
        fav = false;
      });
    } else {
      setState(() {
        fav = true;
      });
    }
  }

  getProductData() async {
    FirebaseFirestore.instance
        .collection('Products')
        .doc(productID)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds.exists) {
        setState(() {
          productName = ds['name'].toString();
          productDescription = ds['description'].toString();
          productPrice = ds['price'].toString();
          picUrl = ds['pic_url'].toString();
          total = double.parse(ds['price'].toString());
          productCategory = ds['category'].toString();
          rentPrice = ds['category'].toString().toLowerCase() == 'shisha'
              ? ds['rentPrice'].toString()
              : "";
          boxPrice = ds['category'].toString().toLowerCase() == 'cigars'
              ? ds['boxPrice'].toString()
              : "";
        });
      }
    });
  }

  bool signedIn = false;
  String userid = "";
  bool fav = false;

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

  checkCart() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = Path.join(databasesPath, 'tables');

    Database database = await openDatabase(dbPath, version: 1);

    var cart = await database
        .rawQuery('SELECT * FROM cart WHERE product_id=?', [productID]);

    if (cart.toString() == '[]') {
      setState(() {
        isInCart = false;
      });
    } else {
      setState(() {
        isInCart = true;
      });
    }
    print(cart.toString());
  }

  @override
  void initState() {
    checkFavs();
    getId();
    checkCart();
    getProductData();
    super.initState();
  }

  Widget buildCharcoal(BuildContext context, DocumentSnapshot document) {
    return GestureDetector(
        onTap: () {
          //_showPopupMenu();
          setState(() {
            if (selectedCharcoal == document['name'].toString().toLowerCase()) {
              selectedCharcoal = "";
              total = total - double.parse(document['price'].toString());
              selectedCharcoalPrice = "0";
              charcoalID = "";
              charcoalName = "";
              charcoalPrice = "0";
            } else {
              if (selectedCharcoal == "") {
                total = (total) + double.parse(document['price'].toString());
              } else {
                total = (total - double.parse(selectedCharcoalPrice)) +
                    double.parse(document['price'].toString());
              }
              selectedCharcoalPrice = document['price'].toString();
              selectedCharcoal = document['name'].toString().toLowerCase();
              charcoalID = document['id'].toString();
              charcoalName = document['name'].toString();
            }
          });
        },
        child: Center(
            child: Row(
          children: [
            SizedBox(
              height: 55,
              width: 55,
              child: CachedNetworkImage(
                imageUrl: document["icon_url"],
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => const Text(''),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            SizedBox(
                height: 55,
                child: Container(
                    padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                    decoration: BoxDecoration(
                      color: selectedCharcoal ==
                              document['name'].toString().toLowerCase()
                          ? Colors.yellow[800]
                          : Colors.transparent,
                      border: Border.all(color: Colors.orangeAccent),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              document['name'],
                              style: TextStyle(
                                  color: selectedCharcoal ==
                                          document['name']
                                              .toString()
                                              .toLowerCase()
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.blueGrey[900],
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12),
                            )
                          ],
                        ),
                        Text('R' + document['price'].toString(),
                            style: TextStyle(
                                color: selectedCharcoal ==
                                        document['name']
                                            .toString()
                                            .toLowerCase()
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.blueGrey[900],
                                fontWeight: FontWeight.w800,
                                fontSize: 14))
                      ],
                    ))),
            const SizedBox(
              width: 7,
            )
          ],
        )));
  }

  showLoader(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);
    overlayLoader = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.4),
        child: Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
      ),
    );
    overlayState?.insert(overlayLoader);
  }

  dismissLoader() {
    print("Loader Dismissed");

    try {
      overlayLoader.remove();
    } catch (ex) {}
  }

  Widget buildAccessories(BuildContext context, DocumentSnapshot document) {
    return GestureDetector(
        onTap: () {
          //_showPopupMenu();
          setState(() {
            if (selectedAccessory ==
                document['name'].toString().toLowerCase()) {
              flavourID = "";
              selectedAccessory = "";
              total = total - double.parse(document['price'].toString());
              selectedFlavourPrice = "0";
              flavourName = "";
            } else {
              if (selectedAccessory == "") {
                total = (total) + double.parse(document['price'].toString());
              } else {
                total = (total - double.parse(selectedFlavourPrice)) +
                    double.parse(document['price'].toString());
              }
              selectedFlavourPrice = document['price'].toString();
              selectedAccessory = document['name'].toString().toLowerCase();
              flavourID = document['id'].toString();
              flavourName = document['name'].toString();
            }
          });
        },
        child: Center(
            child: Row(
          children: [
            SizedBox(
                height: 55,
                child: Container(
                    padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                    decoration: BoxDecoration(
                      color: selectedAccessory ==
                              document['name'].toString().toLowerCase()
                          ? Colors.yellow[800]
                          : Colors.transparent,
                      border: Border.all(color: Colors.orangeAccent),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              document['name'],
                              style: TextStyle(
                                  color: selectedAccessory ==
                                          document['name']
                                              .toString()
                                              .toLowerCase()
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.blueGrey[900],
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12),
                            )
                          ],
                        ),
                        Text('R' + document['price'].toString(),
                            style: TextStyle(
                                color: selectedAccessory ==
                                        document['name']
                                            .toString()
                                            .toLowerCase()
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.blueGrey[900],
                                fontWeight: FontWeight.w800,
                                fontSize: 14))
                      ],
                    ))),
            const SizedBox(
              width: 7,
            )
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.99),
      body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              actions: <Widget>[
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                    child: fav
                        ? IconButton(
                            icon: Icon(
                              Icons.favorite,
                              size: 20,
                              color: Colors.red[900],
                            ),
                            onPressed: () async {
                              if (signedIn) {
                                databaseReference
                                    .collection(userid + 'favourites')
                                    .doc(productID)
                                    .delete()
                                    .then((value) async {
                                  String databasesPath =
                                      await getDatabasesPath();
                                  String dbPath =
                                      Path.join(databasesPath, 'tables');

                                  Database database =
                                      await openDatabase(dbPath, version: 1);

                                  await database.transaction((txn) async {
                                    int id1 = await txn.rawDelete(
                                        'DELETE FROM favourites WHERE product_id = ?',
                                        [productID]);
                                  }).then((value) {
                                    setState(() {
                                      fav = false;
                                    });
                                  });
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        "Please login first to remove favourites",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black54,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            })
                        : IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              size: 20,
                              color: Colors.black54,
                            ),
                            onPressed: () async {
                              if (signedIn) {
                                databaseReference
                                    .collection(userid + 'favourites')
                                    .doc(productID)
                                    .set({
                                  'category': productCategory,
                                  'description': productDescription,
                                  'product_id': productID,
                                  'id': productID,
                                  'name': productName,
                                  'pic_url': picUrl,
                                  'price': productPrice,
                                }).then((_) async {
                                  String databasesPath =
                                      await getDatabasesPath();
                                  String dbPath =
                                      Path.join(databasesPath, 'tables');

                                  Database database =
                                      await openDatabase(dbPath, version: 1);

                                  await database.transaction((txn) async {
                                    int id1 = await txn.rawInsert(
                                        'INSERT INTO favourites(product_id) VALUES(?)',
                                        [
                                          productID,
                                        ]);
                                  }).then((value) {
                                    setState(() {
                                      fav = true;
                                    });
                                  });
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please login first to add favourites",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black54,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            })),
              ],
              pinned: true,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(
                color: Colors.black,
                size: 34,
              ),
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: GestureDetector(
                        onTap: () {},
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width,
                          child: CachedNetworkImage(
                            imageUrl: picUrl,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => const Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.grey,
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        )),
                  )),
              expandedHeight: 400,
            ),
            SliverList(
                delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.87,
                  child: Column(
                    children: [
                      productCategory == "shisha"
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      if (selectedMethod == "rent") {
                                        setState(() {
                                          total = (total -
                                                  double.parse(rentPrice)) +
                                              double.parse(productPrice);
                                        });
                                      }
                                      setState(() {
                                        selectedMethod = "buy";
                                      });
                                    },
                                    child: SizedBox(
                                        width: 150,
                                        height: 45,
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: selectedMethod == "buy"
                                                  ? Colors.yellow[800]
                                                  : Colors.transparent,
                                              border: Border.all(
                                                  color: Colors.orangeAccent),
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Text(
                                                  "Buy",
                                                  style: TextStyle(
                                                      color: selectedMethod ==
                                                              "buy"
                                                          ? Colors.white
                                                              .withOpacity(0.9)
                                                          : Colors
                                                              .blueGrey[900],
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 12),
                                                )
                                              ],
                                            )))),
                                //const SizedBox(width: 20,),
                                GestureDetector(
                                    onTap: () {
                                      if (selectedMethod == "buy") {
                                        setState(() {
                                          total = (total -
                                                  double.parse(productPrice)) +
                                              double.parse(rentPrice);
                                        });
                                      }
                                      setState(() {
                                        selectedMethod = "rent";
                                      });
                                    },
                                    child: SizedBox(
                                        width: 150,
                                        height: 45,
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: selectedMethod == "rent"
                                                  ? Colors.yellow[800]
                                                  : Colors.transparent,
                                              border: Border.all(
                                                  color: Colors.orangeAccent),
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Text(
                                                  "Rent",
                                                  style: TextStyle(
                                                      color: selectedMethod ==
                                                              "rent"
                                                          ? Colors.white
                                                              .withOpacity(0.9)
                                                          : Colors
                                                              .blueGrey[900],
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 12),
                                                )
                                              ],
                                            )))),
                              ],
                            )
                          : productCategory == 'cigars'
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          if (selectedCigar == "box") {
                                            setState(() {
                                              total = (total -
                                                      double.parse(boxPrice)) +
                                                  double.parse(productPrice);
                                            });
                                          }
                                          setState(() {
                                            selectedCigar = "cigar";
                                          });
                                        },
                                        child: SizedBox(
                                            width: 150,
                                            height: 45,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      selectedCigar == "cigar"
                                                          ? Colors.yellow[800]
                                                          : Colors.transparent,
                                                  border: Border.all(
                                                      color:
                                                          Colors.orangeAccent),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: <Widget>[
                                                    Text(
                                                      "Cigar",
                                                      style: TextStyle(
                                                          color: selectedCigar ==
                                                                  "cigar"
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                      0.9)
                                                              : Colors.blueGrey[
                                                                  900],
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: 12),
                                                    )
                                                  ],
                                                )))),
                                    //const SizedBox(width: 20,),
                                    GestureDetector(
                                        onTap: () {
                                          if (selectedCigar == "cigar") {
                                            setState(() {
                                              total = (total -
                                                      double.parse(
                                                          productPrice)) +
                                                  double.parse(boxPrice);
                                            });
                                          }
                                          setState(() {
                                            selectedCigar = "box";
                                          });
                                        },
                                        child: SizedBox(
                                            width: 150,
                                            height: 45,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: selectedCigar == "box"
                                                      ? Colors.yellow[800]
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                      color:
                                                          Colors.orangeAccent),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: <Widget>[
                                                    Text(
                                                      "Box",
                                                      style: TextStyle(
                                                          color: selectedCigar ==
                                                                  "box"
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                      0.9)
                                                              : Colors.blueGrey[
                                                                  900],
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: 12),
                                                    )
                                                  ],
                                                )))),
                                  ],
                                )
                              : Container(),
                      const SizedBox(height: 25),
                      productCategory == 'cigars'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  productName,
                                  style: TextStyle(
                                      color: Colors.blueGrey[600],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                selectedCigar == "cigar"
                                    ? Text('R' + productPrice,
                                        style: TextStyle(
                                            color: Colors.yellow[800],
                                            fontWeight: FontWeight.w900,
                                            fontSize: 19))
                                    : Text('R' + boxPrice,
                                        style: TextStyle(
                                            color: Colors.yellow[800],
                                            fontWeight: FontWeight.w900,
                                            fontSize: 19))
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  productName,
                                  style: TextStyle(
                                      color: Colors.blueGrey[600],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                selectedMethod == "buy"
                                    ? Text('R' + productPrice,
                                        style: TextStyle(
                                            color: Colors.yellow[800],
                                            fontWeight: FontWeight.w900,
                                            fontSize: 19))
                                    : Text('R' + rentPrice,
                                        style: TextStyle(
                                            color: Colors.yellow[800],
                                            fontWeight: FontWeight.w900,
                                            fontSize: 19))
                              ],
                            ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Text(productDescription,
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      productCategory == 'shisha'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const [
                                Text(
                                  'Select Flavor',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.arrow_right_alt_rounded,
                                  size: 25,
                                )
                              ],
                            )
                          : Container(),
                      productCategory == 'shisha'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 70,
                                  width:
                                      MediaQuery.of(context).size.width * 0.86,
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('ShishaFlavours')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: Text('....'),
                                        );
                                      } else {
                                        return snapshot.data!.docs.isEmpty
                                            ? const Center(
                                                child: Text(
                                                '',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    //fontStyle: FontStyle.italic,
                                                    fontSize: 16),
                                              ))
                                            : ListView.builder(
                                                itemBuilder: (context, index) =>
                                                    buildAccessories(
                                                        context,
                                                        snapshot
                                                            .data!.docs[index]),
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                //itemExtent: 140,
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                              );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(height: 15),
                      productCategory == 'shisha'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const [
                                Text(
                                  'Select Charcoal',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.arrow_right_alt_rounded,
                                  size: 25,
                                )
                              ],
                            )
                          : Container(),
                      productCategory == 'shisha'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 70,
                                  width:
                                      MediaQuery.of(context).size.width * 0.86,
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Charcoals')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: Text('....'),
                                        );
                                      } else {
                                        return snapshot.data!.docs.isEmpty
                                            ? const Center(
                                                child: Text(
                                                '',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    //fontStyle: FontStyle.italic,
                                                    fontSize: 16),
                                              ))
                                            : ListView.builder(
                                                itemBuilder: (context, index) =>
                                                    buildCharcoal(
                                                        context,
                                                        snapshot
                                                            .data!.docs[index]),
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                //itemExtent: 140,
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                              );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ]))
          ]),
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
                    child: !isInCart
                        ? ElevatedButton(
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
                              'Add to Cart (R' + total.toString() + ')',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              showLoader(context);
                              try {
                                String databasesPath = await getDatabasesPath();
                                String dbPath =
                                    Path.join(databasesPath, 'tables');

                                Database database =
                                    await openDatabase(dbPath, version: 1);

                                if (productCategory == 'shisha') {
                                  await database.transaction((txn) async {
                                    await txn.rawInsert(
                                        'INSERT INTO cart(product_id, productName, productPrice, productPic, flavourName, flavourPrice, flavour_id, charcoalName, charcoalPrice, charcoal_id, total_price, selectedMethod) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)',
                                        [
                                          productID,
                                          productName,
                                          selectedMethod == 'buy'
                                              ? productPrice
                                              : rentPrice,
                                          picUrl,
                                          flavourName,
                                          selectedFlavourPrice,
                                          flavourID,
                                          charcoalName,
                                          selectedCharcoalPrice,
                                          charcoalID,
                                          total.toString(),
                                          selectedMethod
                                        ]);
                                  }).then((value) {
                                    setState(() {
                                      isInCart = true;
                                    });
                                  });
                                } else if (productCategory == 'cigars') {
                                  await database.transaction((txn) async {
                                    await txn.rawInsert(
                                        'INSERT INTO cart(product_id, productName, productPrice, productPic, flavourName, flavourPrice, flavour_id, charcoalName, charcoalPrice, charcoal_id, total_price, selectedMethod) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)',
                                        [
                                          productID,
                                          productName,
                                          selectedCigar == 'cigar'
                                              ? productPrice
                                              : boxPrice,
                                          picUrl,
                                          flavourName,
                                          selectedFlavourPrice,
                                          flavourID,
                                          charcoalName,
                                          selectedCharcoalPrice,
                                          charcoalID,
                                          total.toString(),
                                          selectedMethod
                                        ]);
                                  }).then((value) {
                                    setState(() {
                                      isInCart = true;
                                    });
                                  });
                                } else {
                                  await database.transaction((txn) async {
                                    await txn.rawInsert(
                                        'INSERT INTO cart(product_id, productName, productPrice, productPic, flavourName, flavourPrice, flavour_id, charcoalName, charcoalPrice, charcoal_id, total_price, selectedMethod) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)',
                                        [
                                          productID,
                                          productName,
                                          productPrice,
                                          picUrl,
                                          flavourName,
                                          selectedFlavourPrice,
                                          flavourID,
                                          charcoalName,
                                          selectedCharcoalPrice,
                                          charcoalID,
                                          total.toString(),
                                          selectedMethod
                                        ]);
                                  }).then((value) {
                                    setState(() {
                                      isInCart = true;
                                    });
                                  });
                                }
                                dismissLoader();
                                print(isInCart);
                              } catch (e) {
                                print(e.toString());
                                dismissLoader();
                                if ((e.toString().toLowerCase())
                                    .contains('unique')) {
                                  Fluttertoast.showToast(
                                      msg: "Product already added to cart",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black54,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              }
                              updateCartCount();
                            },
                          )
                        : ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green[700]),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            child: Text(
                              'PROCEED TO CHECKOUT',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          checkoutPage()));
                            },
                          ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
              )
            ],
          )),
      /*floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.blueGrey[900],
        onPressed: (){},
      child: Center(child:SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          children: [
            const Positioned(
                top: 11,
                right: 8,
                child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 30,color: Colors.white
                    )),
            Positioned(
                bottom: 30,
                right: 5,
                child: Container(
                  width: 25,
                  height: 25,
                  child: Center(child:Text(cartItems.toString(), style: const TextStyle(color: Colors.white, fontSize: 12,fontWeight: FontWeight.bold),)),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                ))
          ],
        ),
      )),
    ),*/
    );
  }
}
