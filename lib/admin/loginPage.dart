import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'HomePage.dart';
import 'language.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
bool isLoggedIn = false; // Add this line to track authentication state globally






class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;
  LoginPage({Key? key, required this.onLogin}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool isLoggedIn = false;
  bool network=false;
  bool beginlogin=false;
  FocusNode _focusNode=FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    checkConnectivity();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!
      if (result == ConnectivityResult.mobile) {
        print("Connected to Mobile Network");
        network=true;
        print(network);
      } else if (result == ConnectivityResult.wifi) {
        print("Connected to WiFi Network");
        network=true;
        print(network);
      } else {
        print("No Internet Connection");
        network=false;
        print(network);
      }
    });
  }
  void dispose() {
    // Clean up the FocusNode when the widget is disposed
    _focusNode.dispose();
    super.dispose();
  }
  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      beginlogin = prefs.getBool('beginlogin') ?? false;
    });
  }

  final TextEditingController _textPasswordController = TextEditingController();
  final TextEditingController _textEmailController = TextEditingController();

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
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
    }
  }


  void alert(BuildContext context, String title, String content) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
              child: Text(languageProvider.localizedStrings['ok'] ?? 'Ok', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (title == "Welcome" || title == "أهلا وسهلا") {
                  widget.onLogin();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyAdminApp()));
                } else {
                  Navigator.of(context).pop();

                }
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
    final languageProvider = Provider.of<LanguageProvider>(context);
    return GestureDetector(
        onTap: () {
          // When tapped, remove focus from any focused field
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
        },
    child:  Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  languageProvider.localizedStrings['login'] ?? 'Login',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Text(languageProvider.localizedStrings['enterEmailPassword'] ?? 'Enter your email and password to log in'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _textEmailController,
                  decoration: InputDecoration(
                    hintText: languageProvider.localizedStrings['email'] ?? 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.blue.withOpacity(0.1),
                    filled: true,
                    prefixIcon: const Icon(Icons.email),
                  ),cursorColor: Colors.blue,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _textPasswordController,
                  decoration: InputDecoration(
                    hintText: languageProvider.localizedStrings['password'] ?? 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.blue.withOpacity(0.1),
                    filled: true,
                    prefixIcon: const Icon(Icons.password),

                  ),
                  obscureText: true,
                  cursorColor: Colors.blue,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if(network) {
                      if (_textEmailController.text.isEmpty &&
                          _textPasswordController.text.isEmpty) {
                        alert(context,
                            languageProvider.localizedStrings['error'] ??
                                'Error',
                            languageProvider
                                .localizedStrings['enterAllFields'] ??
                                'Please enter all fields.');
                      }
                      else {
                        try {

                          if(_textEmailController.text!="dohaahmed123@gmail.com"){
                            alert(context,
                                languageProvider.localizedStrings['error'] ??
                                    'Error',
                                languageProvider
                                    .localizedStrings['adminerror'] ??
                                    'That is not Admin Account');
                          }
                          else {
                            UserCredential userCredential = await FirebaseAuth
                                .instance.signInWithEmailAndPassword(
                              email: _textEmailController.text,
                              password: _textPasswordController.text,
                            );
                            SharedPreferences prefs = await SharedPreferences
                                .getInstance();
                            await prefs.setBool('isLoggedIn', true);
                            await prefs.setBool('beginlogin', true);
                            alert(context,
                                languageProvider.localizedStrings['welcome'] ??
                                    'Welcome',
                                languageProvider.localizedStrings['loggedIn'] ??
                                    'You have logged in successfully.');
                          }

                        } on FirebaseAuthException catch (e) {
                          String error=e.toString();
                          if(error=="[firebase_auth/invalid-credential] The supplied auth credential is incorrect, malformed or has expired."){
                            alert(context, languageProvider.localizedStrings['error'] ?? 'Error', languageProvider.localizedStrings['errorloggedIn'] ??
                                'the password or the username not correct.');
                          }
                          else{
                            alert(context, languageProvider.localizedStrings['error'] ?? 'Error', e.toString());
                          }
                          print('Error Login : $e');
                        }
                      }
                    }
                    else{
                      alert(context, languageProvider
                          .localizedStrings['error'] ?? 'Error',
                          languageProvider
                              .localizedStrings['notconnect'] ??
                              'there is no internet connection please try again later');
                    }
                  },
                  child: Text(
                    languageProvider.localizedStrings['login'] ?? 'Login',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                // ElevatedButton(
                //   onPressed: () async {
                //     final SharedPreferences prefs = await SharedPreferences.getInstance();
                //     await prefs.setBool('isLoggedIn', false);
                //     await prefs.setBool('beginlogin', true);
                //     //FirebaseAuth.instance.signOut();
                //     UserCredential userCredential = await FirebaseAuth
                //         .instance.signInWithEmailAndPassword(
                //       email: "dohaahmed123@gmail.com",
                //       password:"11111111",
                //     );
                //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                //     //Navigator.pop(context);
                //   },
                //   style: ElevatedButton.styleFrom(
                //     shape: const StadiumBorder(),
                //     padding: const EdgeInsets.symmetric(vertical: 16),
                //     backgroundColor: Colors.blue,
                //   ),
                //   child: Text(
                //     languageProvider.localizedStrings['guest'] ?? 'Guest',
                //     style: TextStyle(fontSize: 20, color: Colors.white),
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(languageProvider.localizedStrings['noAccount'] ?? 'Don\'t have an account?'),
                    // TextButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (context) => SignupPage(onLogin: widget.onLogin)),
                    //     );
                    //   },
                    //   child: Text(
                    //     languageProvider.localizedStrings['signUp'] ?? 'Sign Up',
                    //     style: TextStyle(color: Colors.blue),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}





// class SignupPage extends StatefulWidget {
//   final VoidCallback onLogin;
//
//   SignupPage({Key? key, required this.onLogin}) : super(key: key);
//
//   @override
//   _SignupPageState createState() => _SignupPageState();
// }
//
// class _SignupPageState extends State<SignupPage> {
//   final TextEditingController _textconfirmController = TextEditingController();
//   final TextEditingController _textEmailController = TextEditingController();
//   final TextEditingController _textPasswordController = TextEditingController();
//   bool network = false;
//
//   void alert(BuildContext context, String title, String content) {
//     final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(content),
//           actions: [
//             TextButton(
//               child: Text(languageProvider.localizedStrings['ok'] ?? 'Ok', style: TextStyle(color: Colors.blue)),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//   void alert2(BuildContext context, String title, String content) {
//     final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(content),
//           actions: [
//             TextButton(
//               child: Text(languageProvider.localizedStrings['ok'] ?? 'Ok', style: TextStyle(color: Colors.blue)),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginPage(onLogin: widget.onLogin)),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//   Future<void> checkConnectivity() async {
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.mobile) {
//       print("Connected to Mobile Network");
//       network=true;
//       print(network);
//     } else if (connectivityResult == ConnectivityResult.wifi) {
//       print("Connected to WiFi Network");
//       network=true;
//       print(network);
//     } else {
//       print("No Internet Connection");
//       network=false;
//       print(network);
//     }
//   }
//
//   @override
//   void initState(){
//     super.initState();
//     checkConnectivity();
//     Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
//       // Got a new connectivity status!
//       if (result == ConnectivityResult.mobile) {
//         print("Connected to Mobile Network");
//         network=true;
//         print(network);
//       } else if (result == ConnectivityResult.wifi) {
//         print("Connected to WiFi Network");
//         network=true;
//         print(network);
//       } else {
//         print("No Internet Connection");
//         network=false;
//         print(network);
//       }
//     });
// }
//
//   Future<void> _createUserCollection(String userId) async {
//     try {
//       final firestore = FirebaseFirestore.instance;
//       final userDoc = await firestore.collection('users').doc(userId).get();
//       if (!userDoc.exists) {
//         await firestore.collection('users').doc(userId).set({});
//         await firestore.collection('users').doc(userId).collection('verbs');
//         await firestore.collection('users').doc(userId).collection('emotions');
//         await firestore.collection('users').doc(userId).collection('me');
//         await firestore.collection('users').doc(userId).collection('places');
//         await firestore.collection('users').doc(userId).collection('questions');
//         await firestore.collection('users').doc(userId).collection('welcome');
//       }
//     } catch (error) {
//       print('Error creating user collection: $error');
//     }
//   }
//
//
//
//   Future<void> _signup(BuildContext context) async {
//     final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
//     final FirebaseAuth _auth = FirebaseAuth.instance;
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: _textEmailController.text,
//         password: _textPasswordController.text,
//       );
//
//       if (userCredential.user != null) {
//         await _createUserCollection(userCredential.user!.uid);
//         alert2(context, languageProvider.localizedStrings['congratulations'] ?? 'Congratulations',
//             languageProvider.localizedStrings['signedUp'] ?? 'You have signed up.');
//         widget.onLogin();
//       } else {
//         alert(context, languageProvider.localizedStrings['error'] ?? 'Error',
//             languageProvider.localizedStrings['signupFailed'] ?? 'Failed to sign up.');
//       }
//     } catch (error) {
//       print('Error creating user: $error');
//       alert(context, languageProvider.localizedStrings['error'] ?? 'Error', error.toString());
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final languageProvider = Provider.of<LanguageProvider>(context);
//     return Scaffold(
//       body: Container(
//         margin: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Column(
//               children: [
//                 Text(
//                   languageProvider.localizedStrings['createAccount'] ?? 'Create Account',
//                   style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
//                 ),
//                 Text(languageProvider.localizedStrings['enterDetails'] ?? 'Enter your details to sign up'),
//               ],
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 TextField(
//                   controller: _textEmailController,
//                   decoration: InputDecoration(
//                     hintText: languageProvider.localizedStrings['email'] ?? 'Email',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: Colors.blue.withOpacity(0.1),
//                     filled: true,
//                     prefixIcon: const Icon(Icons.email),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _textPasswordController,
//                   decoration: InputDecoration(
//                     hintText: languageProvider.localizedStrings['password'] ?? 'Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: Colors.blue.withOpacity(0.1),
//                     filled: true,
//                     prefixIcon: const Icon(Icons.password),
//                   ),
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _textconfirmController,
//                   decoration: InputDecoration(
//                     hintText: languageProvider.localizedStrings['confirmpassword'] ?? 'Confirm Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(18),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: Colors.blue.withOpacity(0.1),
//                     filled: true,
//                     prefixIcon: const Icon(Icons.password),
//                   ),
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (network) {
//                       if (_textconfirmController.text.isNotEmpty &&
//                           _textEmailController.text.isNotEmpty &&
//                           _textPasswordController.text.isNotEmpty) {
//                         if (_textPasswordController.text.length >= 8 &&
//                             _textEmailController.text.contains('@')) {
//                           if (_textconfirmController.text == _textPasswordController.text) {
//                             await _signup(context);
//                           } else {
//                             alert(context, languageProvider.localizedStrings['error'] ?? 'Error',
//                                 languageProvider.localizedStrings['passwordEmailconfirmation'] ?? 'The Passwords do not match.');
//                           }
//                         } else {
//                           alert(context, languageProvider.localizedStrings['error'] ?? 'Error',
//                               languageProvider.localizedStrings['passwordEmailValidation'] ?? 'Please enter a password with at least 8 characters and a valid email.');
//                         }
//                       } else {
//                         alert(context, languageProvider.localizedStrings['error'] ?? 'Error',
//                             languageProvider.localizedStrings['enterAllFields'] ?? 'Please enter all fields.');
//                       }
//                     } else {
//                       alert(context, languageProvider.localizedStrings['error'] ?? 'Error',
//                           languageProvider.localizedStrings['notconnect'] ?? 'There is no internet connection, please try again later.');
//                     }
//                   },
//                   child: Text(
//                     languageProvider.localizedStrings['signUp'] ?? 'Sign Up',
//                     style: TextStyle(fontSize: 20, color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     shape: const StadiumBorder(),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: Colors.blue,
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(languageProvider.localizedStrings['haveAccount'] ?? 'Already have an account?'),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text(
//                         languageProvider.localizedStrings['login'] ?? 'Login',
//                         style: TextStyle(color: Colors.blue),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





class FileManager {

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/user_data.txt');
  }

  static Future<File> writeUserData(String data) async {
    final file = await _localFile;
    return file.writeAsString('$data\n',mode: FileMode.append);
  }

  static Future<List<List<String>>?> readUserData() async {
    try {
      final file = await _localFile;
      List<String> lines = await file.readAsLines();
      List<List<String>> nestedList = lines.map((line) => line.split(',')).toList();
      return nestedList;
    } catch (e) {
      return null;
    }
  }
}
