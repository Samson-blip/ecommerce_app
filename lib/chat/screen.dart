import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String recipientEmail;

  ChatScreen(this.recipientEmail);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage(String messageText) {
    if (messageText.isNotEmpty) {
      final currentUserEmail = _auth.currentUser?.email ?? "";
      final chatRoomId = _getChatRoomId(currentUserEmail, widget.recipientEmail);

      _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add({
            'text': messageText,
            'sender': currentUserEmail,
            'timestamp': FieldValue.serverTimestamp(),
          });

      _messageController.clear();
    }
  }

  String _getChatRoomId(String user1, String user2) {
    final email1 = _auth.currentUser?.email ?? "";
    if (user1.compareTo(user2) <= 0) {
      return '$email1-$user2';
    } else {
      return '$user2-$email1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.recipientEmail}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('chats')
                  .doc(_getChatRoomId(_auth.currentUser?.email ?? "", widget.recipientEmail))
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final messages = snapshot.data?.docs ?? <QueryDocumentSnapshot>[];
                List<Widget> messageWidgets = [];

                for (var message in messages) {
                  final messageText = message['text'];
                  final messageSender = message['sender'];

                  var messageWidget = MessageWidget(
                    sender: messageSender,
                    text: messageText,
                    isMe: _auth.currentUser?.email == messageSender,
                  );
                  messageWidgets.add(messageWidget);
                }

                return ListView(
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  MessageWidget({
    required this.sender,
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            color: isMe ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(12.0),
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Text(
            sender,
            style: TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
