import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../models/chat_models.dart';
import '../../widgets/common/custom_button.dart';
import 'chat_detail_controller.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatDetailController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text(controller.otherPartyName.value)),
        actions: [
          Obx(() {
            if (controller.collaborationId.value.isNotEmpty) {
              return IconButton(
                onPressed: () => controller.viewCollaboration(),
                icon: const Icon(Icons.handshake),
                tooltip: 'View Collaboration',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: AppStyles.heading3.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start the conversation by sending a message',
                        style: AppStyles.body2.copyWith(
                          color: AppColors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _buildMessageItem(context, message, controller);
                  },
                ),
              );
            }),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment button
                  IconButton(
                    onPressed: () => controller.pickAttachment(),
                    icon: const Icon(Icons.attach_file),
                    color: AppColors.grey,
                  ),
                  
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      focusNode: controller.messageFocus,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                    ),
                  ),
                  // Removed the Container widget as it was causing errors due to undefined variables and incorrect usage.
                  ),
                
                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatTime(DateTime.now()), // Assuming DateTime.now() as a placeholder for demonstration
                    style: AppStyles.caption.copyWith(
                      color: AppColors.grey,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
      )
      ],
      ),
    );
  }

  Widget _buildSystemMessage(MessageModel message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.message,
          style: AppStyles.caption.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (messageDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == yesterday) {
      return 'Yesterday ${DateFormat('HH:mm').format(time)}';
    } else {
      return DateFormat('MMM dd, HH:mm').format(time);
    }
  }

  Widget _buildMessageItem(
    BuildContext context,
    MessageModel message,
    ChatDetailController controller,
  ) {
    // Define isCurrentUser based on the message sender
    final bool isCurrentUser = message.senderId == controller.currentUserId.value;
    final bool isSystemMessage = message.senderId == 'system';
    
    if (isSystemMessage) {
      return _buildSystemMessage(message);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Other user's avatar
          if (!isCurrentUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: controller.otherPartyImage.value != null
                  ? CachedNetworkImageProvider(controller.otherPartyImage.value)
                  : null,
              child: controller.otherPartyImage.value == null
                  ? Text(
                      controller.otherPartyName.value.isNotEmpty
                          ? controller.otherPartyName.value.substring(0, 1)
                          : '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          
          const SizedBox(width: 8),
          
          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Attachments
                if (message.attachments.isNotEmpty)
                  GestureDetector(
                    onTap: () => controller.viewAttachment(message.attachments.first),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                        maxHeight: 200,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: message.attachments.first,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
                // Message bubble
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isCurrentUser
                          ? const Radius.circular(16)
                          : const Radius.circular(0),
                      bottomRight: isCurrentUser
                          ? const Radius.circular(0)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    message.message,
                    style: AppStyles.body2.copyWith(
                      color: isCurrentUser ? Colors.white : AppColors.dark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}