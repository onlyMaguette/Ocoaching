import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patient_flutter/common/chat_widget/chat_bottom_text_filed.dart';
import 'package:patient_flutter/common/fancy_button.dart';
import 'package:patient_flutter/model/chat/chat.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/message_chat_screen/message_chat_screen_controller.dart';
import 'package:patient_flutter/screen/message_chat_screen/widget/message_center_area.dart';
import 'package:patient_flutter/utils/color_res.dart';

import 'widget/message_chat_top_bar.dart';

class MessageChatScreen extends StatelessWidget {
  final Conversation? conversation;
  final RegistrationData? userData;

  const MessageChatScreen({Key? key, required this.conversation, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = MessageChatScreenController(conversation: conversation, userData: userData);
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: GestureDetector(
        onTap: controller.allScreenTap,
        child: GetBuilder(
          init: controller,
          builder: (controller) => Stack(
            children: [
              Column(
                children: [
                  MessageChatTopBar(
                    conversation: controller.conversation,
                    controller: controller,
                  ),
                  MessageCenterArea(
                    scrollController: controller.scrollController,
                    chatData: controller.chatData,
                    userData: controller.userData,
                    onLongPress: controller.onLongPress,
                    timeStamp: controller.timeStamp,
                  ),
                  ChatBottomTextFiled(
                    msgController: controller.msgController,
                    onSendTap: controller.onSendBtnTap,
                    onTextFiledTap: controller.onTextFiledTap,
                  ),
                ],
              ),
              Positioned(
                right: Directionality.of(context) == TextDirection.rtl ? null : 6,
                bottom: 4,
                left: Directionality.of(context) == TextDirection.rtl ? 6 : null,
                child: SafeArea(
                  top: false,
                  child: FancyButton(
                    key: controller.key,
                    onCameraTap: () => controller.onImageTap(source: ImageSource.camera),
                    onGalleryTap: () => controller.onImageTap(source: ImageSource.gallery),
                    onVideoTap: controller.onVideoTap,
                    isOpen: controller.isOpen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
