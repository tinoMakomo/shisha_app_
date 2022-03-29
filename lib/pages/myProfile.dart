import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shisha_app/pages/signUp.dart';

//import 'package:zimtrade/dump.dart';

class mySettings extends StatefulWidget {
  @override
  Mysaved createState() => Mysaved();
}

class Mysaved extends State<mySettings> {
  String ?userid = '';
  String password = '';
  String phoneNum = '';
  String email = '';
  String username = '';
  bool signedIn = false;
  var user_snapshot;
  final oldpassword = TextEditingController();
  final newpassword = TextEditingController();



  String countryCode = "";
  String countryCode3 = "";

  void _onCountryChange(CountryCode countryCode2) {
    countryCode = countryCode2.toString();

    print(countryCode);
  }
  void _onCountryChange2(CountryCode countryCode2) {
    countryCode3 = countryCode2.toString();
  }


  getId() async {
    if (await FirebaseAuth.instance.currentUser != null) {
      print('signed in');
      setState(() {
        signedIn = true;
        userid = FirebaseAuth.instance.currentUser?.uid;
      });
    }
    print(userid);
  }

  getData() async {
    if(signedIn) {
      User? user = FirebaseAuth.instance.currentUser;

      user_snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('user_id', isEqualTo: user?.uid)
          .limit(1)
          .get();
    }

    setState(() {
      username = user_snapshot[0]['username'];
      email = user_snapshot[0]['email'];
    });
    print(username);
  }

  @override
  void initState() {
    getId();
    getData();
    super.initState();
  }

  @override
  void dispose() {
    newpassword.dispose();
    oldpassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.yellow[800],
          title: const Text(
            'My Profile',
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
          ),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height ,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height * 0.23,
                    color: Colors.yellow[800],
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                            top: MediaQuery.of(context).size.height * 0.04,
                            left: MediaQuery.of(context).size.width * 0.04,
                            child:GestureDetector(

                                onTap:(){},
                                child: Container(
                                  child: Center(
                                    child:Icon(Icons.person,size: 40,),
                                  ),
                                  decoration: const BoxDecoration(
                                      color: Colors.white, shape: BoxShape.circle),
                                  height: 80,
                                  width: 80,
                                ))),

                        Positioned(
                            bottom: MediaQuery.of(context).size.height * 0.01,
                            right: MediaQuery.of(context).size.width * 0.09,
                            child: Text(
                              email,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900),
                            )),

                        Positioned(
                            top: 0,
                            right: 0,
                            child:signedIn? Text(email): TextButton.icon(onPressed: (){
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (BuildContext context) => signUpPage()));
                            }, icon: const Icon(Icons.warning,color: Colors.yellow,), label: Text('Create Account ',style: TextStyle(color: Colors.white.withOpacity(0.8),fontWeight: FontWeight.w600))))
                      ],
                    )),
                const SizedBox(
                  height: 14,
                ),
                Card(
                  elevation: 0.5,
                    child: ConstrainedBox(

                        constraints: const BoxConstraints(
                          minHeight: 50,
                          // maxHeight: 100.0,
                          // maxWidth: 100.0
                        ),
                        // height: MediaQuery.of(context).size.height * 0.1,
                        // width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const <Widget>[

                                Text(
                                  '  Password',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text(
                                  ' ......',
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black54),
                                ),
                                TextButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(
                                                          20.0))),
                                              title: const Text('Change Password'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                    'change',
                                                    style: TextStyle(
                                                        color: Colors.red[900]),
                                                  ),
                                                  onPressed: () async {

                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(
                                                    'back',
                                                    style: TextStyle(
                                                        color: Colors.red[900]),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                              content: Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.3,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                                  children: <Widget>[
                                                    TextFormField(
                                                        controller: oldpassword,
                                                        decoration:
                                                        const InputDecoration(
                                                          labelText:
                                                          'Old password',
                                                        )),
                                                    const SizedBox(height: 3),
                                                    TextFormField(
                                                        controller: newpassword,
                                                        decoration:
                                                        const InputDecoration(
                                                          labelText:
                                                          'New password',
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.red[900],
                                    ))
                              ],
                            )
                          ],
                        ))),
                const SizedBox(
                  height: 14,
                ),
                Card(
                  elevation: 0.5,
                    child:  ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 50,
                          // maxHeight: 100.0,
                          // maxWidth: 100.0
                        ),
                        //  height: MediaQuery.of(context).size.height * 0.1,
                        // width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const <Widget>[
                                Text(
                                  '  Mobile number',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('   ' + phoneNum),
                                TextButton(
                                    onPressed: () {

                                    },
                                    child: Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.red[900],
                                    ))
                              ],
                            )
                          ],
                        ))),
                const SizedBox(
                  height: 14,
                ),
              ],
            ),
          ),
        ));
  }
}