import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:comtest/domain/datasources/printer_source.dart';
import 'package:comtest/presentation/app.dart';
import 'package:comtest/utils/app_bloc_observer.dart';
import 'package:comtest/utils/logging.dart';
import 'package:comtest/utils/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logging.setup();
  await ServiceLocator.setup();

  Bloc.observer = AppBlocObserver.instance();
  Bloc.transformer = bloc_concurrency.sequential<Object?>();

  Logger('MAIN').fine(await GetIt.I<PrinterSource>().loadPrinters());

  runApp(const App());
}
