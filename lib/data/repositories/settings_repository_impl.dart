import 'dart:async';

import 'package:comtest/domain/datasources/settings_source.dart';
import 'package:comtest/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl extends SettingsRepository {
  final SettingsSource _settingsSource;
  String? _currentPrinter;

  SettingsRepositoryImpl({required SettingsSource settingsSource}) : _settingsSource = settingsSource {
    _currentPrinter = _settingsSource.getString('currentPrnter');
  }

  @override
  String? get currentPrinter => _currentPrinter;

  @override
  set currentPrinter(String? value) {
    _currentPrinter = value;
    if (value == null) {
      unawaited(_settingsSource.remove('currentPrnter'));
    } else {
      unawaited(_settingsSource.setString('currentPrnter', value));
    }
  }
}
