import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/confirmation_dialog.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/chat/appointment_chat.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreenController extends GetxController {
  int uid = 0;
  int? remoteUserId;
  bool isJoined = false;
  late RtcEngine agoraEngine;
  bool isMuted = true;
  bool isVideo = true;
  bool isRemoteMutedVideo = false;
  bool isRemoteMutedAudio = false;
  AppointmentChat appointmentChat;
  int type = 0;

  VideoCallScreenController(this.appointmentChat);

  @override
  void onReady() {
    setupVideoSDKEngine();
    super.onReady();
  }

  Future<void> setupVideoSDKEngine() async {
    await [Permission.microphone, Permission.camera].request();
    //CustomUi.loader();
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine
        .initialize(const RtcEngineContext(appId: ConstRes.agoraAppId));
    await agoraEngine.enableVideo();

    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          isJoined = true;
          update();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          remoteUserId = remoteUid;
          type = 0;
          update();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          type = 1;
          update();
          leave();
        },
        onUserMuteVideo: (connection, remoteUid, muted) {
          isRemoteMutedVideo = muted;
          update();
          log('🛑 $muted');
        },
        onUserMuteAudio: (connection, remoteUid, muted) {
          isRemoteMutedAudio = muted;
          update();
        },
      ),
    );
    join();
  }

  void join() async {
    String token = appointmentChat.videoCall?.token ?? '';
    String channelId = appointmentChat.videoCall?.channelId ?? '';
    await agoraEngine.startPreview();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelId,
      options: options,
      uid: uid,
    );
    Get.back();
  }

  void leave() {
    if (type == 0) {
      Get.dialog(ConfirmationDialog(
        onPositiveBtn: () {
          channelLeave(true);
        },
        title: S.current.areYouSure,
        positiveText: S.current.exit,
        positiveTextColor: ColorRes.lightRed,
      ));
    } else if (type == 1) {
      channelLeave(true);
    } else {
      channelLeave(false);
    }
  }

  channelLeave(bool value) {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    agoraEngine.leaveChannel().then((v) {
      isJoined = false;
      remoteUserId == null;
      Get.back(result: value);
    });
  }

  void muteUnMute() async {
    if (isMuted) {
      isMuted = false;
      await agoraEngine.enableLocalAudio(false);
    } else {
      isMuted = true;
      await agoraEngine.enableLocalAudio(true);
    }
    update();
  }

  void videoDisable() async {
    if (isVideo) {
      isVideo = false;
      await agoraEngine.enableLocalVideo(false);
    } else {
      isVideo = true;
      await agoraEngine.enableLocalVideo(true);
    }
    update();
  }

  @override
  void onClose() async {
    await agoraEngine.leaveChannel();
    agoraEngine.release();
    super.onClose();
  }
}
