import 'package:flutter/material.dart';
// Remove image_picker import for now since it's causing errors
// import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Project sync call scheduled for Friday at 11:00 AM.',
      'isMe': false,
      'time': '10:30 AM',
      'type': 'text'
    },
    {
      'text': 'Follow up with the design team about the UI updates.',
      'isMe': false,
      'time': '10:31 AM',
      'type': 'text'
    },
    {
      'text': 'Hello',
      'isMe': true,
      'time': '11:00 AM',
      'type': 'text'
    },
  ];

  // Function to handle image selection (temporarily disabled)
  Future<void> _pickImage() async {
    // This will be implemented after adding image_picker
    /*
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _messages.add({
          'image': pickedFile.path,
          'isMe': true,
          'time': 'Now',
          'type': 'image'
        });
      });
    }
    */

    // Temporary implementation - add a placeholder image
    setState(() {
      _messages.add({
        'image': 'assets/placeholder.png', // Use your asset
        'isMe': true,
        'time': 'Now',
        'type': 'image'
      });
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text,
          'isMe': true,
          'time': 'Now',
          'type': 'text'
        });
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chat',
          style: TextStyle(
            color: Color(0xFFFF8F8F), // Brand color
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            const CircleAvatar(
              backgroundColor: Color(0xFFF5F5F5),
              child: Icon(Icons.person, color: Color(0xFFFF8F8F)),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFFFF8F8F) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                  ),
                  child: message['type'] == 'text'
                      ? Text(
                    message['text'],
                    style: TextStyle(
                      color: isMe ? Colors.white : const Color(0xFF333333),
                    ),
                  )
                      : Container( // Changed to Container for image placeholder
                    width: 150,
                    height: 150,
                    color: const Color(0xFFF5F5F5),
                    child: const Icon(Icons.image, color: Color(0xFF888888), size: 50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message['time'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          if (isMe)
            const SizedBox(width: 8),
          if (isMe)
            const CircleAvatar(
              backgroundColor: Color(0xFFF5F5F5),
              child: Icon(Icons.person, color: Color(0xFFFF8F8F)),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          // Image attachment button
          IconButton(
            icon: const Icon(Icons.image, color: Color(0xFFFF8F8F)),
            onPressed: _pickImage,
          ),
          // Text input field
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Send button
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFFFF8F8F)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}