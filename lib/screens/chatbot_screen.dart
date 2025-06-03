import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();

  // Historique complet des messages pour l'API OpenAI (rôle + contenu)
  final List<Map<String, String>> _chatHistory = [
    {
      'role': 'system',
      'content': '''Vous êtes un coach expert et compatissant en arrêt du tabac. Votre rôle est d'aider, conseiller et motiver une personne qui souhaite arrêter de fumer.Répondez toujours avec empathie, des conseils pratiques et des encouragements. Réponds en 5 phrases maximum avec des conseils qui peuvent être réalisé sur le moment et pas sur le long terme'''
    },
  ];

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Ajout du message utilisateur à l'historique local et chat UI
    setState(() {
      _messages.add(Message(text: trimmed, isUser: true));
    });
    _controller.clear();

    _chatHistory.add({'role': 'user', 'content': trimmed});

    // Préparer la requête à l'API OpenAI
    // Remplace par ta clé
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': _chatHistory,
      'temperature': 0.8,
      'max_tokens': 512,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final aiMessage = data['choices'][0]['message']['content'] as String;

        // Ajouter la réponse IA à l'historique et à l'UI
        setState(() {
          _messages.add(Message(text: aiMessage.trim(), isUser: false));
        });
        _chatHistory.add({'role': 'assistant', 'content': aiMessage.trim()});
      } else {
        // En cas d’erreur HTTP, afficher un message d’erreur simple
        setState(() {
          _messages.add(Message(
            text: "Désolé, une erreur est survenue (${response.statusCode}).",
            isUser: false,
          ));
        });
      }
    } catch (e) {
      // En cas d’exception réseau
      setState(() {
        _messages.add(Message(
          text: "Impossible de contacter le service d’IA. Vérifie ta connexion.",
          isUser: false,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[_messages.length - 1 - index];
              return Align(
                alignment:
                msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: msg.isUser ? Colors.black : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                        color: msg.isUser ? Colors.white : Colors.black),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
