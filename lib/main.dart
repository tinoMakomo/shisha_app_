import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
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

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
late final FirebaseMessaging _messaging;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smoke 24',
      theme: ThemeData(
        primarySwatch: globals.themeColor,
      ),
      home: const SplashScreen(),
    ));
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
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const HomeScreen()));
    });
  }

  void registerNotification() async {
    await Firebase.initializeApp();

    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        var _notificationInfo = message.notification;

        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo.title!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            leading: Icon(Icons.notifications,color: Colors.white,size: 30,),
            subtitle: Text(_notificationInfo.body!,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            background: Colors.yellow[800],
            duration: const Duration(seconds: 5),
          );
        }
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


    } else {
      print('User declined or has not accepted permission');
    }
  }

  openTablesDb() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? statusValue = prefs.getString('isFirstTime');
    String databasesPath = await getDatabasesPath();
    String dbPath = Path.join(databasesPath, 'tables');

    if (statusValue == 'no') {
      print('user has table');
    } else {
      await openDatabase(dbPath, version: 1,
          onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE favourites (id INTEGER PRIMARY KEY, product_id TEXT UNIQUE)');
        await db.execute(
            'CREATE TABLE cart (id INTEGER PRIMARY KEY , product_id TEXT UNIQUE, productName TEXT, productPrice TEXT, productPic TEXT, flavourName TEXT, flavourPrice TEXT, flavour_id TEXT, charcoalName TEXT, charcoalPrice TEXT, charcoal_id TEXT, total_price TEXT, selectedMethod TEXT)');
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('isFirstTime', 'no');
    }
  }

  @override
  void initState() {
    registerNotification();
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
          children: <Widget>[Image.asset('assets/images/logo.jpeg')],
        ),
      ),
    );
  }
}
