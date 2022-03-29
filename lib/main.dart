import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shisha_app/pages/homeScreen.dart';
import 'package:sqflite/sqflite.dart';
import 'utils/globals.dart' as globals;
import 'package:path/path.dart' as Path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: globals.themeColor,
      ),
      home:  const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);


  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  void _gotoHomeScreen() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => const HomeScreen()));
    });
  }

  openTablesDb() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? statusValue = prefs.getString('isFirstTime');
    String databasesPath = await getDatabasesPath();
    String dbPath = Path.join(databasesPath, 'tables');

    if(statusValue == 'no'){
      print('user has table');
    }else {
       await openDatabase(dbPath, version: 1,
          onCreate: (Database db, int version) async {
            await db.execute(
                'CREATE TABLE favourites (id INTEGER PRIMARY KEY, product_id TEXT UNIQUE)');
            await db.execute(
                'CREATE TABLE cart (id INTEGER PRIMARY KEY , product_id TEXT UNIQUE, productName TEXT, productPrice TEXT, productPic TEXT, flavourName TEXT, flavourPrice TEXT, flavour_id TEXT, charcoalName TEXT, charcoalPrice TEXT, charcoal_id TEXT, total_price TEXT, selectedMethod TEXT)');
          });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('isFirstTime','no');

    }
  }

  @override
  void initState() {
    openTablesDb();
    _gotoHomeScreen();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo.jpeg')
          ],
        ),
      ),
    );
  }
}
