import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderType; // 'user' or 'admin'
  final String content;
  final String type; // 'text' or 'image'
  final String? imageUrl;
  final String? imageName;
  final DateTime timestamp;
  final bool isRead;
  final String chatRoomId;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.content,
    required this.type,
    this.imageUrl,
    this.imageName,
    required this.timestamp,
    this.isRead = false,
    required this.chatRoomId,
  });

  // Convert ChatMessage to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'content': content,
      'type': type,
      'imageUrl': imageUrl,
      'imageName': imageName,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'chatRoomId': chatRoomId,
    };
  }

  // Create ChatMessage from Firestore document
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderType: map['senderType'] ?? 'user',
      content: map['content'] ?? '',
      type: map['type'] ?? 'text',
      imageUrl: map['imageUrl'],
      imageName: map['imageName'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      chatRoomId: map['chatRoomId'] ?? '',
    );
  }

  // Create ChatMessage from Firestore DocumentSnapshot
  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage.fromMap(data);
  }

  // Copy with method for updating message properties
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderType,
    String? content,
    String? type,
    String? imageUrl,
    String? imageName,
    DateTime? timestamp,
    bool? isRead,
    String? chatRoomId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      imageName: imageName ?? this.imageName,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      chatRoomId: chatRoomId ?? this.chatRoomId,
    );
  }
}

class ChatRoom {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String lastMessage;
  final int unreadCount;
  final bool isActive;

  ChatRoom({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.createdAt,
    required this.lastMessageAt,
    required this.lastMessage,
    this.unreadCount = 0,
    this.isActive = true,
  });

  // Convert ChatRoom to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'isActive': isActive,
    };
  }

  // Create ChatRoom from Firestore document
  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastMessageAt: (map['lastMessageAt'] as Timestamp).toDate(),
      lastMessage: map['lastMessage'] ?? '',
      unreadCount: map['unreadCount'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  // Create ChatRoom from Firestore DocumentSnapshot
  factory ChatRoom.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom.fromMap(data);
  }

  // Copy with method for updating chat room properties
  ChatRoom copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessage,
    int? unreadCount,
    bool? isActive,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
    );
  }
}