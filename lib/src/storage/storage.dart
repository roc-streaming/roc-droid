import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dto.dart';
import 'storage_exception.dart';

/// Persistent storage for settings.
class Storage {
  final Logger _logger;
  final SharedPreferences _prefs;
  static const String _receiverConfigKey = 'receiver_config';
  static const String _senderConfigKey = 'sender_config';

  Storage._create(this._logger, this._prefs);

  static Future<Storage> create(Logger logger) async {
    final prefs = await SharedPreferences.getInstance();
    return Storage._create(logger, prefs);
  }

  /// Reads the saved receiver configuration from shared preferences.
  /// Returns a default configuration if none is found.
  Future<ReceiverConfig> readReceiverConfig() async {
    final content = _prefs.getString(_receiverConfigKey);
    if (content == null) {
      throw StorageNotFoundException("No receiver config found");
    }

    try {
      final config = ReceiverConfig.fromJson(jsonDecode(content));
      _logger.d('Loaded receiver config: $config');
      return config;
    } on FormatException catch (_) {
      throw StorageException(
          ErrorCode.dbError, "Can't parse receiver config (malformed json)");
    } on Error catch (_) {
      throw StorageException(
          ErrorCode.dbError, "Can't parse receiver config (unexpected json)");
    }
  }

  /// Writes the receiver configuration to shared preferences.
  Future<void> writeReceiverConfig(ReceiverConfig config) async {
    final String content = jsonEncode(config.toJson());

    await _prefs.setString(_receiverConfigKey, content);
    _logger.d('Saved receiver config: $config');
  }

  /// Reads the saved sender configuration from shared preferences.
  /// Returns a default configuration if none is found.
  Future<SenderConfig> readSenderConfig() async {
    final content = _prefs.getString(_senderConfigKey);
    if (content == null) {
      throw StorageNotFoundException("No sender config found");
    }

    try {
      final config = SenderConfig.fromJson(jsonDecode(content));
      _logger.d('Loaded sender config: $config');
      return config;
    } on FormatException catch (_) {
      throw StorageException(
          ErrorCode.dbError, "Can't parse sender config (malformed json)");
    } on Error catch (_) {
      throw StorageException(
          ErrorCode.dbError, "Can't parse sender config (unexpected json)");
    }
  }

  /// Writes the sender configuration to shared preferences.
  Future<void> writeSenderConfig(SenderConfig config) async {
    final String content = jsonEncode(config.toJson());

    await _prefs.setString(_senderConfigKey, content);
    _logger.d('Saved sender config: $config');
  }
}
