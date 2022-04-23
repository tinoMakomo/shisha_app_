import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shisha_app/pages/homeScreen.dart';

//import 'package:zimtrade/dump.dart';

class mySettings extends StatefulWidget {
  @override
  Mysaved createState() => Mysaved();
}

class Mysaved extends State<mySettings> {
  String? userid = '';
  String password = '';
  String phoneNum = '';
  String email = '';
  String username = '';
  String phoneNumber = '';
  bool signedIn = false;
  var user_snapshot;
  final oldpassword = TextEditingController();
  final newpassword = TextEditingController();
  final _controller3 = TextEditingController();

  String countryCode = "";
  String countryCode3 = "";
  final FirebaseAuth auth = FirebaseAuth.instance;

  void _onCountryChange(CountryCode countryCode2) {
    countryCode = countryCode2.toString();

    print(countryCode);
  }

  void _onCountryChange2(CountryCode countryCode2) {
    countryCode3 = countryCode2.toString();
  }

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
  String user_snapshot_id="";
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
        username = user_snapshot.docs[0]['username'];
        email = user_snapshot.docs[0]['email'];
        phoneNumber = user_snapshot.docs[0]['Mobile_number'];
        user_snapshot_id = user_snapshot.docs[0].id;
      });
    }
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
          title: Text(
            '${username}\'s Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
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
                            child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  child: Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 40,
                                    ),
                                  ),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900),
                            )),
                        Positioned(
                            top: 0,
                            right: 0,
                            child: TextButton.icon(
                                onPressed: () async {
                                  try {
                                    await FirebaseAuth.instance.signOut();
                                    Fluttertoast.showToast(
                                        msg: "Successfully Logged Out",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.black54,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                                        HomeScreen()), (Route<dynamic> route) => false);
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                        msg: e.toString(),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.black54,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
                                },
                                icon: Icon(
                                  Icons.power_settings_new,
                                  color: Colors.red[900],
                                ),
                                label: Text('Logout',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w900))))
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
                                        title: Text(
                                          'Change Your Password',
                                          style: TextStyle(
                                              color: Colors.yellow[800],
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        content: Text("A password reset link will be sent to your email. Click PROCEED to confirm."),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'CANCEL',
                                                style: TextStyle(
                                                    color: Colors.yellow[800]),
                                              )),
                                          TextButton(
                                              onPressed: () async {
                                                  try {
                                                    showLoader(context);
                                                    await auth.sendPasswordResetEmail(
                                                        email:
                                                        email.trim());
                                                    Navigator.of(context).pop();
                                                    Fluttertoast.showToast(
                                                        msg:
                                                        "Password Reset Link successfully sent to your email",
                                                        toastLength:
                                                        Toast.LENGTH_SHORT,
                                                        gravity: ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                        Colors.black54,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                    dismissLoader();
                                                  } catch (e) {
                                                    dismissLoader();
                                                    print(e.toString());
                                                    Navigator.of(context).pop();
                                                    Fluttertoast.showToast(
                                                        msg: e.toString(),
                                                        toastLength:
                                                        Toast.LENGTH_SHORT,
                                                        gravity: ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                        Colors.black54,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  }

                                              },
                                              child: Text('PROCEED',
                                                  style: TextStyle(
                                                      color: Colors.yellow[800])))
                                        ],
                                      );});
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
                    child: ConstrainedBox(
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
                                  '  Mobile Number',
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
                                Text('   ' + phoneNumber),
                                TextButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                'Change Mobile Number',
                                                style: TextStyle(
                                                    color: Colors.yellow[800],
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                              content: SizedBox(
                                                width: 350,
                                                height: 100,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                                  children: <Widget>[
                                                    TextFormField(
                                                      controller: _controller3,
                                                      decoration: InputDecoration(
                                                        hintText: 'Enter Your New Mobile Number',
                                                        hintStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                                0.03),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text(
                                                      'CANCEL',
                                                      style: TextStyle(
                                                          color: Colors.yellow[800]),
                                                    )),
                                                TextButton(
                                                    onPressed: () async {
                                                      if (_controller3.text == "") {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                            "Please enter your new mobile number",
                                                            toastLength: Toast.LENGTH_SHORT,
                                                            gravity: ToastGravity.BOTTOM,
                                                            timeInSecForIosWeb: 1,
                                                            backgroundColor: Colors.black54,
                                                            textColor: Colors.white,
                                                            fontSize: 16.0);
                                                      } else {
                                                        try {
                                                          showLoader(context);
                                                          FirebaseFirestore.instance.collection('users').doc(user_snapshot_id).set(
                                                              {'Mobile_number': _controller3.text.trim()}, SetOptions(merge: true)).then((value) {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                "Mobile number has been changed successfully, refresh page to view the changes.",
                                                                toastLength:
                                                                Toast.LENGTH_LONG,
                                                                gravity: ToastGravity.BOTTOM,
                                                                timeInSecForIosWeb: 1,
                                                                backgroundColor:
                                                                Colors.black54,
                                                                textColor: Colors.white,
                                                                fontSize: 16.0);
                                                          });
                                                          dismissLoader();
                                                        } catch (e) {
                                                          dismissLoader();
                                                          print(e.toString());
                                                          Navigator.of(context).pop();
                                                          Fluttertoast.showToast(
                                                              msg: e.toString(),
                                                              toastLength:
                                                              Toast.LENGTH_LONG,
                                                              gravity: ToastGravity.BOTTOM,
                                                              timeInSecForIosWeb: 1,
                                                              backgroundColor:
                                                              Colors.black54,
                                                              textColor: Colors.white,
                                                              fontSize: 16.0);
                                                        }
                                                      }
                                                    },
                                                    child: Text('CHANGE',
                                                        style: TextStyle(
                                                            color: Colors.yellow[800])))
                                              ],
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
              ],
            ),
          ),
        ));
  }
}
