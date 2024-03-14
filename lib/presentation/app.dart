import 'dart:async';

import 'package:comtest/domain/datasources/printer_source.dart';
import 'package:comtest/domain/repositories/settings_repository.dart';
import 'package:comtest/presentation/blocs/printer_bloc.dart';
import 'package:comtest/presentation/blocs/scanner_cubit.dart';
import 'package:comtest/presentation/screens/screen_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@immutable
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _scannerCubit = ScannerCubit();

  @override
  void dispose() {
    unawaited(_scannerCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ScannerCubit>.value(value: _scannerCubit),
          BlocProvider<PrinterBLoC>(
            create: (context) => PrinterBLoC(
              printerSource: GetIt.I<PrinterSource>(),
              settingsRepository: GetIt.I<SettingsRepository>(),
            ),
          ),
        ],
        child: BarcodeKeyboardListener(
          onBarcodeScanned: _scannerCubit.scan,
          child: const ScreenMain(),
        ),
      ),
    );
  }
}
