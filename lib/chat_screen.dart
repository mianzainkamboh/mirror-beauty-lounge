import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/chat_message.dart';
import 'services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  
  String? _chatRoomId;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final chatRoomId = await _chatService.createOrGetChatRoom();
      setState(() {
        _chatRoomId = chatRoomId;
        _isLoading = false;
      });
      
      // Mark messages as read when entering chat
      await _chatService.markMessagesAsRead(chatRoomId);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendTextMessage() async {
    if (_messageController.text.trim().isEmpty || _chatRoomId == null || _isSending) {
      return;
    }

    final message = _messageController.text.trim();
    _messageController.clear();
    
    setState(() {
      _isSending = true;
    });

    try {
      await _chatService.sendTextMessage(_chatRoomId!, message);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _pickAndSendImage() async {
    if (_chatRoomId == null || _isSending) return;

    try {
      // Show image source selection
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      setState(() {
        _isSending = true;
      });

      final File? imageFile = await _chatService.pickImage(source: source);
      if (imageFile != null) {
        final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        // Check if file type is supported
        if (!_chatService.isSupportedImageType(fileName)) {
          throw Exception('Unsupported file type. Please select JPG, PNG, or SVG files.');
        }

        await _chatService.sendImageMessage(_chatRoomId!, imageFile, fileName);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFFF8F8F)),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFFF8F8F)),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chat with Admin',
          style: TextStyle(
            color: Color(0xFFFF8F8F),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFF8F8F)),
            onPressed: _initializeChat,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8F8F)),
              ),
            )
          : _chatRoomId == null
              ? const Center(
                  child: Text(
                    'Failed to initialize chat. Please try again.',
                    style: TextStyle(color: Color(0xFF888888)),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<ChatMessage>>(
                        stream: _chatService.getMessagesStream(_chatRoomId!),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error loading messages: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8F8F)),
                              ),
                            );
                          }

                          final messages = snapshot.data!;
                          
                          if (messages.isEmpty) {
                            return const Center(
                              child: Text(
                                'No messages yet. Start a conversation!',
                                style: TextStyle(color: Color(0xFF888888)),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return _buildMessageBubble(message);
                            },
                          );
                        },
                      ),
                    ),
                    _buildMessageInput(),
                  ],
                ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderType == 'user' && 
                 message.senderId == FirebaseAuth.instance.currentUser?.uid;
    final isAdmin = message.senderType == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: isAdmin ? const Color(0xFFFF8F8F) : const Color(0xFFF5F5F5),
              child: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: isAdmin ? Colors.white : const Color(0xFFFF8F8F),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      isAdmin ? 'Admin' : message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isAdmin ? const Color(0xFFFF8F8F) : const Color(0xFF888888),
                        fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? const Color(0xFFFF8F8F) 
                        : isAdmin 
                            ? const Color(0xFFF0F8FF)
                            : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                    border: isAdmin 
                        ? Border.all(color: const Color(0xFFFF8F8F), width: 1)
                        : null,
                  ),
                  child: message.type == 'text'
                      ? Text(
                          message.content,
                          style: TextStyle(
                            color: isMe 
                                ? Colors.white 
                                : isAdmin 
                                    ? const Color(0xFFFF8F8F)
                                    : const Color(0xFF333333),
                            fontWeight: isAdmin ? FontWeight.w500 : FontWeight.normal,
                          ),
                        )
                      : _buildImageMessage(message),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: Color(0xFFF5F5F5),
              child: Icon(Icons.person, color: Color(0xFFFF8F8F), size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageMessage(ChatMessage message) {
    if (message.imageUrl == null) {
      return Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Color(0xFF888888), size: 40),
              SizedBox(height: 8),
              Text(
                'Image not available',
                style: TextStyle(color: Color(0xFF888888), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showFullScreenImage(message.imageUrl!),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 200,
          maxHeight: 200,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: message.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 200,
              height: 150,
              color: const Color(0xFFF5F5F5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8F8F)),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200,
              height: 150,
              color: const Color(0xFFF5F5F5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Color(0xFF888888), size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8F8F)),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error, color: Colors.white, size: 50),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Image attachment button
          IconButton(
            icon: Icon(
              Icons.image,
              color: _isSending ? const Color(0xFFCCCCCC) : const Color(0xFFFF8F8F),
            ),
            onPressed: _isSending ? null : _pickAndSendImage,
          ),
          // Text input field
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isSending,
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
              onSubmitted: (_) => _sendTextMessage(),
              textInputAction: TextInputAction.send,
            ),
          ),
          // Send button
          IconButton(
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8F8F)),
                    ),
                  )
                : const Icon(Icons.send, color: Color(0xFFFF8F8F)),
            onPressed: _isSending ? null : _sendTextMessage,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}