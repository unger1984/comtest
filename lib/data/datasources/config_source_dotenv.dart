// ignore_for_file: avoid-late-keyword
import 'package:comtest/domain/datasources/config_source.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class ConfigSourceDotenv extends ConfigSource {
  static final _log = Logger('ConfigSourceDotenv');
  late Future<void> _initialize;

  ConfigSourceDotenv() {
    // Тут так надо.
    // ignore: avoid-async-call-in-sync-function
    _initialize = _init();
  }

  Future<void> _init() async {
    try {
      await dotenv.load();
    } catch (error, stack) {
      _log.severe('loading .env', error, stack);
    }
  }

  @override
  Future<void> get initialize => _initialize;
}
