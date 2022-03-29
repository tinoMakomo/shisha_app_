import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shisha_app/pages/viewProduct.dart';

class ViewCategory extends StatefulWidget {
  String category;
  String iconUrl;

  ViewCategory(this.category,this.iconUrl, {Key? key}) : super(key: key);

  @override
  State<ViewCategory> createState() => _ViewCategoryState(category, iconUrl);
}

class _ViewCategoryState extends State<ViewCategory> {
  String category;
  String iconUrl;
  _ViewCategoryState(this.category,this.iconUrl);

  Widget buildCategoryTiles(BuildContext context, DocumentSnapshot document) {
    return  Center(
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width*0.47,
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
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (BuildContext context) => ViewProduct(document['id']
                                      )));
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width*0.44,
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
                              child:Text(
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
                                  color: Colors.blueGrey[300],
                                  fontSize: 10),
                            )
                            ,)
                        ],
                      )
                    ),

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
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (BuildContext context) => ViewProduct(document['id']
                                    )));
                              },
                            ),
                          ),
                        )),
                  ],
                ))),
          ],));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4, child:Scaffold(
      backgroundColor: Colors.white.withOpacity(0.97),
      appBar: AppBar(
        bottom:  TabBar(
         // indicatorSize: TabBarIndicatorSize.values.,
          indicatorColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.blueGrey[900],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold
          ),
          unselectedLabelColor:Colors.black26,
          tabs: const [
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
        title:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          SizedBox(
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
              const Icon(Icons.error),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Text(category, style: TextStyle(color: Colors.blueGrey[800]),),
        ],),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white.withOpacity(0.97),
        iconTheme: const IconThemeData(color: Colors.black,),
        actions: [

          const SizedBox(width: 15,),
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
                          //put button execution code
                        },
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          size: 25,
                        ))),
                Positioned(
                    top: 9,
                    right: 14,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                    ))
              ],
            ),
          ),
        ],
      ),
      body:  TabBarView(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child:  StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Products')
                    .where('category', isEqualTo: category.toLowerCase())
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
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          )
        ],
      )
    )
    );
  }
}