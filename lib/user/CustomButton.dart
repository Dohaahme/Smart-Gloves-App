import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final StatefulWidget page; // Change the type to StatefulWidget
  final bool darkMode;

  const CustomButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.page,
    required this.darkMode,
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.25, // 25% of the screen height
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isPressed = !_isPressed;
          });
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => widget.page,
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween(
                    begin: Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.blue;
            }
            return widget.darkMode ? Colors.grey[800] : Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.025), // 2.5% of screen width
            ),
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white;
            }
            return widget.darkMode ? Colors.blue : Colors.blue;
          }), // Changed the color to blue when in dark mode
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: screenWidth * 0.175, // 17.5% of the screen width
              color: widget.darkMode ? Colors.blue[100] : null, // Added condition to set color to blue in dark mode
            ),
            SizedBox(height: screenHeight * 0.02), // 2% of the screen height
            Text(
              widget.label,
              style: TextStyle(
                color: widget.darkMode ? Colors.blue[100] : null,
                fontSize: screenWidth * 0.05, // 5% of the screen width
              ),
            ),
          ],
        ),
      ),
    );
  }
}
