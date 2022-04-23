import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shisha_app/pages/viewProduct.dart';

class ViewCategory extends StatefulWidget {
  String category;
  String iconUrl;

  ViewCategory(this.category, this.iconUrl, {Key? key}) : super(key: key);

  @override
  State<ViewCategory> createState() => _ViewCategoryState(category, iconUrl);
}

class _ViewCategoryState extends State<ViewCategory> {
  String category;
  String iconUrl;
  _ViewCategoryState(this.category, this.iconUrl);

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
    super.initState();
  }

  Widget buildCategoryTiles(BuildContext context, DocumentSnapshot document) {
    return Center(
        child: Row(
      children: [
        Container(
            width: MediaQuery.of(context).size.width * 0.47,
            color: Colors.transparent,
            child: Card(
                elevation: 3,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        top: 10,
                        left: 0,
                        child: Center(
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ViewProduct(document['id'])));
                                },
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.44,
                                  height: 130,
                                  child: CachedNetworkImage(
                                    imageUrl: document["pic_url"],
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
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
                        top: 150,
                        left: 10,
                        child: Column(
                          children: [
                            SizedBox(
                                width: 150,
                                child: Text(
                                  '${document['name']}',
                                  style: TextStyle(
                                      color: Colors.blueGrey[900],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.5),
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: 150,
                              child: Text(
                                '${document['description']}',
                                style: TextStyle(
                                    color: Colors.blueGrey[300], fontSize: 10),
                              ),
                            )
                          ],
                        )),
                    Positioned(
                        bottom: 15,
                        left: 10,
                        child: Text(
                          'R${document['price']}',
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontWeight: FontWeight.w800,
                              fontSize: 17),
                        )),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: SizedBox(
                          height: 53,
                          width: 53,
                          child: Card(
                            elevation: 0,
                            child: IconButton(
                              icon: Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.red[900],
                                size: 25,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ViewProduct(document['id'])));
                              },
                            ),
                          ),
                        )),
                  ],
                ))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: category.toLowerCase() == 'favourites' ||
                category.toLowerCase() == 'popular'
            ? 1
            : 4,
        child: Scaffold(
            backgroundColor: Colors.white.withOpacity(0.97),
            appBar: AppBar(
              bottom: TabBar(
                // indicatorSize: TabBarIndicatorSize.values.,
                indicatorColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.blueGrey[900],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.black26,
                tabs: category.toLowerCase() == 'alcohol'
                    ? const [
                        Tab(
                          text: "All",
                        ),
                        Tab(
                          text: "Beer",
                        ),
                        Tab(
                          text: "Ciders",
                        ),
                        Tab(
                          text: "Spirits",
                        ),
                      ]
                    : category.toLowerCase() == 'favourites'
                        ? const [
                            Tab(
                              text: "My Favourites",
                            )
                          ]
                        : category.toLowerCase() == 'popular'
                            ? const [
                                Tab(
                                  text: "Popular Products",
                                )
                              ]
                            : const [
                                Tab(
                                  text: "All",
                                ),
                                Tab(
                                  text: "On Sale",
                                ),
                                Tab(
                                  text: "Popular",
                                ),
                                Tab(
                                  text: "Exclusive",
                                ),
                              ],
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  category.toLowerCase() != 'favourites' ||
                          category != 'popular'
                      ? SizedBox(
                          width: 30,
                          height: 30,
                          child: CachedNetworkImage(
                            imageUrl: iconUrl,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => const Text(''),
                            errorWidget: (context, url, error) =>
                                const Text(""),
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    category,
                    style: TextStyle(color: Colors.blueGrey[800]),
                  ),
                ],
              ),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_outlined,
                    color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Colors.white.withOpacity(0.97),
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              actions: [
                const SizedBox(
                  width: 15,
                ),
              ],
            ),
            body: category.toLowerCase() == 'alcohol'
                ? TabBarView(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Products')
                                .where('category',
                                    isEqualTo: category.toLowerCase())
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: Text(''),
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
                                    : GridView.builder(
                                        itemBuilder: (context, index) =>
                                            buildCategoryTiles(context,
                                                snapshot.data!.docs[index]),
                                        itemCount: snapshot.data!.docs.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 10,
                                          mainAxisExtent: 260,
                                        ),
                                      );
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Products')
                                .where('category',
                                    isEqualTo: category.toLowerCase())
                                .where('type', isEqualTo: 'beer')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: Text(''),
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
                                    : GridView.builder(
                                        itemBuilder: (context, index) =>
                                            buildCategoryTiles(context,
                                                snapshot.data!.docs[index]),
                                        itemCount: snapshot.data!.docs.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 10,
                                          mainAxisExtent: 260,
                                        ),
                                      );
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Products')
                                .where('category',
                                    isEqualTo: category.toLowerCase())
                                .where('type', isEqualTo: 'cider')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: Text(''),
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
                                    : GridView.builder(
                                        itemBuilder: (context, index) =>
                                            buildCategoryTiles(context,
                                                snapshot.data!.docs[index]),
                                        itemCount: snapshot.data!.docs.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 10,
                                          mainAxisExtent: 260,
                                        ),
                                      );
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Products')
                                .where('category',
                                    isEqualTo: category.toLowerCase())
                                .where('type', isEqualTo: 'spirit')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: Text(''),
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
                                    : GridView.builder(
                                        itemBuilder: (context, index) =>
                                            buildCategoryTiles(context,
                                                snapshot.data!.docs[index]),
                                        itemCount: snapshot.data!.docs.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 10,
                                          mainAxisExtent: 260,
                                        ),
                                      );
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  )
                : category.toLowerCase() == 'favourites'
                    ? TabBarView(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: SingleChildScrollView(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection(userid + 'favourites')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: Text(''),
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
                                        : GridView.builder(
                                            itemBuilder: (context, index) =>
                                                buildCategoryTiles(context,
                                                    snapshot.data!.docs[index]),
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 5,
                                              mainAxisSpacing: 10,
                                              mainAxisExtent: 260,
                                            ),
                                          );
                                  }
                                },
                              ),
                            ),
                          )
                        ],
                      )
                    : category.toLowerCase() == 'popular'
                        ? TabBarView(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: SingleChildScrollView(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Products')
                                        .where('popular', isEqualTo: true)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: Text(''),
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
                                            : GridView.builder(
                                                itemBuilder: (context, index) =>
                                                    buildCategoryTiles(
                                                        context,
                                                        snapshot
                                                            .data!.docs[index]),
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 5,
                                                  mainAxisSpacing: 10,
                                                  mainAxisExtent: 260,
                                                ),
                                              );
                                      }
                                    },
                                  ),
                                ),
                              )
                            ],
                          )
                        : TabBarView(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: SingleChildScrollView(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Products')
                                        .where('category',
                                            isEqualTo: category.toLowerCase())
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: Text(''),
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
                                            : GridView.builder(
                                                itemBuilder: (context, index) =>
                                                    buildCategoryTiles(
                                                        context,
                                                        snapshot
                                                            .data!.docs[index]),
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 5,
                                                  mainAxisSpacing: 10,
                                                  mainAxisExtent: 260,
                                                ),
                                              );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: SingleChildScrollView(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Products')
                                        .where('category',
                                            isEqualTo: category.toLowerCase())
                                        .where('type', isEqualTo: 'sale')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: Text(''),
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
                                            : GridView.builder(
                                                itemBuilder: (context, index) =>
                                                    buildCategoryTiles(
                                                        context,
                                                        snapshot
                                                            .data!.docs[index]),
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 5,
                                                  mainAxisSpacing: 10,
                                                  mainAxisExtent: 260,
                                                ),
                                              );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: SingleChildScrollView(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Products')
                                        .where('category',
                                            isEqualTo: category.toLowerCase())
                                        .where('popular', isEqualTo: true)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: Text(''),
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
                                            : GridView.builder(
                                                itemBuilder: (context, index) =>
                                                    buildCategoryTiles(
                                                        context,
                                                        snapshot
                                                            .data!.docs[index]),
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 5,
                                                  mainAxisSpacing: 10,
                                                  mainAxisExtent: 260,
                                                ),
                                              );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: SingleChildScrollView(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Products')
                                        .where('category',
                                            isEqualTo: category.toLowerCase())
                                        .where('type', isEqualTo: 'exclusive')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: Text(''),
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
                                            : GridView.builder(
                                                itemBuilder: (context, index) =>
                                                    buildCategoryTiles(
                                                        context,
                                                        snapshot
                                                            .data!.docs[index]),
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 5,
                                                  mainAxisSpacing: 10,
                                                  mainAxisExtent: 260,
                                                ),
                                              );
                                      }
                                    },
                                  ),
                                ),
                              )
                            ],
                          )));
  }
}
