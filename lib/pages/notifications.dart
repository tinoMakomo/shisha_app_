import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shisha_app/pages/login.dart';
import 'package:uuid/uuid.dart';

class notices extends StatefulWidget {
  @override
  noticesState createState() => noticesState();
}

class noticesState extends State<notices> {
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
  dismissimages() {
    try {
      setState(() {
        isViewimages = false;
      });
    } catch (ex) {}
  }

  var uuid = Uuid();

  Widget buildMessages(BuildContext context, DocumentSnapshot document) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  //height: MediaQuery.of(context).size.height*0.2,
                  child:
                      Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[

                      const SizedBox(
                        width: 3,
                      ),
                      Flexible(
                          child: GestureDetector(
                              onTap: (){
                                if(!signedIn){
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (BuildContext context) => loginPage()));
                                }
                              },
                              child: Container(
                              padding:
                              const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8.0)),
                              margin:
                              EdgeInsets.only(bottom: 10.0, right: 10.0),
                              child: Text(
                                document['message'],
                                style: TextStyle(color: Colors.black),
                                textAlign: TextAlign.left,
                              )))),

                    ],
                  )
              )),
          //Text(date.year.toString()+'-'+date.month.toString()+'-'+date.day.toString()),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
          )
        ]);
  }

  final Controller = TextEditingController();
  bool isViewimages=false;

  setcriteria() {
    print(Controller.text);
  }

  String uname = '';


  @override
  void initState() {
    getId();
    bool isvisible = false;
    Controller.text = '';
    Controller.addListener(setcriteria);
    setState(() {
    });

    super.initState();
  }


  Future<bool> _willPopCallback() async {

    if(isViewimages==false) {
      return true;
    }else{
      dismissimages();
      return false;

    }
    // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    bool isvisible = MediaQuery.of(context).viewInsets.vertical > 0;
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0.5,
              title: const Text(
                'Notifications',
                style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.w600),
              ),
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: Colors.yellow[800],
              actions: <Widget>[
                Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    // height: 10,
                    width: 57,
                    child:Container(width: 57,

                      decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/logo1.png'),
                              fit: BoxFit.contain)),

                    )),
                const SizedBox(width: 50,)
              ],
            ),
            body:SingleChildScrollView(
              // height:MediaQuery.of(context).size.height,

                child: Column(children: <Widget>[

                  Container(
                      height: MediaQuery.of(context).size.height * 0.88,
                      width: MediaQuery.of(context).size.width,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: signedIn? FirebaseFirestore.instance
                            .collection( userid+'notices')
                            .orderBy('createdAt', descending: true)
                            .snapshots():

                            FirebaseFirestore.instance
                            .collection('signUpNotice')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return snapshot.data!.docs.isEmpty
                                ? const Center()
                                : ListView.builder(
                              itemBuilder: (context, index) =>
                                  buildMessages(context,
                                      snapshot.data!.docs[index]),
                              itemCount:
                              snapshot.data?.docs.length,
                              itemExtent: null,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,

                              padding: EdgeInsets.all(10.0),
                            );
                          }
                        },
                      )
                  ),

                  SizedBox(height: 80,),
                ]))));
  }
}