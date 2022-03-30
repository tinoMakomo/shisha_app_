import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shisha_app/pages/login.dart';
import 'package:shisha_app/pages/myProfile.dart';
import 'package:shisha_app/pages/notifications.dart';
import 'package:shisha_app/pages/signUp.dart';
import 'package:shisha_app/pages/viewCategory.dart';
import 'package:shisha_app/pages/viewProduct.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
import 'checkout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future initialiseFirebase() async {
    await Firebase.initializeApp();
  }

  String selectedCategory = "";
  String selectedCategoryRaw = "";
  String iconUrl = "";
  int currentPage = 1;
  int cartItems = 1;
  bool signedIn = false;
  String userid = "";

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
    getId();
    setState(() {
      selectedCategory = "shisha";
      selectedCategoryRaw = "Shisha";
    });
    super.initState();
  }

  checkFavs(proId) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = Path.join(databasesPath, 'tables');

    Database database = await openDatabase(dbPath, version: 1);

    var result = await database.rawQuery('SELECT * FROM favourites WHERE product_id = ?',
        [proId]);
    return result;
  }


  Widget buildCategories(BuildContext context, DocumentSnapshot document) {
    return GestureDetector(
        onTap: () {
          /*Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => ViewCategory(document['name'], document['icon_url']
              )));*/
          setState(() {
            selectedCategory = document['name'].toString().toLowerCase();
            iconUrl = document['icon_url'].toString().toLowerCase();
            selectedCategoryRaw = document['name'].toString();
          });
        },
        child: Center(
            child: Row(
          children: [
            SizedBox(
                width: 130,
                height: 45,
                child: Container(
                    decoration: BoxDecoration(
                      color: selectedCategory ==
                              document['name'].toString().toLowerCase()
                          ? Colors.yellow[800]
                          : Colors.transparent,
                      border: Border.all(color: Colors.orangeAccent),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: 40,
                          height: 40,
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
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        Text(
                          document['name'],
                          style: TextStyle(
                              color: selectedCategory ==
                                      document['name'].toString().toLowerCase()
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.blueGrey[900],
                              fontWeight: FontWeight.w800),
                        )
                      ],
                    ))),
            const SizedBox(
              width: 1,
            )
          ],
        )));
  }

  Widget buildSpecials(BuildContext context, DocumentSnapshot document) {
     var isFav = checkFavs(document['id']);
     print(isFav);
    return GestureDetector(
        onTap: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => ViewProduct(document['id']
              )));
        },
        child: Center(
            child: Row(
              children: [
                Card(
                    color: Colors.white,
                    elevation: 2,
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 140,
                        height: 220,
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                                top: 15,
                                left: 15,
                                child: Center(
                                    child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (BuildContext context) => ViewProduct(document['id']
                                              )));
                                        },
                                        child: SizedBox(
                                          width: 110,
                                          height: 110,
                                          child: CachedNetworkImage(
                                            imageUrl: document["pic_url"],
                                            imageBuilder: (context, imageProvider) =>
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(7),
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
                                            errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                          ),
                                        )))),
                            Positioned(
                              top: 135,
                              left: 16,
                              child: Text(
                                '${document['name']}',
                                style: TextStyle(
                                    color: Colors.blueGrey[800],
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5),
                              ),
                            ),
                            Positioned(
                                top: 156,
                                left: 16.5,
                                child: Text(
                                  'R${document['price']}',
                                  style: TextStyle(
                                      color: Colors.yellow[800],
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14),
                                )),
                            Positioned(
                                top: 5,
                                right: 9,
                                child:  Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  height: 35,
                                  width: 35,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    elevation: 0,
                                    color: Colors.white,
                                    child: Icon(
                                      Icons.favorite,
                                      color: isFav == "[]"? Colors.black45 : Colors.pink,
                                      size: 15,
                                    ),
                                  ),
                                )),

                            Positioned(
                                bottom: 2,
                                right: 2,
                                child:  GestureDetector(
                                    onTap: (){
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (BuildContext context) => ViewProduct(document['id']
                                          )));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      height: 35,
                                      width: 35,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        elevation: 1,
                                        color: Colors.black,
                                        child: const Icon(
                                          Icons.shopping_bag_outlined,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ))),
                          ],
                        ))),
                const SizedBox(
                  width: 12,
                )
              ],
            )));
  }

  Widget buildNewOffers(BuildContext context, DocumentSnapshot document) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => ViewProduct(document['id']
              )));
      },
    child: Center(
        child: Row(
      children: [
        Card(
            color: Colors.grey[100],
            elevation: 0,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(0.2)),
                ),
                width: 140,
                height: 220,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        top: 15,
                        left: 15,
                        child: Center(
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (BuildContext context) => ViewProduct(document['id']
                                      )));
                                },
                                child: SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: CachedNetworkImage(
                                    imageUrl: document["pic_url"],
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
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
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                )))),
                    Positioned(
                      top: 135,
                      left: 16,
                      child: Text(
                        '${document['name']}',
                        style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5),
                      ),
                    ),
                    Positioned(
                        top: 156,
                        left: 16.5,
                        child: Text(
                          'R${document['price']}',
                          style: TextStyle(
                              color: Colors.yellow[800],
                              fontWeight: FontWeight.w800,
                              fontSize: 14),
                        )),
                    Positioned(
                        top: 5,
                        right: 9,
                        child:  Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          height: 35,
                          width: 35,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 1,
                            color: Colors.white,
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.black45,
                                size: 15,
                              ),
                          ),
                        )),

                    Positioned(
                        bottom: 0,
                        right: 0,
                        child:  GestureDetector(
                            onTap: (){
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (BuildContext context) => ViewProduct(document['id']
                                  )));
                            },
                            child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          height: 35,
                          width: 35,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 1,
                            color: Colors.black,
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ))),
                  ],
                ))),
        const SizedBox(
          width: 12,
        )
      ],
    )));
  }

  Widget buildPopularOffers(BuildContext context, DocumentSnapshot document) {
    return Center(
        child:Column(children: [
        Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.white,
                elevation: 0.4,
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width*0.88,
                    height: 180,
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                            top: 15,
                            left: 15,
                            child: Center(
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (BuildContext context) => ViewProduct(document['id']
                                          )));
                                    },
                                    child: SizedBox(
                                      width: 145,
                                      height: 150,
                                      child: CachedNetworkImage(
                                        imageUrl: document["pic_url"],
                                        imageBuilder: (context, imageProvider) =>
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(7),
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
                                        errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                      ),
                                    )))),
                        Positioned(
                          top: 25,
                          left: 176,
                          child: Text(
                            '${document['name']}',
                            style: TextStyle(
                                color: Colors.blueGrey[800],
                                fontWeight: FontWeight.w800,
                                fontSize: 16),
                          ),
                        ),
                        Positioned(
                          top: 55,
                          left: 176,
                          child:SizedBox(
                            width: 120,
                            child: Text(
                            '${document['description']}',
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                                fontSize: 13.5),
                          ),) ,
                        ),
                        Positioned(
                            bottom: 15,
                            left: 176,
                            child: Text(
                              'R${document['price']}',
                              style: TextStyle(
                                  color: Colors.yellow[800],
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15),
                            )),
                        Positioned(
                            top: 5,
                            left: 125,
                            child:  Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              height: 35,
                              width: 35,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                elevation: 1,
                                color: Colors.white,
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.black45,
                                  size: 15,
                                ),
                              ),
                            )),

                        Positioned(
                            bottom: 8,
                            right: 8,
                            child:  GestureDetector(
                                onTap: (){
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (BuildContext context) => ViewProduct(document['id']
                                      )));
                                },
                                child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              height: 35,
                              width: 55,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 1,
                                color: Colors.black,
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ))),
                      ],
                    ))),
          const SizedBox(
            height: 10,
          )
        ],)
           );
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
     /* GestureDetector(
          onTap: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => ViewCategory('Shisha', iconUrl
                )));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent,
              image: const DecorationImage(
                image: AssetImage('assets/images/adv3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          )), */
      GestureDetector(
          onTap: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => ViewCategory('Cigars', iconUrl
                )));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent,
              image: const DecorationImage(
                image: AssetImage('assets/images/adv4.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          )
      ),
      GestureDetector(
        onTap: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => ViewCategory('Alcohol', iconUrl
              )));
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
            image: const DecorationImage(
              image: AssetImage('assets/images/adv5.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      )
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white.withOpacity(0.97),
      bottomNavigationBar:  BottomAppBar(
        elevation: 0.3,
        shape: const CircularNotchedRectangle(),
        notchMargin: 12,
        color: Colors.white,
        child: SizedBox(
          height: 63,
            child:Row(
              children: [

                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 63,

                  child: Card(
                    elevation: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              currentPage = 1;
                            });
                          },
                          child:  SizedBox(
                            height: 60,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.home
                                  ,size: 26,color: currentPage == 1? Colors.yellow[800] : Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                        cartItems == 0 ?GestureDetector(
                          onTap: (){
                            setState(() {
                              currentPage = 2;
                            });
                          },
                          child:  SizedBox(
                            height: 60,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.shopping_cart
                                  ,size: 26,color: currentPage == 2? Colors.yellow[800] : Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ): GestureDetector(
                            onTap: (){

                            },
                            child:SizedBox(
                              width: 35,
                              height: 47,
                              child: Stack(
                                children: [
                                  Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                          onPressed: () => {
                                          Navigator.push(context,
                                          MaterialPageRoute(builder: (BuildContext context) => checkoutPage()))
                                          },
                                          icon: Icon(
                                            Icons.shopping_cart,
                                            size: 26,color: currentPage == 2? Colors.yellow[800] : Colors.black45,
                                          ))),
                                ],
                              ),
                            )),
                        GestureDetector(
                          onTap: (){
                            if(signedIn) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (BuildContext context) => ViewCategory('Favourites', ''
                                  )));
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please login to save your favourites.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black54,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          loginPage()));
                            }
                          },
                          child:  SizedBox(
                            height: 60,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.favorite
                                  ,size: 26,color: currentPage == 3? Colors.yellow[800] : Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            if(signedIn) {
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          mySettings()));
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please login to view your profile.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black54,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          loginPage()));
                            }
                          },
                          child:  SizedBox(
                            height: 60,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.person
                                  ,size: 26, color:currentPage == 4? Colors.yellow[800] : Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: Center(
            child: SizedBox(
                height: 46,
                width: MediaQuery.of(context).size.width,
                child: Card(
                    elevation: 0.4,
                    child: TextField(
                      decoration: InputDecoration(
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: const BorderSide(
                                color: Colors.white, width: 0.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: const BorderSide(
                                color: Colors.white, width: 0.0),
                          ),
                          filled: true,
                          labelStyle: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                          labelText: "Search for products",
                          fillColor: Colors.white),
                    )))),
        elevation: 0.3,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          SizedBox(
            width: 35,
            height: 30,
            child: Stack(
              children: [
                Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                        onPressed: () => {
                        Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) => notices()))
                            },
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          size: 25,
                        ))),
                Positioned(
                    top: 9,
                    right: 13,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                    ))
              ],
            ),
          )
        ],
      ),
      body: Center(
        child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Container(width: 100,
                                height: 110,
                                decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                    //shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/logo1.png'),
                                        fit: BoxFit.fitWidth)),

                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.54,
                                child:  Text(
                                  'All your Alcohol, Smoke Products and Accessories',
                                  style: TextStyle(
                                      color: Colors.blueGrey[700],
                                      fontWeight: FontWeight.w500),
                                ) ,
                              )

                            ],
                          ),

                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width*0.9,
                      child:
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Specials',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[800]),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Row(
                              children: const [
                                Icon(Icons.arrow_right_alt,size: 28,)
                              ],
                            ),
                          ],
                        ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        width:
                        MediaQuery.of(context).size.width * 0.9,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Products')
                              .where('category', isEqualTo: selectedCategory.toLowerCase())
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
                                itemBuilder:
                                    (context, index) =>
                                    buildSpecials(
                                        context,
                                        snapshot.data!
                                            .docs[index]),
                                itemCount: snapshot
                                    .data!.docs.length,
                                itemExtent: 170,
                                shrinkWrap: true,
                                scrollDirection:
                                Axis.horizontal,
                              );
                            }
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 28,
                  ),

                  Center(
                    child: SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width * 0.93,
                      child: CarouselSlider(
                          items: _children,
                          options: CarouselOptions(
                            height: 400,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.97,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 10),
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 1000),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                          )),
                    ),
                  ),
                  Center(
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 28,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Categories',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[800]),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Row(
                                    children: const [
                                      Icon(Icons.arrow_right_alt,size: 28,)
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 70,
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('Categories')
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
                                                  itemBuilder:
                                                      (context, index) =>
                                                          buildCategories(
                                                              context,
                                                              snapshot.data!
                                                                  .docs[index]),
                                                  itemCount: snapshot
                                                      .data!.docs.length,
                                                  itemExtent: 140,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 17,
                              ),

                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context,
                                     MaterialPageRoute(builder: (BuildContext context) => ViewCategory(selectedCategory, iconUrl
                                    )));
                                },
                              child:Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedCategoryRaw,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[800]),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'View all ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.yellow[800]),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_sharp,size: 20,)
                                    ],
                                  ),
                                ],
                              )),
                              const SizedBox(
                                height: 19,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('Products')
                                          .where('category', isEqualTo: selectedCategory.toLowerCase())
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
                                                  itemBuilder:
                                                      (context, index) =>
                                                          buildNewOffers(
                                                              context,
                                                              snapshot.data!
                                                                  .docs[index]),
                                                  itemCount: snapshot
                                                      .data!.docs.length,
                                                  itemExtent: 170,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                );
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 28,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Popular',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[800]),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (BuildContext context) => ViewCategory('Favourites', ''
                                          )));
                                    },
                                  child:Row(
                                    children: [
                                      Text(
                                        'View all ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.yellow[800]),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_sharp,size: 20,)
                                    ],
                                  )
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 23,
                              ),
                              SizedBox(
                                  height: 200,
                                  width:
                                  MediaQuery.of(context).size.width * 0.9,
                              child:StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Products')
                                   // .where('category', isEqualTo: selectedCategory.toLowerCase())
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
                                      itemBuilder:
                                          (context, index) =>
                                          buildNewOffers(
                                              context,
                                              snapshot.data!
                                                  .docs[index]),
                                      itemCount: snapshot
                                          .data!.docs.length,
                                      itemExtent: 170,
                                      shrinkWrap: true,
                                      scrollDirection:
                                      Axis.horizontal,
                                    );
                                  }
                                },
                              )
      ),
                            ],
                          ))),
                  const SizedBox(
                    height: 90,
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
