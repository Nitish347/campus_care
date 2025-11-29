import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatController extends GetxController {
  final messages = <Map<String, dynamic>>[].obs;
  final messageController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void _loadMessages() {
    // Static UI data
    messages.value = [
      {
        'id': 'msg_001',
        'text': 'Hello, how is my child performing in class?',
        'sender': 'parent',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': 'msg_002',
        'text': 'Your child is doing very well. They are actively participating in class.',
        'sender': 'teacher',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      },
      {
        'id': 'msg_003',
        'text': 'Thank you for the update!',
        'sender': 'parent',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      },
    ];
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    final newMessage = {
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'text': messageController.text.trim(),
      'sender': 'teacher',
      'timestamp': DateTime.now(),
    };

    messages.add(newMessage);
    messageController.clear();
  }

  String formatTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }
}

