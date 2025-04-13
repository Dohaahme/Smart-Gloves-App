import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:provider/provider.dart';
import 'package:test_gproject/admin/HomePage.dart';
import 'package:test_gproject/favourite.dart';
import 'package:test_gproject/how_use.dart';
import 'package:test_gproject/loginPage.dart';
import 'package:test_gproject/theme.dart';
import 'package:test_gproject/word_list_page.dart';
import 'package:test_gproject/word_list_page2.dart';

import 'package:test_gproject/word_list_page3.dart';

import 'package:test_gproject/word_list_page4.dart';

import 'package:test_gproject/word_list_page5.dart';

import 'package:test_gproject/word_list_page6.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test_gproject/firebase_options.dart';


import 'package:url_launcher/url_launcher.dart';
import 'CustomButton.dart';
import 'language.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:animated_rating_stars/animated_rating_stars.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    // Save the theme preference to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Define light theme
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    // Define more properties for light theme as needed
  );

  // Define dark theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    // Define more properties for dark theme as needed
  );

  // Constructor to initialize the theme preference
  ThemeProvider() {
    _loadThemePreference();
  }

  // Function to load the theme preference from shared preferences
  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize App Check
  //FirebaseAppCheck.instance.activate();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final bool _isAdmin = prefs.getBool('isAdmin') ?? false;
  runApp(

    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MyApp(),

    ),
  );
}






class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool network=false;
  String  userName="";
  String  userEmail="";
  bool isLoggedIn = false;
  bool _isLoggedIn=false;
  bool beginlogin=false;
  bool isAdmin=false;


  @override
  void initState() {
    super.initState();
    _loadLoginState();
    _loaduserdata();
    checkConnectivity();
    _loadAdminState();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    final languageProvider =Provider.of<LanguageProvider>(context, listen: false);
    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connected to Mobile Network");
      network=true;
      print(network);
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Connected to WiFi Network");
      network=true;
      print(network);
    } else {
      print("No Internet Connection");
      network=false;
      print(network);
      Fluttertoast.showToast(
          msg: languageProvider.localizedStrings['errorinternet'] ?? 'Please Check The Internet Connection',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }


  // Future<void> _checkGooglePlayServicesAvailability() async {
  //   GooglePlayServicesAvailability availability =
  //   await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
  //
  //   if (availability != GooglePlayServicesAvailability.success) {
  //     _showGooglePlayServicesErrorDialog(availability);
  //   }
  // }

  // Future<void> _usernamevar() async {
  //
  //   final user = FirebaseAuth.instance.currentUser;
  //   String? userId = user?.uid;
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('info')
  //       .get()
  //       .then((querySnapshot) {
  //     querySnapshot.docs.forEach((doc) {
  //       // Assuming 'username' is the field name where the username is stored
  //       var username = doc['username'];
  //       userName=username;
  //       print("Username: $userName");
  //       var useremail = doc['email'];
  //       userEmail=useremail;
  //       print("Useremail: $userEmail");
  //     });
  //   }).catchError((error) {
  //     print("Error getting documents: $error");
  //   });
  //
  //   if (user != null) {
  //     String? userId = user.uid;
  //
  //     FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('info')
  //         .doc('details') // Assuming 'details' is the document ID under 'info'
  //         .get()
  //         .then((DocumentSnapshot documentSnapshot) {
  //       if (documentSnapshot.exists) {
  //         var data = documentSnapshot.data() as Map<String, dynamic>?;
  //         var username = data?['username'];
  //         var useremail = data?['email'];
  //         // Use the retrieved data
  //         print("Username: $userName");
  //         print("User Email: $userEmail");
  //
  //         // Assign values to variables if needed
  //         userName = username;
  //         userEmail = useremail;
  //       } else {
  //         print('Document does not exist on the server.');
  //       }
  //     }).catchError((error) {
  //       print("Error getting documents: $error");
  //     });
  //   } else {
  //     print('User is not logged in.');
  //   }
  // }


  // Future<void> _checkGooglePlayServicesAvailability() async {
  //   GooglePlayServicesAvailability availability =
  //   await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
  //
  //   if (availability != GooglePlayServicesAvailability.success) {
  //     _showGooglePlayServicesErrorDialog(availability);
  //   }
  // }

  Future<void> _loaduserdata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userName=prefs.getString('username')??'';
    userEmail=prefs.getString('email')??'';
    print(userName);
    print(userEmail);

  }



  Future<void> _loadLoginState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _isLoggedIn=prefs.getBool('isLoggedIn') ?? false;
      beginlogin = prefs.getBool('beginlogin') ?? false;
      print(beginlogin);
    });
  }

  Future<void> _loadAdminState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = prefs.getBool('isAdmin') ?? false;
      print(isAdmin);
      print("*****  it is admin   ********");
    });
  }




  void _handleLogin() async {
    setState(() {
      isLoggedIn = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }



  void _handleLogout() async {
    UserCredential userCredential = await FirebaseAuth
        .instance.signInWithEmailAndPassword(
      email: "dohaahmed123@gmail.com",
      password:"11111111",
    );
    setState(() {
      isLoggedIn = false;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage(onLogin: _handleLogin)),
    );
  }

  bool isArabic(String text) {
    final arabicRegex = RegExp(r'^[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);


    String firstchar='';
    if (userName.isNotEmpty) {
      firstchar=userName[0].toUpperCase();
    }
    bool isTextArabic = isArabic(firstchar);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      locale: languageProvider.appLocale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'SA'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: navigatorKey,
      home: beginlogin?
      isAdmin?MyAdminApp():DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              languageProvider.localizedStrings['smartgloves'] ?? 'Smart Gloves',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
            bottom: TabBar(
              labelColor: Colors.white,
              labelStyle: const TextStyle(fontSize: 20),
              unselectedLabelColor: Colors.blueGrey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(
                  text: languageProvider.localizedStrings['Home'] ?? 'Home',
                  icon: const Icon(Icons.home),
                ),
                Tab(
                  text: languageProvider.localizedStrings['Chat'] ?? 'Chat',
                  icon: const Icon(Icons.chat),
                ),
                Tab(
                  text: languageProvider.localizedStrings['Dictionary'] ?? 'Dictionary',
                  icon: const Icon(Icons.menu_book_rounded),
                ),
              ],
            ),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Row(
                    children: [
                      isLoggedIn?Padding(
                        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 30,),
                            Row(
                              children: [
                                //SizedBox(width: 30,),
                                Row(
                                  mainAxisAlignment: isTextArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      child: Text(
                                        firstchar,
                                        style: TextStyle(color: Colors.blue, fontSize: 30),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: TextStyle(color: Colors.white, fontSize: 30),
                                    ),
                                    Text(
                                      userEmail,
                                      style: TextStyle(color: Colors.white70, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ):Row(
                        children: [

                          Icon(Icons.settings, color: Colors.white, size: 30),
                          SizedBox(width: 10), // Add some space between the icon and the text
                          Text(
                            languageProvider.localizedStrings['settings'] ?? 'Settings',
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                    color: Colors.blue,
                  ),
                  title: Text(
                    languageProvider.localizedStrings['darkMode'] ?? 'Dark Mode',
                    style: const TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  onTap: () {
                    themeProvider.toggleTheme();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.blue),
                  title: Text(
                    _switchTitle(languageProvider.appLocale.languageCode == 'ar'),
                    style: const TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  onTap: () {
                    toggleLanguage(context);
                    navigatorKey.currentState!.pushReplacement(
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                  },
                ),
                isLoggedIn?ListTile(
                  leading: Icon(
                    Icons.favorite ,
                    color: Colors.blue,
                  ),
                  title: Text(
                    languageProvider.localizedStrings['myfavorites'] ?? 'My Favourite',
                    style: const TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  onTap: () {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(builder: (context) => MyFavoritesPage(isLogin: isLoggedIn,)),
                    );
                  },
                ):SizedBox(),
                ListTile(
                  leading: Icon(
                    Icons.help_outline ,
                    color: Colors.blue,
                  ),
                  title: Text(
                    languageProvider.localizedStrings['howtouse'] ?? 'Help',
                    style: const TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  onTap: () {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(builder: (context) => HowToUseScreen()),
                    );
                  },
                ),
                isLoggedIn?ListTile(
                  leading: Icon(
                    Icons.star_rate_rounded ,
                    color: Colors.blue,
                  ),
                  title: Text(
                    languageProvider.localizedStrings['fedback'] ?? 'Feedback',
                    style: const TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  onTap: () {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(builder: (context) => App()),
                    );
                  },
                ):SizedBox(),
                ListTile(
                  leading: Icon(
                    isLoggedIn ? Icons.logout : Icons.login_rounded,
                    color: Colors.blue,
                  ),
                  title: Text(
                    isLoggedIn
                        ? languageProvider.localizedStrings['logout'] ?? 'Logout'
                        : languageProvider.localizedStrings['login'] ?? 'Login',
                    style: const TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  onTap: () {
                    if (isLoggedIn) {
                      _handleLogout();
                    } else {
                      navigatorKey.currentState!.push(
                        MaterialPageRoute(builder: (context) => LoginPage(onLogin: _handleLogin)),
                      );
                    }
                  },
                ),

              ],
            ),
          ),
          body: TabBarView(
            children: [
              MyHomePage(),
              ChatCard(),
              ButtonGrid(),
            ],
          ),
        ),
      )
          :LoginPage(onLogin: () { },),
    );
  }

  String _switchTitle(bool isArabic) {
    return isArabic ? 'English' : 'العربية';
  }

  void toggleLanguage(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLocale = languageProvider.appLocale;
    final newLocale = currentLocale.languageCode == 'en'
        ? const Locale('ar', 'SA')
        : const Locale('en', 'US');
    languageProvider.changeLanguage(newLocale);
  }
}

class ChatCard extends StatefulWidget {
  const ChatCard({Key? key}) : super(key: key);

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  final List<Map<String, dynamic>> _cards = [];
  final user = FirebaseAuth.instance.currentUser;
  final List<Map<String, dynamic>> loadedCards = [];
  bool network = false;

  @override
  void initState() {
    super.initState();
    _loadDataFromFirestore();
    _initializeStaticWords();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider =
    Provider.of<LanguageProvider>(context, listen: false);
    TextEditingController textFieldController = TextEditingController();

    return Center(
      child: Card(
        margin: EdgeInsets.all(20.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: textFieldController,
                decoration: InputDecoration(
                  hintText:
                  languageProvider.localizedStrings['chat'] ?? 'Chat',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.blue.withOpacity(0.1),
                  filled: true,
                  prefixIcon: const Icon(
                    Icons.chat,
                    color: Colors.blue,
                  ),
                ),
                cursorColor: Colors.blue,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  String text = textFieldController.text.trim();
                  List<String> words = text.split(' ');
                  List<String> imagePaths = [];
                  int count = 0;

                  for (String word in words) {
                    bool found = false;
                    for (var card in _cards) {
                      if (card['word_en'].toLowerCase() == word.toLowerCase() ||
                          card['word_ar'] == word) {
                        imagePaths.add(card['image']);
                        found = true;
                        break;
                      }
                    }
                    if (!found) {
                      count += 1;
                    }
                  }

                  if (count >= 1) {
                    Fluttertoast.showToast(
                        msg: languageProvider.localizedStrings['wordserror'] ??
                            'There Is Words n\'t In The Dictionary',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 5,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }

                  if (imagePaths.isNotEmpty) {
                    _showImages(context, imagePaths);
                  } else if (text.isEmpty) {
                    Fluttertoast.showToast(
                        msg: languageProvider.localizedStrings[
                        'youshouldentertext'] ??
                            'You should enter text',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 5,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    Fluttertoast.showToast(
                        msg: languageProvider.localizedStrings['usedictionary'] ??
                            'Please Use The Dictionary',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 5,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 0.15 * MediaQuery.of(context).size.width),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  languageProvider.localizedStrings['confirm'] ?? 'Confirm',
                  style: TextStyle(color: Colors.white, fontSize: 0.05 * MediaQuery.of(context).size.width),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initializeStaticWords() {
    _cards.clear(); // Clear the list before adding static words
    _cards.addAll([
      {
        'image': 'lib/assets/p8.jpg',
        'word_en': 'Go',
        'word_ar': 'اذهب',
      },
      {
        'image': 'lib/assets/p7.jpg',
        'word_en': 'Want',
        'word_ar': 'يريد',
      },
      {
        'image': 'lib/assets/p6.jpg',
        'word_en': 'Drink',
        'word_ar': 'يشرب',
      },

      {
        'image': 'lib/assets/p14.jpg',
        'word_en': 'Happy',
        'word_ar': 'سعيد',
      },
      {
        'image': 'lib/assets/p12.jpg',
        'word_en': 'Hungry',
        'word_ar': 'جائع',
      },
      {
        'image': 'lib/assets/p5.jpg',
        'word_en': 'Upset',
        'word_ar': 'منزعج',
      },
      {
        'image': 'lib/assets/p4.jpg',
        'word_en': 'Airport',
        'word_ar': 'المطار',
      },
      {
        'image': 'lib/assets/p2.jpg',
        'word_en': 'Train Station',
        'word_ar': 'محطة القطار',
      },
      {
        'image': 'lib/assets/p16.jpg',
        'word_en': 'How',
        'word_ar': 'كيف',
      },
      {
        'image': 'lib/assets/p3.jpg',
        'word_en': 'Where',
        'word_ar': 'اين',
      },
      {
        'image': 'lib/assets/p13.jpg',
        'word_en': 'What',
        'word_ar': 'ماذا',
      },
      {
        'image': 'lib/assets/p11.jpg',
        'word_en': 'I',
        'word_ar': 'أنا',
      },
      {
        'image': 'lib/assets/p15.jpg',
        'word_en': 'to',
        'word_ar': 'ان',
      },
      {
        'image': 'lib/assets/p1.jpg',
        'word_en': 'That',
        'word_ar': 'ذلك',
      },
      {
        'image': 'lib/assets/p10.jpg',
        'word_en': 'Hi',
        'word_ar': 'اهلا',
      },
      {
        'image': 'lib/assets/p9.jpg',
        'word_en': 'Are You',
        'word_ar': 'تكون',
      },

      {
        'image': 'lib/assets/p17.jpg',
        'word_en': 'Goodbye',
        'word_ar': 'وداعا',
      },
    ]);
  }

  Future<void> _loadDataFromFirestore() async {
    String? userId = "SnGEBUjhAdbtflEYzF1C3JgXBD33";
    List<String> collections = [
      'verbs',
      'emotions',
      'me',
      'places',
      'welcome',
      'questions',
    ];

    for (String collection in collections) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection(collection)
            .get();

        for (var doc in querySnapshot.docs) {
          _cards.add({
            'image': doc['image'],
            'word_en': doc['word_en'],
            'word_ar': doc['word_ar'],
          });
        }
      } catch (error) {
        print("Failed to load words from $collection: $error");
      }
    }
  }

  void _showImages(BuildContext context, List<String> imagePaths) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: imagePaths.map((path) {
              bool isUrl = Uri.tryParse(path)?.isAbsolute ?? false;
              return Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: isUrl ? Image.network(path) : Image.asset(path),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}


// void _showImages(BuildContext context, List<String> imagePaths) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       content: SingleChildScrollView(
//         child: Wrap(
//           spacing: 8.0,
//           runSpacing: 8.0,
//           children: imagePaths.map((path) {
//             bool isUrl = Uri.tryParse(path)?.isAbsolute ?? false;
//             return Container(
//               width: 60,
//               height: 80,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0),
//                 child: isUrl
//                     ? Image.network(path)
//                     : Image.asset(path),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     ),
//   );
// }
//

class ButtonGrid extends StatefulWidget {
  const ButtonGrid({Key? key}) : super(key: key);

  @override
  _ButtonGridState createState() => _ButtonGridState();
}

class _ButtonGridState extends State<ButtonGrid> {
  bool isAdmin = false;
  bool isLogin=false;
  bool network = false;

  @override
  void initState() {
    super.initState();
    _loadLoginState();
  }



  Future<void> _loadLoginState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = prefs.getBool('isAdmin') ?? false;
      isLogin = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    icon: Icons.energy_savings_leaf,
                    label: languageProvider.localizedStrings['verbs'] ?? 'Verbs',
                    page:VerbsPage(isAdmin:isAdmin,isLogin:isLogin),
                    darkMode: themeProvider.isDarkMode,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: CustomButton(
                    icon: Icons.sentiment_satisfied,
                    label: languageProvider.localizedStrings['emotions'] ?? 'Emotions',
                    page: EmotionsPage(isAdmin: isAdmin,isLogin:isLogin),
                    darkMode: themeProvider.isDarkMode,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    icon: Icons.location_on,
                    label: languageProvider.localizedStrings['places'] ?? 'Places',
                    page: PlacePage(isAdmin: isAdmin,isLogin:isLogin),
                    darkMode: themeProvider.isDarkMode,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: CustomButton(
                    icon: Icons.question_answer,
                    label: languageProvider.localizedStrings['questions'] ?? 'Questions',
                    page: QuestionPage(isAdmin: isAdmin,isLogin:isLogin),
                    darkMode: themeProvider.isDarkMode,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    icon: Icons.person,
                    label: languageProvider.localizedStrings['me'] ?? 'Me',
                    page: MePage(isAdmin: isAdmin,isLogin:isLogin),
                    darkMode: themeProvider.isDarkMode,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: CustomButton(
                    icon: Icons.handshake,
                    label: languageProvider.localizedStrings['welcomeWords'] ?? 'Welcome ',
                    page: WelcomePage(isAdmin: isAdmin,isLogin:isLogin),
                    darkMode: themeProvider.isDarkMode,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final DatabaseReference _messageRef = FirebaseDatabase.instance.reference().child('message');

  bool _cardsFetched = false;
  String _message = '';
  final FlutterTts flutterTts = FlutterTts();
  String text = '';
  String lastText = '';
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> _cards = [];
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    card(); // Fetch cards whenever dependencies change
  }
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await card();
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    text = _translateText(text, languageProvider);
    setState(() {}); // Update UI after initialization
    _messageRef.onValue.listen((event) {
      _handleDatabaseChange(event);
    });
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);
  }
  void _handleDatabaseChange(DatabaseEvent event) async {
    final message = (event.snapshot.value ?? '').toString();
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translatedMessage = await _translateText(message, languageProvider);
    //await Future.delayed(Duration(milliseconds: 1));
    setState(() {
      _message = message;
      text += (text.isNotEmpty ? ' ' : '') + translatedMessage;
      if (text != lastText) {

        _speak(message, languageProvider);
        lastText = text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Center(
      child: Card(
        margin: EdgeInsets.all(20.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Text(
                  text,
                  style: TextStyle(color: Colors.blue, fontSize: 20),
                ),
              ),
              SizedBox(height: 10),
              IconButton(
                icon: const Icon(Icons.volume_up, size: 40, color: Colors.blue),
                onPressed: () {
                  _speak(text, languageProvider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _translateText(String text, LanguageProvider languageProvider) {
    final languageCode = languageProvider.appLocale.languageCode;

    if (languageCode == "en") {
      return text;
    } else if (languageCode == "ar") {
      text=text.toLowerCase();
      List<String> words = text.split(' '); // Split text into words
      List<String> translatedWords = [];

      for (String word in words) {
        var foundCard;
        try {
          foundCard = _cards.firstWhere((card) => card['word_en'].toLowerCase() == word.toLowerCase());
          translatedWords.add(foundCard['word_ar']); // Translate word and add to list
        } catch (e) {
          // If translation not found, keep the original word
          translatedWords.add(word);
        }
      }

      return translatedWords.join(' '); // Join translated words back into a single string
    }

    return text; // Fallback to original text if language code is neither 'en' nor 'ar'
  }




  Future<void> _speak(String speechText, LanguageProvider languageProvider) async {
    // Translate specific English words to Arabic
    speechText = _translateText(speechText, languageProvider);

    // Detect language from text content
    String language = await _detectLanguage(speechText);

    // Set text-to-speech language based on the detected language
    await flutterTts.setLanguage(language);

    // Speak the translated text
    await flutterTts.speak(speechText);
  }

  Future<String> _detectLanguage(String text) async {
    // Basic detection based on characters
    if (text.contains(RegExp(r'[\u0600-\u06FF]'))) {
      // Arabic
      return 'ar-SA';
    } else {
      // English
      return 'en-US';
    }
  }

  Future<void> card() async {
    _cards.clear();
    String? userId = user?.uid;
    List<String> collections = [
      'verbs',
      'emotions',
      'me',
      'places',
      'welcome',
      'questions',
    ];


    for (String collection in collections) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection(collection)
            .get();

        for (var doc in querySnapshot.docs) {
          _cards.add({
            'word_en': doc['word_en'],
            'word_ar': doc['word_ar'],
          });
        }

        _cards.add({
          'word_en': 'Go',
          'word_ar': 'اذهب',
        });
        _cards.add({

          'word_en': 'Want',
          'word_ar': 'يريد',
        });
        _cards.add({
          'word_en': 'Drink',
          'word_ar': 'يشرب',
        });
        _cards.add({
          'word_en': 'Happy',
          'word_ar': 'سعيد',
        });
        _cards.add({
          'word_en': 'Hungry',
          'word_ar': 'جائع',
        });
        _cards.add({
          'word_en': 'Upset',
          'word_ar': 'منزعج',
        });
        _cards.add({
          'word_en': 'Airport',
          'word_ar': 'المطار',
        });
        _cards.add({
          'word_en': 'Train Station',
          'word_ar': 'محطة القطار',
        });
        _cards.add({
          'word_en': 'How',
          'word_ar': 'كيف',
        });
        _cards.add({
          'word_en': 'Where',
          'word_ar': 'اين',
        });
        _cards.add({
          'word_en': 'What',
          'word_ar': 'ماذا',
        });
        _cards.add({
          'word_en': 'I',
          'word_ar': 'أنا',
        });
        _cards.add({
          'word_en': 'to',
          'word_ar': 'ان',
        });
        _cards.add({

          'word_en': 'Goodbye',
          'word_ar': 'وداعا',
        });
        _cards.add({
          'word_en': 'To',
          'word_ar': 'الى',
        });
        _cards.add({
          'word_en': 'Hi',
          'word_ar': 'اهلا',
        });
        _cards.add({
          'word_en': 'Are You',
          'word_ar': 'انت تكون/ حالك',
        });
        setState(() {});
      } catch (error) {
        print("Failed to load words from $collection: $error");
      }
    }
  }
}

// Make sure to import the AnimatedRatingStars widget



class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  double _rating = 2.5;
  final user = FirebaseAuth.instance.currentUser;
  //String? userId = user?.uid;

  void _submitRating() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('feedback')
        .add({
      'feedback': _rating,
      'ratingtime':DateTime.now(),
    });
    alert2(context, "Rate", "Thanks For Rating Us");
  }

  void alert2(BuildContext context, String title, String content) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
                child: Text(languageProvider.localizedStrings['ok'] ?? 'Ok',style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  backgroundColor: Colors.blue,)
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        theme: themeProvider.themeData, // Use theme from ThemeProvider
        debugShowCheckedModeBanner: false,
        title: languageProvider.localizedStrings['RatingUs'] ?? 'Rating Us',
        home: Scaffold(
          appBar: AppBar(
            title:  Text(languageProvider.localizedStrings["PleaseRatingUs"] ?? "Please Rating Us"),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Rating: $_rating',
                  style: const TextStyle(fontSize: 24.0),
                ),
                AnimatedRatingStars(
                  initialRating: 2.5,
                  onChanged: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                  displayRatingValue: true,
                  interactiveTooltips: true,
                  customFilledIcon: Icons.star,
                  customHalfFilledIcon: Icons.star_half,
                  customEmptyIcon: Icons.star_border,
                  starSize: 40.0,
                  animationDuration: const Duration(milliseconds: 500),
                  animationCurve: Curves.easeInOut,
                ),
                SizedBox(height: 20.0), // Add some spacing
                TextButton(
                  onPressed: _submitRating,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  ),
                  child: Text(
                    languageProvider.localizedStrings['submit'] ?? 'Submit',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyAdminApp extends StatefulWidget {
  const MyAdminApp({Key? key}) : super(key: key);

  @override
  _MyAdminAppState createState() => _MyAdminAppState();
}

class _MyAdminAppState extends State<MyAdminApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool isLoggedIn = false;
  bool beginlogin=false;
  bool network=false;
  @override
  void initState() {
    super.initState();
    _loadLoginState();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    final languageProvider =Provider.of<LanguageProvider>(context, listen: false);
    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connected to Mobile Network");
      network=true;
      print(network);
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Connected to WiFi Network");
      network=true;
      print(network);
    } else {
      print("No Internet Connection");
      network=false;
      print(network);
      Fluttertoast.showToast(
          msg: "Please Check The Internet Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  // Future<void> _checkGooglePlayServicesAvailability() async {
  //   GooglePlayServicesAvailability availability =
  //   await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
  //
  //   if (availability != GooglePlayServicesAvailability.success) {
  //     _showGooglePlayServicesErrorDialog(availability);
  //   }
  // }
  Future<void> _loadLoginState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      beginlogin = prefs.getBool('beginlogin') ?? false;
      print(beginlogin);
    });
  }

  void _handleLogin() async {
    setState(() {
      isLoggedIn = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }



  void _handleLogout() async {
    setState(() {
      isLoggedIn = false;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage(onLogin: _handleLogin)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: themeProvider.themeData,
      locale: languageProvider.appLocale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'SA'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: navigatorKey,
      home: beginlogin?DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              languageProvider.localizedStrings['smartgloves'] ?? 'Smart Gloves',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
            bottom: TabBar(
              labelColor: Colors.white,
              labelStyle: const TextStyle(fontSize: 20),
              unselectedLabelColor: Colors.blueGrey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(
                  text: languageProvider.localizedStrings['ratings'] ?? 'Rating',
                  icon: const Icon(Icons.star_rate_rounded),
                ),
                // Tab(
                //   text: languageProvider.localizedStrings['Chat'] ?? 'Chat',
                //   icon: const Icon(Icons.chat),
                // ),
                Tab(
                  text: languageProvider.localizedStrings['Dictionary'] ?? 'Dictionary',
                  icon: const Icon(Icons.menu_book_rounded),
                ),
              ],
            ),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Row(
                    children: [
                      isLoggedIn?Padding(
                        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 30,),
                            Row(
                              children: [
                                //SizedBox(width: 30,),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      child:
                                      Text(
                                        'A',
                                        style: TextStyle(color: Colors.blue, fontSize: 30),
                                      )
                                      ,backgroundColor: Colors.white,

                                    ),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Admin Doha",
                                      style: TextStyle(color: Colors.white, fontSize: 30),
                                    ),
                                    Text(
                                      "dohaahmed123@gmail.com",
                                      style: TextStyle(color: Colors.white70, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ):Row(
                        children: [

                          Icon(Icons.settings, color: Colors.white, size: 30),
                          SizedBox(width: 10), // Add some space between the icon and the text
                          Text(
                            languageProvider.localizedStrings['settings'] ?? 'Settings',
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                    color: Colors.blue,
                  ),
                  title: Text(
                    languageProvider.localizedStrings['darkMode'] ?? 'Dark Mode',
                    style: const TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  onTap: () {
                    themeProvider.toggleTheme();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.blue),
                  title: Text(
                    _switchTitle(languageProvider.appLocale.languageCode == 'ar'),
                    style: const TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  onTap: () {
                    toggleLanguage(context);
                  },
                ),
                // ListTile(
                //   leading: Icon(
                //     Icons.help_outline ,
                //     color: Colors.blue,
                //   ),
                //   title: Text(
                //     languageProvider.localizedStrings['howtouse'] ?? 'Help',
                //     style: const TextStyle(color: Colors.blue, fontSize: 20),
                //   ),
                //   onTap: () {
                //     navigatorKey.currentState!.push(
                //       MaterialPageRoute(builder: (context) => HowToUseScreen()),
                //     );
                //   },
                // ),
                // ListTile(
                //   leading: Icon(
                //     Icons.star_rate_rounded ,
                //     color: Colors.blue,
                //   ),
                //   title: Text(
                //     languageProvider.localizedStrings['fedback'] ?? 'Feedback',
                //     style: const TextStyle(color: Colors.blue, fontSize: 20),
                //   ),
                //   onTap: () {
                //     navigatorKey.currentState!.push(
                //       MaterialPageRoute(builder: (context) => App()),
                //     );
                //   },
                // ),
                ListTile(
                  leading: Icon(
                    isLoggedIn ? Icons.logout : Icons.login_rounded,
                    color: Colors.blue,
                  ),
                  title: Text(
                    isLoggedIn
                        ? languageProvider.localizedStrings['logout'] ?? 'Logout'
                        : languageProvider.localizedStrings['login'] ?? 'Login',
                    style: const TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  onTap: () {
                    if (isLoggedIn) {
                      _handleLogout();
                    } else {
                      navigatorKey.currentState!.push(
                        MaterialPageRoute(builder: (context) => LoginPage(onLogin: _handleLogin)),
                      );
                    }
                  },
                ),

              ],
            ),
          ),
          body: TabBarView(
            children: [
              //MyHomePage(),
              //ChatCard(),
              RatingPage(),
              ButtonGrid(),
            ],
          ),
        ),
      ):LoginPage(onLogin: () { },),
    );
  }

  String _switchTitle(bool isArabic) {
    return isArabic ? 'English' : 'العربية';
  }

  void toggleLanguage(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLocale = languageProvider.appLocale;
    final newLocale = currentLocale.languageCode == 'en'
        ? const Locale('ar', 'SA')
        : const Locale('en', 'US');
    languageProvider.changeLanguage(newLocale);
  }
}
class RatingPage extends StatefulWidget {
  const RatingPage({Key? key}) : super(key: key);

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  List<Map<String, dynamic>> _ratings = [];
  final FlutterTts flutterTts = FlutterTts();
  String _userName = '';
  bool network = false;
  bool isLoggedIn=false;


  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      print("Connected to Network");
      network = true;
      print(network);
    } else {
      print("No Internet Connection");
      network = false;
      print(network);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.localizedStrings['errorloadwords'] ?? 'Internet Connection Failed Try Later',
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ),
        ),
      );
    }
  }

  void alert2(BuildContext context, String title, String content) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: Text(languageProvider.localizedStrings['ok'] ?? 'Ok', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadRatings();
    _loadLoginState();
  }

  Future<void> _loadRatings() async {
    List<Map<String, dynamic>> loadedRatings = [];
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    FirebaseFirestore.instance.collection('users').get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        final userInfo = await FirebaseFirestore.instance.collection('users').doc(doc.id).collection('info').doc('details').get();

        final userRatings = await FirebaseFirestore.instance.collection('users').doc(doc.id).collection('feedback').get();

        userRatings.docs.forEach((ratingDoc) {
          loadedRatings.add({
            'rating': ratingDoc['feedback'],
            'phone': userInfo['phoneNumber'] ?? '',
            'emailContact': userInfo['email'] ?? '',
            'userName': userInfo['username'] ?? '',
            'ratingTime': ratingDoc['ratingtime']?.toDate() ?? '',
          });
        });

        setState(() {
          _ratings = loadedRatings;
        });

        // Debugging: Print the loaded ratings
        print("Loaded ratings: $_ratings");
      });
    }).catchError((error) {
      print("Failed to load ratings from Firestore: $error");
      alert2(context, languageProvider.localizedStrings['ratingload'] ?? 'Load Ratings',languageProvider.localizedStrings['loodrat'] ?? "Sorry, can't load ratings now");
    });
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final url = 'https://wa.me/$phoneNumber';
    if (!await launch(url)) {
      print('Could not launch $url');
      // Log to error monitor (crashlytics and sentry) generic error saying 'Link has not launched for url($url)'
    }
  }

  void _sendEmail(String emailAddress) async {
    final Uri emailUri = Uri(

      scheme: 'mailto',
      path: emailAddress,
    );
    if (!await launch(emailUri.toString())) {
      print('Could not launch $emailUri');
      // Log to error monitor (crashlytics and sentry) generic error saying 'Link has not launched for url($url)'
    }
  }

  Future<void> _loadLoginState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(

      body:isLoggedIn? SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: _ratings.length,
              itemBuilder: (context, index) {
                String userName = _ratings[index]['userName'] ?? '';
                double rating = _ratings[index]['rating'] ?? 0.0;
                String phone = _ratings[index]['phone'] ?? '';
                String emailContact = _ratings[index]['emailContact'] ?? '';
                DateTime ratingTime = _ratings[index]['ratingTime'] ?? '';
                _userName = _ratings[index]['userName'] ?? '';
                String firstChar = '';
                bool isEmpty = true;
                if (_userName != '') {
                  isEmpty = false;
                  firstChar = _userName[0].toUpperCase();
                }
                return Padding(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 10, screenWidth * 0.05, 10),
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              isEmpty
                                  ? CircleAvatar(
                                radius: screenWidth * 0.075,
                                child: Icon(
                                  Icons.person,
                                  size: screenWidth * 0.075,
                                  color: Colors.blue,
                                ),
                                backgroundColor: Colors.white,
                              )
                                  : CircleAvatar(
                                radius: screenWidth * 0.075,
                                child: Text(
                                  firstChar,
                                  style: TextStyle(color: Colors.blue, fontSize: screenWidth * 0.075),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              SizedBox(width: screenWidth * 0.025),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${ratingTime.year}:${ratingTime.month}:${ratingTime.day}:${ratingTime.hour}:${ratingTime.minute}',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < rating ? Icons.star : Icons.star_border,
                                        color: Colors.yellow,
                                        size: screenWidth * 0.05,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                                        onPressed: () => _launchWhatsApp(phone),
                                        iconSize: screenWidth * 0.075,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(FontAwesomeIcons.google, color: Colors.blue),
                                        onPressed: () => _sendEmail(emailContact),
                                        iconSize: screenWidth * 0.075,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ): Padding(padding:EdgeInsets.all(20),
        child:Center(
            child:Text(languageProvider.localizedStrings['loginrate'] ?? 'Please Login To Show The Ratings',style: TextStyle(color: Colors.blue,fontSize: 20,fontWeight: FontWeight.bold),)),
      ),);
  }
}
// class ButtonGridadmin extends StatefulWidget {
//   const ButtonGridadmin({Key? key}) : super(key: key);
//
//   @override
//   _ButtonGridadmin createState() => _ButtonGridadmin();
// }
//
// class _ButtonGridadmin extends State<ButtonGrid> {
//   bool isLogin = false;
//   FocusNode _focusNode=FocusNode();
//   @override
//   void initState() {
//     super.initState();
//     _loadLoginState();
//     _focusNode.requestFocus();
//   }
//
//   Future<void> _loadLoginState() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isLogin = prefs.getBool('isLoggedIn') ?? false;
//     });
//   }
//   void dispose() {
//     // Clean up the FocusNode when the widget is disposed
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final languageProvider = Provider.of<LanguageProvider>(context);
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     return GestureDetector(
//       child:  Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: CustomButton(
//                       icon: Icons.energy_savings_leaf,
//                       label: languageProvider.localizedStrings['verbs'] ?? 'Verbs',
//                       page: VerbsPageadmin(isLogin: isLogin,),
//                       darkMode: themeProvider.isDarkMode,
//                     ),
//                   ),
//                   SizedBox(width: 15),
//                   Expanded(
//                     child: CustomButton(
//                       icon: Icons.sentiment_satisfied,
//                       label: languageProvider.localizedStrings['emotions'] ?? 'Emotions',
//                       page: EmotionsPageadmin(isLogin: isLogin,),
//                       darkMode: themeProvider.isDarkMode,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: CustomButton(
//                       icon: Icons.location_on,
//                       label: languageProvider.localizedStrings['places'] ?? 'Places',
//                       page: PlacePageadmin(isLogin: isLogin,),
//                       darkMode: themeProvider.isDarkMode,
//                     ),
//                   ),
//                   SizedBox(width: 15),
//                   Expanded(
//                     child: CustomButton(
//                       icon: Icons.question_answer,
//                       label: languageProvider.localizedStrings['questions'] ?? 'Questions',
//                       page: QuestionPageadmin(isLogin: isLogin,),
//                       darkMode: themeProvider.isDarkMode,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: CustomButton(
//                       icon: Icons.person,
//                       label: languageProvider.localizedStrings['me'] ?? 'Me',
//                       page: MePageadmin(isLogin: isLogin,),
//                       darkMode: themeProvider.isDarkMode,
//                     ),
//                   ),
//                   SizedBox(width: 15),
//                   Expanded(
//                     child: CustomButton(
//                       icon: Icons.handshake,
//                       label: languageProvider.localizedStrings['welcomeWords'] ?? 'Welcome',
//                       page: WelcomePageadmin(isLogin: isLogin,),
//                       darkMode: themeProvider.isDarkMode,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),);
//   }
// }
