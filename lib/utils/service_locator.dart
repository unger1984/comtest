import 'package:comtest/data/datasources/config_source_dotenv.dart';
import 'package:comtest/data/datasources/printer_source_cups.dart';
import 'package:comtest/data/datasources/settings_source_secure_storage.dart';
import 'package:comtest/data/repositories/settings_repository_impl.dart';
import 'package:comtest/domain/datasources/config_source.dart';
import 'package:comtest/domain/datasources/printer_source.dart';
import 'package:comtest/domain/datasources/settings_source.dart';
import 'package:comtest/domain/repositories/settings_repository.dart';
import 'package:get_it/get_it.dart';

class ServiceLocator {
  static Future<void> setup() async {
    final configSource = ConfigSourceDotenv();
    await configSource.initialize;

    final settingsSource = SettingsSourceSecureStorage();
    await settingsSource.initialize;

    GetIt.I.registerSingleton<ConfigSource>(configSource);
    GetIt.I.registerSingleton<SettingsSource>(settingsSource);
    GetIt.I.registerSingleton<PrinterSource>(PrinterSourceCups());

    GetIt.I.registerSingleton<SettingsRepository>(SettingsRepositoryImpl(settingsSource: settingsSource));
  }
}
