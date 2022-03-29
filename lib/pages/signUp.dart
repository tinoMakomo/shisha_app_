import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shisha_app/pages/homeScreen.dart';
import 'package:shisha_app/pages/login.dart';


class signUpPage extends StatefulWidget {
  @override
  signUpPageState createState() => signUpPageState();
}

class signUpPageState extends State<signUpPage> {

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
      setState(() {
        isLoading = false;
      });
      overlayLoader.remove();
    } catch (ex) {}
  }

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKeyLogin = GlobalKey<FormState>();
  var error;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  Future<bool> _willPopCallback() async {
    if (isLoading == true) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
            backgroundColor: Colors.white.withOpacity(0.95),
            body: Form(
                key: _formKeyLogin,
                child: Center(
                  child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Image.asset('assets/images/logo1.png'),
                            height: MediaQuery.of(context).size.height * 0.27,
                            width: MediaQuery.of(context).size.width * 0.55,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.person,
                                color: Colors.yellow[800],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(0)),
                                width: MediaQuery.of(context).size.width * 0.65,
                                height: 45,
                                child: TextFormField(
                                  validator: (value){
                                    if (value!.isEmpty) {
                                      return 'username can\'t be empty';
                                    }
                                  },
                                  controller: _nameController,

                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide:
                                          const BorderSide(color: Colors.white)),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      hintText: "Username",
                                      hintStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.perm_identity,
                                color: Colors.yellow[800],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(0)),
                                width: MediaQuery.of(context).size.width * 0.65,
                                height: 45,
                                child: TextFormField(
                                  // keyboardType: TextInputType.number,
                                  // maxLength: 10,
                                  validator: (value){
                                    if (value!.isEmpty) {
                                      return 'email can\'t be empty';
                                    }
                                  },
                                  controller: _emailController,

                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide:
                                          const BorderSide(color: Colors.white)),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      hintText: "Email",
                                      hintStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.phone,
                                color: Colors.yellow[800],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.65,
                                height: 45,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(0)),
                                child: TextFormField(
                                  validator: (value){
                                    if (value!.isEmpty) {
                                      return 'mobile number can\'t be empty';
                                    }
                                  },
                                  controller: _mobileNumberController,
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide:
                                          const BorderSide(color: Colors.white)),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      hintText: "Mobile Number",
                                      hintStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),

                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.yellow[800],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.65,
                                height: 45,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(0)),
                                child: TextFormField(
                                  obscureText: true,
                                  controller: _passwordController,
                                  validator: (value){
                                    if (value!.isEmpty) {
                                      return 'password can\'t be empty';
                                    }
                                    if (value.length < 6) {
                                      return 'password too short';
                                    }
                                  },
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide:
                                          const BorderSide(color: Colors.white)),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      hintText: "Password",
                                      hintStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),

                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.lock,
                                color: Colors.yellow[800],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.65,
                                height: 45,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(0)),
                                child: TextFormField(
                                  validator: (value){
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                  },
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide:
                                          const BorderSide(color: Colors.white)),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      hintText: "Confirm Password",
                                      hintStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),

                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07,
                          ),
                          Container(
                              color: Colors.yellow[800],
                              width: MediaQuery.of(context).size.width * 0.73,
                              height:40,
                              child: TextButton(
                                onPressed: signUp,
                                child: const Text(
                                  'Create Account',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  textAlign: TextAlign.left,
                                ),
                              )),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (BuildContext context) => loginPage()));
                            },
                            child: Text(
                              'Already have an Account?',
                              style: TextStyle(
                                color: Colors.yellow[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),

                        ],
                      )),
                ))));
  }

  signUp() async {
    if (_formKeyLogin.currentState!.validate()) {
      showLoader(context);
      try {
        UserCredential result = await auth
            .createUserWithEmailAndPassword(
            email: _emailController.text.trim().split(" ").join(""),
            password: _passwordController.text);
        User? user = result.user;
        final id = user?.uid;

        await databaseReference
            .collection("users")
            .add({
          'username': _nameController.text,
          'Mobile_number': _mobileNumberController.text.toString(),
          'user_id': id,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'email': _emailController.text,
          }).then((value) async {
          await auth.signInWithEmailAndPassword(
              email: _emailController.text
                  .trim()
                  .toLowerCase().split(" ").join(""),
              password: _passwordController.text);
          _nameController.clear();
          _passwordController.clear();
          _emailController.clear();
          _mobileNumberController.clear();
          dismissLoader();
          Fluttertoast.showToast(
              msg: "Successfully created account.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
        });
      } catch (e) {
        dismissLoader();
        print(e.toString());
        if (e.toString() ==
            'PlatformException(ERROR_EMAIL_ALREADY_IN_USE, The email address is already in use by another account., null)') {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(
                          Radius.circular(
                              20.0))),
                  content: Text(
                      'username in use by another account'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop();
                        },
                        child: Text('Ok',style: TextStyle(fontWeight: FontWeight.w600),))
                  ],
                );
              });
        }else if(e.toString()=='PlatformException(ERROR_INVALID_EMAIL, The email address is badly formatted., null)'){
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(
                          Radius.circular(
                              20.0))),
                  content: Text(
                      'Remove special characters on username'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop();
                        },
                        child: Text('Ok',style: TextStyle(fontWeight: FontWeight.w600),))
                  ],
                );
              });

        } else {
          //dismissLoader();
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(
                          Radius.circular(
                              20.0))),
                  title: Icon(Icons.warning),
                  content: Text(
                    'no internet connection',style: TextStyle(fontWeight: FontWeight.w600),),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop();
                        },
                        child: Text('Ok'))
                  ],
                );
              });
        }
      }
    }
  }
}
