import 'package:firestore_search/firestore_search.dart';
import 'package:flutter/material.dart';
import 'package:shisha_app/pages/viewProduct.dart';

import '../utils/dataModel.dart';

class SearchPage extends StatefulWidget {
  @override
  searchPageState createState() => searchPageState();
}

class searchPageState extends State<SearchPage> {
  Future<bool> _willPopCallback() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: FirestoreSearchScaffold(
        appBarBackgroundColor: Colors.yellow[700],
        backButtonColor: Colors.yellow[700],
        firestoreCollectionName: 'Products',
        searchBy: 'name',
        scaffoldBody: Center(),
        dataListFromSnapshot: DataModel().dataListFromSnapshot,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<DataModel>? dataList = snapshot.data;
            if (dataList!.isEmpty) {
              return const Center(
                child: Text('No Results Returned'),
              );
            }
            return ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  final DataModel data = dataList[index];

                  return GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ViewProduct(data.id!)));
                  },
                      child:Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${data.name}',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8.0, left: 8.0, right: 8.0),
                        child: Text('${data.description}',
                            style: Theme.of(context).textTheme.bodyText1),
                      )
                    ],
                  ));
                })
            ;
          }

          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text('No Results Returned'),
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
