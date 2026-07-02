import 'package:get/get.dart';

import '../../data/models/chat_user_profile_model.dart';
import '../../data/repositories/openim_chat_repository.dart';
import '../utils/log_util.dart';

class ChatUserProfileService extends GetxService {
  static const String tag = 'ChatUserProfileService';

  static ChatUserProfileService get to => Get.find();

  final OpenIMChatRepository _repository = OpenIMChatRepository();
  final Map<int, ChatUserProfileModel> _cache = {};

  ChatUserProfileModel? profileForOpenIMUserID(String? userID) {
    final id = _parseUserID(userID);
    if (id == null) return null;
    return _cache[id];
  }

  Future<Map<int, ChatUserProfileModel>> getProfilesForOpenIMUserIDs(
    Iterable<String?> userIDs,
  ) async {
    final ids = userIDs
        .map(_parseUserID)
        .whereType<int>()
        .where((id) => id > 0)
        .toSet();
    if (ids.isEmpty) return {};

    final missing = ids.where((id) => !_cache.containsKey(id)).toList();
    if (missing.isNotEmpty) {
      try {
        final profiles = await _repository.getUserProfiles(missing);
        for (final profile in profiles) {
          _cache[profile.userId] = profile;
        }
      } catch (e) {
        LogUtil.e('Load chat user profiles failed: $e', tag: tag);
      }
    }

    return {
      for (final id in ids)
        if (_cache[id] != null) id: _cache[id]!,
    };
  }

  int? _parseUserID(String? userID) {
    final value = userID?.trim();
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }
}
