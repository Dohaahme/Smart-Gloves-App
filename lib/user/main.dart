// import 'dart:convert';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:test_gproject/language.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => LanguageProvider(), // Provide LanguageProvider
//       child: MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Speech Synthesis Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final FirebaseDatabase _database = FirebaseDatabase.instance;
//   final DatabaseReference _messageRef = FirebaseDatabase.instance.reference().child('message');
//   bool _cardsFetched = false;
//   String _message = '';
//   final FlutterTts flutterTts = FlutterTts();
//   String text = '';
//   String lastText = '';
//   final user = FirebaseAuth.instance.currentUser;
//
//   // void _setValue(String value) async {
//   //   await _messageRef.set(value);
//   //   print('Value set in the database');
//   // }
//   List<Map<String, dynamic>> _cards = [];
//   @override
//   Future<void> didChangeDependencies() async {
//     super.didChangeDependencies();
//     card(); // Fetch cards whenever dependencies change'
//     _loadCardsFromSharedPreferences();
//   }
//
//
//   @override
//   void dispose() {
//     _saveCardData(_cardData); // Save card data when the widget is disposed
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     card();
//     _loadCardsFromSharedPreferences();
//     // Initialize text with the translated version based on the initial language
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
//       text = _translateText(text, languageProvider);
//       setState(() {});
//     });
//
//     _messageRef.onValue.listen((event) {
//       setState(() async {
//
//         _message = (event.snapshot.value ?? '').toString();
//         print(_message + " love you__________");
//
//         // Add space between each value
//         if (text.isNotEmpty) {
//           text += ' ';
//         }
//         text += _message;
//
//         // Check if new text is added
//         if (text != lastText) {
//           await Future.delayed(Duration(milliseconds: 500));
//           _speak(_message, Provider.of<LanguageProvider>(context, listen: false)); // If new text, speak it
//           lastText = text; // Update lastText to current text
//         }
//       });
//     });
//
//     flutterTts.setSpeechRate(0.5);
//     flutterTts.setVolume(1.0);
//     flutterTts.setPitch(1.0);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final languageProvider = Provider.of<LanguageProvider>(context);
//     // Fetch cards only once when the widget is first built
//     return Center(
//       child: Card(
//         margin: EdgeInsets.all(20.0),
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Center(
//                 child: Text(
//                   _translateText(text, languageProvider), // Translate text dynamically
//                   style: TextStyle(color: Colors.blue, fontSize: 20),
//                 ),
//               ),
//               SizedBox(height: 10),
//               IconButton(
//                   icon: const Icon(Icons.volume_up, size: 40, color: Colors.blue),
//                   onPressed: () {
//                     _speak(text, languageProvider);
//                   }
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _translateText(String text, LanguageProvider languageProvider) {
//     final languageCode = languageProvider.appLocale.languageCode;
//
//     if (languageCode == "en") {
//       return text;
//     } else if (languageCode == "ar") {
//       List<String> words = text.split(' '); // Split text into words
//       List<String> translatedWords = [];
//
//       for (String word in words) {
//         var foundCard;
//         try {
//           // Use SharedPreferences data for translation
//           foundCard = _findTranslationFromSharedPreferences(word);
//           translatedWords.add(foundCard); // Translate word and add to list
//         } catch (e) {
//           // If translation not found, keep the original word
//           translatedWords.add(word);
//         }
//       }
//
//       return translatedWords.join(' '); // Join translated words back into a single string
//     }
//
//     return text; // Fallback to original text if language code is neither 'en' nor 'ar'
//   }
//
//   Future<String> _findTranslationFromSharedPreferences(String word) async {
//     // Load translation data from SharedPreferences
//     // Example: Replace this with your actual code to load translation data
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? translationJson = prefs.getString('translations');
//     if (translationJson != null) {
//       Map<String, dynamic> translationData = jsonDecode(translationJson);
//       // Check if translation exists for the word
//       if (translationData.containsKey(word.toLowerCase())) {
//         return translationData[word.toLowerCase()];
//       }
//     }
//     throw Exception("Translation not found for $word");
//   }
//
//
//
//   Future<void> _speak(String speechText, LanguageProvider languageProvider) async {
//     // Translate specific English words to Arabic
//     speechText = _translateText(speechText, languageProvider);
//
//     // Detect language from text content
//     String language = await _detectLanguage(speechText);
//
//     // Set text-to-speech language based on the detected language
//     await flutterTts.setLanguage(language);
//
//     // Speak the translated text
//     await flutterTts.speak(speechText);
//   }
//
//   Future<String> _detectLanguage(String text) async {
//     // Basic detection based on characters
//     if (text.contains(RegExp(r'[\u0600-\u06FF]'))) {
//       // Arabic
//       return 'ar-SA';
//     } else {
//       // English
//       return 'en-US';
//     }
//   }
//
//   Future<void> card() async {
//     _cards.clear();
//     String? userId = user?.uid;
//     List<String> collections = [
//       'verbs',
//       'emotions',
//       'me',
//       'places',
//       'welcome',
//       'questions',
//     ];
//
//
//     for (String collection in collections) {
//       try {
//         QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(userId)
//             .collection(collection)
//             .get();
//
//         for (var doc in querySnapshot.docs) {
//           _cards.add({
//             'word_en': doc['word_en'],
//             'word_ar': doc['word_ar'],
//           });
//         }
//
//         _cards.add({
//           'word_en': 'Go',
//           'word_ar': 'اذهب',
//         });
//         _cards.add({
//
//           'word_en': 'Want',
//           'word_ar': 'يريد',
//         });
//         _cards.add({
//           'word_en': 'Drink',
//           'word_ar': 'يشرب',
//         });
//         _cards.add({
//           'word_en': 'Happy',
//           'word_ar': 'سعيد',
//         });
//         _cards.add({
//           'word_en': 'Hungry',
//           'word_ar': 'جائع',
//         });
//         _cards.add({
//           'word_en': 'Upset',
//           'word_ar': 'منزعج',
//         });
//         _cards.add({
//           'word_en': 'Airport',
//           'word_ar': 'المطار',
//         });
//         _cards.add({
//           'word_en': 'Train Station',
//           'word_ar': 'محطة القطار',
//         });
//         _cards.add({
//           'word_en': 'How',
//           'word_ar': 'كيف',
//         });
//         _cards.add({
//           'word_en': 'Where',
//           'word_ar': 'اين',
//         });
//         _cards.add({
//           'word_en': 'What',
//           'word_ar': 'ماذا',
//         });
//         _cards.add({
//           'word_en': 'I',
//           'word_ar': 'أنا',
//         });
//         _cards.add({
//           'word_en': 'to',
//           'word_ar': 'ان',
//         });
//         _cards.add({
//
//           'word_en': 'Bye',
//           'word_ar': 'وداعا',
//         });
//         _cards.add({
//           'word_en': 'To',
//           'word_ar': 'الى',
//         });
//         _cards.add({
//           'word_en': 'Hello',
//           'word_ar': 'اهلا',
//         });
//         _cards.add({
//           'word_en': 'Are You',
//           'word_ar': 'انت تكون/ حالك',
//         });
//         setState(() {});
//       } catch (error) {
//         print("Failed to load words from $collection: $error");
//       }
//     }
//     await _saveCardsToSharedPreferences();
//   }
//
//   Future<void> _saveCardsToSharedPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String cardsJson = jsonEncode(_cards);
//     await prefs.setString('cards', cardsJson);
//   }
//
//   Future<void> _loadCardsFromSharedPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? cardsJson = prefs.getString('cards');
//     if (cardsJson != null) {
//       List<dynamic> decodedCards = jsonDecode(cardsJson);
//       _cards = decodedCards.cast<Map<String, dynamic>>();
//       setState(() {}); // Update UI after loading cards
//     }
//   }
// }
