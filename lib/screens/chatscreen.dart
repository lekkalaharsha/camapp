import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Chatscreen extends StatefulWidget {
  final String? imagePath; // The captured image path

  const Chatscreen({super.key, this.imagePath});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
        "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  @override
  void initState() {
    super.initState();
    if (widget.imagePath != null) {
      _sendMediaMessage(widget.imagePath!); // Send the captured image if it exists
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Gemini Chat",
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(trailing: [
        IconButton(
          onPressed: _sendMediaMessageFromCamera,
          icon: const Icon(
            Icons.image,
          ),
        )
      ]),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  // Method to send a regular message
  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    // Simulate a response from the Gemini bot (You can replace this with actual logic)
    String response = "I received your message!";
    ChatMessage botMessage = ChatMessage(
      user: geminiUser,
      createdAt: DateTime.now(),
      text: response,
    );
    setState(() {
      messages = [botMessage, ...messages];
    });
  }

  // Method to send a media message when the image is captured
  void _sendMediaMessage(String imagePath) {
    ChatMessage chatMessage = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: "Describe the picture?",
      medias: [
        ChatMedia(
          url: imagePath,
          fileName: "",
          type: MediaType.image,
        )
      ],
    );
    _sendMessage(chatMessage);
  }

  // Method to capture an image and send it as a media message
  void _sendMediaMessageFromCamera() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (file != null) {
      _sendMediaMessage(file.path); // Send the captured image
    }
  }
}

