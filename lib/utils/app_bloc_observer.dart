import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class AppBlocObserver extends BlocObserver {
  static final log = Logger('BlocObserver');
  static AppBlocObserver? _instance;

  factory AppBlocObserver.instance() => _instance ??= const AppBlocObserver._();
  const AppBlocObserver._();

  @override
  // Тут так надно.
  // ignore: avoid-dynamic
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log.severe('Unhandled bloc exception', error, stackTrace);
  }
}
