import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language.dart';

class HowToUseScreen extends StatefulWidget {
  @override
  _HowToUseScreenState createState() => _HowToUseScreenState();
}

class _HowToUseScreenState extends State<HowToUseScreen> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  List<String> _screenshots = [
    'lib/assets/deaf-mute.webp',
    'lib/assets/home.jpg',
    'lib/assets/drawer.jpg',
    'lib/assets/chat.jpg',
    'lib/assets/dictionary.jpg',
    'lib/assets/verbsection.jpg',
    'lib/assets/rating.jpg'
  ];

  void _next() {
    if (_currentIndex < _screenshots.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _go();
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    Navigator.pop(context);
  }

  void _go() {
    Navigator.pop(context);
  }

  Widget _buildBulletIndicator(int index) {
    return GestureDetector(
      onTap: () => _pageController.jumpToPage(index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        width: 10.0,
        height: 10.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentIndex == index ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildScreenshotWidget(String imagePath) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width - 32.0,
          height: MediaQuery.of(context).size.height * 0.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    List<String> _descriptions = [
      languageProvider.localizedStrings['describtion1'] ?? 'Welcome We will Guide You To Use Our Application',
      languageProvider.localizedStrings['describtion2'] ?? 'Here You  Receive Words That Explain Your Hand Signs From The Gloves',
      languageProvider.localizedStrings['describtion3'] ?? 'Here You Can Use This Options Like change Language or Theme And You Can Login To Use Feedback and Favourite Features',
      languageProvider.localizedStrings['describtion4'] ?? 'Here The Normal Person Can Use The Words That In The Dictionary To Communicate With The Dump Or Deaf People And That Words Translated To Signs When Press Confirm Button',
      languageProvider.localizedStrings['describtion5'] ?? 'In The Dictionary You Will Find The Sections That Have Words And Signs That Related To Section Label',
      languageProvider.localizedStrings['describtion6'] ?? 'In Every Section You Can Find Words And Signs You Can Use In The Application And You Can Choose Your Favourite Words If You Logged In ',
      languageProvider.localizedStrings['describtion7'] ?? 'Please,Don\'t Forget Rating Us Thank You',
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text(
              languageProvider.localizedStrings['skip'] ?? 'Skip',
              style: TextStyle(color: Colors.blue, fontSize: 16.0),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _screenshots.length,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildScreenshotWidget(_screenshots[index]),
                    SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          _descriptions[index],
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 80.0),  // Adjust this to create enough space at the bottom
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _screenshots.length,
                        (index) => _buildBulletIndicator(index),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentIndex > 0)
                        TextButton(
                          onPressed: _previous,
                          style: TextButton.styleFrom(foregroundColor: Colors.blue),
                          child: Text(
                            languageProvider.localizedStrings['prev'] ?? 'Prev',
                            style: TextStyle(color: Colors.blue, fontSize: 16.0),
                          ),
                        ),
                      TextButton(
                        onPressed: _next,
                        style: TextButton.styleFrom(foregroundColor: Colors.blue),
                        child: Text(
                          _currentIndex == _screenshots.length - 1
                              ? languageProvider.localizedStrings['go'] ?? 'Go'
                              : languageProvider.localizedStrings['next'] ?? 'Next',
                          style: TextStyle(color: Colors.blue, fontSize: 16.0),
                        ),
                      ),
                    ],
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
