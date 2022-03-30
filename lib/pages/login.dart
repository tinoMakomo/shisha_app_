import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shisha_app/pages/homeScreen.dart';
import 'package:shisha_app/pages/signUp.dart';


class loginPage extends StatefulWidget {
  @override
  loginPageState createState() => loginPageState();
}

class loginPageState extends State<loginPage> {

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

  final _controller = TextEditingController();
  final _controller2 = TextEditingController();
  final _controller3 = TextEditingController();
  final _controller4 = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKeyLogin = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String retrievedPassword = "";
  var error;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
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
                            height: MediaQuery.of(context).size.height * 0.06,
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

                                  controller: _controller2,

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
                                  obscureText: true,
                                  controller: _controller,
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
                            height: 40,
                          ),
                          Container(
                            color: Colors.yellow[800],
                              width: MediaQuery.of(context).size.width * 0.73,
                              height:40,
                              child: TextButton(
                                  onPressed: signIn,
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                    textAlign: TextAlign.left,
                                  ),
                                  )),
                          SizedBox(
                            height: 20,
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(context: context,
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                      title: Text('Retrieve Your Password',style: TextStyle(color: Colors.red[900],fontSize:12,fontWeight: FontWeight.w600),),
                                      content: SizedBox(
                                        width: 350,
                                        height: 150,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            TextFormField(
                                              controller: _controller3,

                                              decoration: InputDecoration(
                                                hintText: 'username',
                                                hintStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                    MediaQuery.of(context).size.width *
                                                        0.03),
                                              ),

                                            ),

                                          ],
                                        ),
                                      ),
                                      actions: const <Widget>[

                                      ],
                                    );
                                  }
                              );
                            },
                            child: Text(
                              'Forgot Password',
                              style: TextStyle(
                                color: Colors.yellow[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            height:2,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (BuildContext context) => signUpPage()));
                            },
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.yellow[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      )),
                ))));
  }

  signIn() async {
    if (_controller2.text != '' && _controller.text != '') {
      try {
        showLoader(context);
        setState(() {
          isLoading = true;
        });
        await auth.signInWithEmailAndPassword(
            email: _controller2.text,
            password: _controller.text);

        dismissLoader();
        _formKeyLogin.currentState?.reset();
        Fluttertoast.showToast(
            msg: "Successfully logged in.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
      } catch (e) {
        dismissLoader();

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                //title: Icon(Icons.warning),
                content: Text(e.toString()),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Ok'))
                ],
              );
            });
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please fill in all the details.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }
}
