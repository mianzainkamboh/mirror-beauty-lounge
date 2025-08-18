import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chat_message.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create or get existing chat room for user
  Future<String> createOrGetChatRoom() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get user data from Firestore
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final userName = userData?['name'] ?? 'Unknown User';

    final chatRoomId = 'chat_${user.uid}';
    
    // Check if chat room already exists
    final chatRoomDoc = await _firestore.collection('chatRooms').doc(chatRoomId).get();
    
    if (!chatRoomDoc.exists) {
      // Create new chat room
      final chatRoom = ChatRoom(
        id: chatRoomId,
        userId: user.uid,
        userName: userName,
        userEmail: user.email ?? '',
        createdAt: DateTime.now(),
        lastMessageAt: DateTime.now(),
        lastMessage: 'Chat started',
        unreadCount: 0,
        isActive: true,
      );
      
      await _firestore.collection('chatRooms').doc(chatRoomId).set(chatRoom.toMap());
    }
    
    return chatRoomId;
  }

  // Send text message
  Future<void> sendTextMessage(String chatRoomId, String content) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get user data
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final userName = userData?['name'] ?? 'Unknown User';

    final messageId = _firestore.collection('messages').doc().id;
    final message = ChatMessage(
      id: messageId,
      senderId: user.uid,
      senderName: userName,
      senderType: 'user',
      content: content,
      type: 'text',
      timestamp: DateTime.now(),
      chatRoomId: chatRoomId,
    );

    // Add message to messages collection
    await _firestore.collection('messages').doc(messageId).set(message.toMap());

    // Update chat room with last message
    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'lastMessage': content,
      'lastMessageAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String fileName) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      final storageRef = _storage.ref().child('chat_images/${user.uid}/$fileName');
      final uploadTask = storageRef.putFile(imageFile);
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Send image message
  Future<void> sendImageMessage(String chatRoomId, File imageFile, String fileName) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Upload image first
      final imageUrl = await uploadImage(imageFile, fileName);

      // Get user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final userName = userData?['name'] ?? 'Unknown User';

      final messageId = _firestore.collection('messages').doc().id;
      final message = ChatMessage(
        id: messageId,
        senderId: user.uid,
        senderName: userName,
        senderType: 'user',
        content: 'Image',
        type: 'image',
        imageUrl: imageUrl,
        imageName: fileName,
        timestamp: DateTime.now(),
        chatRoomId: chatRoomId,
      );

      // Add message to messages collection
      await _firestore.collection('messages').doc(messageId).set(message.toMap());

      // Update chat room with last message
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastMessage': 'Image',
        'lastMessageAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to send image: $e');
    }
  }

  // Pick image from gallery or camera
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Get messages stream for a chat room
  Stream<List<ChatMessage>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('messages')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromDocument(doc)).toList();
    });
  }

  // Get chat room stream
  Stream<ChatRoom?> getChatRoomStream(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return ChatRoom.fromDocument(doc);
      }
      return null;
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId) async {
    final user = currentUser;
    if (user == null) return;

    final messagesQuery = await _firestore
        .collection('messages')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .where('senderId', isNotEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messagesQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();

    // Update unread count in chat room
    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'unreadCount': 0,
    });
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }

  // Get file extension from file name
  String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  // Check if file type is supported
  bool isSupportedImageType(String fileName) {
    final extension = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'svg'].contains(extension);
  }
}