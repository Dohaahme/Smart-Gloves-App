import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class QuestionPage extends StatefulWidget {
  final bool isLogin;

  const QuestionPage({Key? key, required this.isLogin}) : super(key: key);

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  List<Map<String, dynamic>> _cards = [];
  final FlutterTts flutterTts = FlutterTts();
  final DatabaseReference _messageRef = FirebaseDatabase.instance.reference().child('word');
  final DatabaseReference _messagecheck = FirebaseDatabase.instance.reference().child('check');
  final DatabaseReference _messagecheck_add = FirebaseDatabase.instance.reference().child('check_add');

  bool network=false;
  List<bool> _isFavorited=[];
  void _setValue(String value) async {
    await _messageRef.set(value);
    print('Value set in the database');
  }
  void _setValue2(int value) async {
    await _messagecheck.set(value);
    print('Value set in the database');
  }
  void _setValue3(int value) async {
    await _messagecheck_add.set(value);
    print('Value set in the database');
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
      final languageProvider = Provider.of<LanguageProvider>(
          context, listen: false);
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionPage(isLogin: widget.isLogin)));
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
  void initState() {
    super.initState();
    _loadCards();
    checkConnectivity();
  }

  Future<void> _loadCards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final languageProvider =Provider.of<LanguageProvider>(context, listen: false);
    List<String>? cardStrings = prefs.getStringList('questions_cards');
    final user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    List<Map<String, dynamic>> loadedCards = [];


    // Load basic words
    if (cardStrings != null) {
      loadedCards = cardStrings.map((cardString) => json.decode(cardString))
          .toList()
          .cast<Map<String, dynamic>>();
    } else {
      // If no cards are stored, initialize with basic images
      loadedCards = [
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
      ];
    }

    // Load new words from Firestore and merge them with the basic words
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('questions')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        loadedCards.add({
          'image': doc['image'],
          'word_en': doc['word_en'],
          'word_ar': doc['word_ar'],
        });
      });

      setState(() {
        _cards = loadedCards;
      });
      _isFavorited = List<bool>.generate(_cards.length, (int index) => false);
      // Debugging: Print the loaded cards
      print("Loaded cards: $_cards");
    }).catchError((error) {
      print("Failed to load words from Firestore: $error");
      setState(() {
        _cards = loadedCards;
      });
      //alert2(context,languageProvider.localizedStrings['loadyourwords'] ?? 'Load Your Words',languageProvider.localizedStrings['errorload'] ?? "Sorry Can't Load Your Words Know");
    });
  }

  void showOverlayMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);
    Future.delayed(Duration(seconds: 10), () {
      overlayEntry.remove();
    });
  }

  Future<void> _addNewCard(BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final picker = ImagePicker();
    final con = context;
    final user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      TextEditingController _englishController = TextEditingController();
      TextEditingController _arabicController = TextEditingController();
      bool isAdding = false; // Track whether the button is in the adding state

      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  languageProvider.localizedStrings['AddNewCard'] ?? 'Add New Card',
                  style: TextStyle(color: Colors.blue),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _englishController,
                      decoration: InputDecoration(
                        labelText: languageProvider.localizedStrings['EnglishWord'] ?? 'English Word',
                        labelStyle: TextStyle(color: Colors.blue),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      cursorColor: Colors.blue,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _arabicController,
                      decoration: InputDecoration(
                        labelText: languageProvider.localizedStrings['ArabicWord'] ?? 'Arabic Word',
                        labelStyle: TextStyle(color: Colors.blue),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      cursorColor: Colors.blue,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      languageProvider.localizedStrings['Cancel'] ?? 'Cancel',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isAdding
                        ? null // Disable button when isAdding is true
                        : () async {
                      setState(() {
                        isAdding = true; // Disable button
                      });

                      showOverlayMessage(con, languageProvider.localizedStrings['PleaseWait'] ?? 'Please wait few seconds to add the word...');

                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      List<Map<String, dynamic>> updatedCards = [..._cards];

                      _setValue(_englishController.text);

                      await Future.delayed(Duration(seconds: 20));
                      String checkValue = "";
                      var snapshot = await _messagecheck_add.once();
                      DataSnapshot dataSnapshot = snapshot.snapshot;
                      checkValue = (dataSnapshot.value ?? '').toString();
                      print(checkValue);

                      if (checkValue == "1") {
                        _setValue3(0);
                        // Use the stored scaffoldContext to show the SnackBar
                        File file = File(pickedFile.path);
                        try {
                          FirebaseStorage storage = FirebaseStorage.instance;
                          String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
                          Reference ref = storage.ref().child('uploads/$fileName');
                          UploadTask uploadTask = ref.putFile(file);

                          await uploadTask;
                          String downloadURL = await ref.getDownloadURL();

                          // Add image URL and words to Firestore
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('questions')
                              .add({
                            'image': downloadURL,
                            'word_en': _englishController.text,
                            'word_ar': _arabicController.text,
                          });

                          updatedCards.add({
                            'image': downloadURL,
                            'word_en': _englishController.text.trim(),
                            'word_ar': _arabicController.text.trim(),
                          });

                          setState(() {
                            _cards = updatedCards;
                          });

                          Navigator.of(context).pop();
                        } catch (e) {
                          alert2(
                            con,
                            languageProvider.localizedStrings['wordstatues'] ?? 'Word statues',
                            languageProvider.localizedStrings['imageaddedfailed'] ?? 'Error uploading image',
                          );
                          print('Error uploading image: $e');
                        }
                        alert2(
                          con,
                          languageProvider.localizedStrings['wordstatues'] ?? 'Word statues',
                          languageProvider.localizedStrings['wordaddedsuccess'] ?? 'Word Added successfully',
                        );
                      } else {
                        // Use the stored scaffoldContext to show the SnackBar
                        alert2(
                          con,
                          languageProvider.localizedStrings['wordstatues'] ?? 'Word statues',
                          languageProvider.localizedStrings['wordaddedfailed'] ?? 'Sorry Failed to Add the word',
                        );
                      }

                      // Re-enable the button after processing
                      setState(() {
                        isAdding = false;
                      });
                    },
                    child: Text(
                      languageProvider.localizedStrings['Add'] ?? 'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.localizedStrings['questionwords'] ?? 'Question Words',
          style: TextStyle(color: Colors.blue),
        ),
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: Column(
        children: [
          Expanded(child:
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80.0),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    String word = languageProvider.appLocale.languageCode == 'ar'
                        ? _cards[index]['word_ar'] ?? ''
                        : _cards[index]['word_en'] ?? '';
                    Widget imageWidget;
                    if (_cards[index]['image'] != null) {
                      if (_cards[index]['image'].startsWith('/data')) {
                        // Load picked image from local file
                        imageWidget = Image.file(
                          File(_cards[index]['image']),
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.height * 0.30,
                        );
                      } else if (_cards[index]['image'].startsWith('http')) {
                        // Load image from URL
                        imageWidget = Image.network(
                          _cards[index]['image'],
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.height * 0.30,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading network image: $error');
                            //alert2(context,languageProvider.localizedStrings['loadyourwords'] ?? 'Load Your Words',languageProvider.localizedStrings['errorload'] ?? "Sorry Can't Load Your Words Know");
                            return Text(languageProvider.localizedStrings['errorphoto'] ?? 'error loading image',style: TextStyle(color: Colors.blue),);
                          },
                        );
                      } else {
                        // Load asset image
                        imageWidget = Image.asset(
                          _cards[index]['image'],
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.height * 0.30,
                        );
                      }
                    } else {
                      imageWidget = Text('No image available');
                    }
                    // Debugging: Print the image path
                    print('Image Path at Index $index: ${_cards[index]['image']}');

                    return Padding(
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                      child: Card(
                        elevation: 5,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(15), // Adjusted padding
                                    child: imageWidget,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(20, 20, 10, 20), // Adjusted padding
                                    child: Text(
                                      word,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 28, // Reduced font size
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.volume_up, size: 24, color: Colors.blue), // Smaller icon size
                                  onPressed: () async {
                                    if (word.contains(RegExp(r'[\u0600-\u06FF]'))) {
                                      // Arabic
                                      await flutterTts.setLanguage('ar-SA');
                                    } else {
                                      // English
                                      await flutterTts.setLanguage('en-US');
                                    }

                                    // Speak the translated text
                                    await flutterTts.speak(word);
                                  },
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: widget.isLogin
          ? FloatingActionButton(
        onPressed: () => _addNewCard(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        shape: CircleBorder(),
      )
          : null,
    );
  }
}
