import 'dart:io';
import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class Chatscreen extends StatefulWidget {
  final String? imagePath; // The captured image path
  final String? prompt; // The prompt for the image

  const Chatscreen({super.key, this.imagePath, this.prompt});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User",);
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "AI for all ",
    profileImage:
        "assets/images/download.jpeg", // Replace with the actual path to your image
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
        title: const Text("AI for all"),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(trailing: [
        IconButton(
          onPressed: _sendMediaMessageFromCamera,
          icon: const Icon(Icons.image),
        )
      ]),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    _getGeminiResponse(chatMessage);
  }

  void _sendMediaMessage(String imagePath) {
    ChatMessage chatMessage = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: widget.prompt ?? "Describe the picture?",
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

  void _sendMediaMessageFromCamera() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (file != null) {
      _sendMediaMessage(file.path);
    }
  }

  void _getGeminiResponse(ChatMessage chatMessage) {
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen((event) {
        String response = event.content?.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";

        // Manually create a new message and concatenate the response
        if (messages.isNotEmpty && messages.first.user == geminiUser) {
          ChatMessage lastMessage = messages.removeAt(0);
          lastMessage = ChatMessage(
            user: geminiUser,
            createdAt: lastMessage.createdAt,
            text: lastMessage.text + response,
            medias: lastMessage.medias,
          );
          setState(() {
            messages = [lastMessage, ...messages];
          });
        } else {
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
