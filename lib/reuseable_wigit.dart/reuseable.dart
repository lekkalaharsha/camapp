import 'package:flutter/material.dart';

// Widget to display a logo image
Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
  );
}

// Reusable text field with optional suffix icon for password visibility toggle
TextField reusableTextField(
  String text,
  IconData icon,
  bool isPasswordType,
  TextEditingController controller, {
  IconButton? suffixIcon,
}) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle(
      color: Colors.white.withOpacity(0.9),
    ),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),
      suffixIcon: suffixIcon,
      label: Text(text),
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
    ),
    keyboardType:
        isPasswordType ? TextInputType.visiblePassword : TextInputType.emailAddress,
  );
}

// Reusable button with corrected property usage
Container reusableButton(BuildContext context, Function onTap, String text) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.black26;
          }
          return Colors.white;
        }),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
}

// Reusable widget for sign-up/sign-in option link
class SignUpOption extends StatelessWidget {
  final String questionText;
  final String actionText;
  final VoidCallback onTap;

  const SignUpOption({
    super.key,
    this.questionText = "Don't have an account?",
    this.actionText = "Sign Up",
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          questionText,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}