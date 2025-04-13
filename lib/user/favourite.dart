import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language.dart';

class MyFavoritesPage extends StatefulWidget {
  final bool isLogin;

  const MyFavoritesPage({Key? key, required this.isLogin}) : super(key: key);

  @override
  _MyFavoritesPageState createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {
  List<Map<String, dynamic>> _cards = [];
  final FlutterTts flutterTts = FlutterTts();
  bool network = false;

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connected to Mobile Network");
      network = true;
      print(network);
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Connected to WiFi Network");
      network = true;
      print(network);
    } else {
      print("No Internet Connection");
      network = false;
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
    _loadFavoriteCards();
    checkConnectivity();
  }

  Future<void> _loadFavoriteCards() async {
    final user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    List<Map<String, dynamic>> loadedCards = [];

    // Load favorite words from Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
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
      // Debugging: Print the loaded cards
      print("Loaded favorite cards: $_cards");
    }).catchError((error) {
      print("Failed to load favorite words from Firestore: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.localizedStrings['myfavorites'] ?? 'My Favorites',
          style: TextStyle(color: Colors.blue),
        ),
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: _cards.isEmpty
          ? Center(
        child: Text(
          languageProvider.localizedStrings['nofavorites'] ?? 'No favorite cards added yet',
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      )
          : SingleChildScrollView(
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
                      width: MediaQuery.of(context).size.width * 0.5, // Adjusted width
                      height: MediaQuery.of(context).size.height * 0.3, // Adjusted height
                    );
                  } else if (_cards[index]['image'].startsWith('http')) {
                    // Load image from URL
                    imageWidget = Image.network(
                      _cards[index]['image'],
                      width: MediaQuery.of(context).size.width * 0.5, // Adjusted width
                      height: MediaQuery.of(context).size.height * 0.3, // Adjusted height
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading network image: $error');
                        alert2(context, languageProvider.localizedStrings['loadyourwords'] ?? 'Load Your Words', languageProvider.localizedStrings['errorload'] ?? "Sorry Can't Load Your Words Know");
                        return Text('Error loading image');
                      },
                    );
                  } else {
                    // Load asset image
                    imageWidget = Image.asset(
                      _cards[index]['image'],
                      width: MediaQuery.of(context).size.width * 0.5, // Adjusted width
                      height: MediaQuery.of(context).size.height * 0.3, // Adjusted height
                    );
                  }
                } else {
                  imageWidget = Text('No image available');
                }
                // Debugging: Print the image path
                print('Image Path at Index $index: ${_cards[index]['image']}');

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Adjusted padding
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
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Adjusted padding
                                child: Text(
                                  word,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: MediaQuery.of(context).size.width * 0.05, // Adjusted font size
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.volume_up, size: MediaQuery.of(context).size.width * 0.06, color: Colors.blue), // Adjusted icon size
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
    );
  }
}
