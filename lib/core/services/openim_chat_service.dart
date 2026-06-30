import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/openim_token_model.dart';
import '../../data/repositories/openim_chat_repository.dart';
import '../utils/log_util.dart';

class OpenIMChatService extends GetxService {
  static const String TAG = 'OpenIMChatService';

  static OpenIMChatService get to => Get.find();

  final OpenIMChatRepository _openIMChatRepository = OpenIMChatRepository();
  final RxBool isLoggedIn = false.obs;
  final RxList<ConversationInfo> conversationChanged =
      <ConversationInfo>[].obs;
  final Rxn<Message> newMessage = Rxn<Message>();
  final Rxn<List<ReadReceiptInfo>> readReceipt = Rxn<List<ReadReceiptInfo>>();
  final Rxn<RevokedInfo> messageRevoked = Rxn<RevokedInfo>();
  final RxInt totalUnreadCount = 0.obs;

  String? _apiAddr;
  String? _wsAddr;
  String? _currentUserID;
  Future<void>? _loginFuture;

  String? get currentUserID => _currentUserID;

  Future<void> ensureLoggedIn() async {
    if (isLoggedIn.value) return;
    await loginWithBackendToken();
  }

  Future<void> loginWithBackendToken() async {
    if (_loginFuture != null) {
      return _loginFuture;
    }
    _loginFuture = _doLoginWithBackendToken();
    try {
      await _loginFuture;
    } finally {
      _loginFuture = null;
    }
  }

  Future<void> refreshConversations() async {
    if (!isLoggedIn.value) return;

    try {
      final list =
          await OpenIM.iMManager.conversationManager.getConversationListSplit(
        offset: 0,
        count: 100,
      );
      conversationChanged.assignAll(list);
    } catch (e) {
      LogUtil.e('Refresh conversations failed: $e', tag: TAG);
    }
  }

  Future<void> _doLoginWithBackendToken() async {
    try {
      final token = await _openIMChatRepository.getToken();
      await initialize(token);
      await login(token.openIMUserID, token.token);
    } catch (e) {
      LogUtil.e('OpenIM login failed: $e', tag: TAG);
      rethrow;
    }
  }

  Future<void> initialize(OpenIMTokenModel token) async {
    if (_apiAddr == token.apiAddr && _wsAddr == token.wsAddr) return;

    final dir = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${dir.path}/openim');
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    LogUtil.d('OpenIM init: api=${token.apiAddr}, ws=${token.wsAddr}', tag: TAG);
    await OpenIM.iMManager.initSDK(
      platformID: token.platformID ?? _platform,
      apiAddr: token.apiAddr,
      wsAddr: token.wsAddr,
      dataDir: dataDir.path,
      logLevel: kReleaseMode ? 3 : 6,
      listener: OnConnectListener(
        onConnectSuccess: () {
          LogUtil.d('OpenIM connected', tag: TAG);
        },
        onConnectFailed: (code, errorMsg) {
          LogUtil.e('OpenIM connect failed: $code $errorMsg', tag: TAG);
        },
        onConnecting: () {
          LogUtil.d('OpenIM connecting', tag: TAG);
        },
        onKickedOffline: () {
          LogUtil.e('OpenIM kicked offline', tag: TAG);
          isLoggedIn.value = false;
        },
        onUserTokenExpired: () {
          LogUtil.e('OpenIM token expired', tag: TAG);
          isLoggedIn.value = false;
        },
        onUserTokenInvalid: () {
          LogUtil.e('OpenIM token invalid', tag: TAG);
          isLoggedIn.value = false;
        },
      ),
    );
    _registerListeners();
    _apiAddr = token.apiAddr;
    _wsAddr = token.wsAddr;
  }

  Future<void> login(String userID, String token) async {
    if (_currentUserID == userID && isLoggedIn.value) {
      await refreshConversations();
      return;
    }
    if (_currentUserID != null && _currentUserID != userID) {
      await logout();
    }

    LogUtil.d('OpenIM login: $userID', tag: TAG);
    await OpenIM.iMManager.login(userID: userID, token: token);
    _currentUserID = userID;
    isLoggedIn.value = true;
    await refreshConversations();
  }

  Future<void> logout() async {
    try {
      if (isLoggedIn.value) {
        await OpenIM.iMManager.logout();
      }
    } catch (e) {
      LogUtil.e('OpenIM logout failed: $e', tag: TAG);
    } finally {
      _currentUserID = null;
      isLoggedIn.value = false;
      conversationChanged.clear();
      newMessage.value = null;
      readReceipt.value = null;
      messageRevoked.value = null;
      totalUnreadCount.value = 0;
    }
  }

  void _registerListeners() {
    OpenIM.iMManager.conversationManager.setConversationListener(
      OnConversationListener(
        onConversationChanged: (list) {
          conversationChanged.assignAll(list);
        },
        onNewConversation: (list) {
          conversationChanged.assignAll(list);
        },
        onTotalUnreadMessageCountChanged: (count) {
          totalUnreadCount.value = count;
        },
        onSyncServerFinish: (_) => refreshConversations(),
        onSyncServerFailed: (_) => refreshConversations(),
      ),
    );
    OpenIM.iMManager.messageManager.setAdvancedMsgListener(
      OnAdvancedMsgListener(
        onRecvNewMessage: (message) {
          newMessage.value = message;
          refreshConversations();
        },
        onRecvOfflineNewMessage: (message) {
          newMessage.value = message;
          refreshConversations();
        },
        onRecvC2CReadReceipt: (list) {
          readReceipt.value = list;
        },
        onNewRecvMessageRevoked: (info) {
          messageRevoked.value = info;
          refreshConversations();
        },
      ),
    );
  }

  int get _platform {
    if (GetPlatform.isIOS) return 1;
    if (GetPlatform.isAndroid) return 2;
    return 5;
  }
}
