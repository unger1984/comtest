import 'package:comtest/domain/datasources/printer_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PrintType {
  cpcl,
  text,
}

sealed class PrinterEvent {
  const PrinterEvent();
  const factory PrinterEvent.init() = _InitPrinterEvent;
  const factory PrinterEvent.print(PrintType type, String printer, String path) = _PrintPrinterEvent;
  const factory PrinterEvent.select(String? current) = _SelectPrinterEvent;
}

class _InitPrinterEvent extends PrinterEvent {
  const _InitPrinterEvent();
}

class _PrintPrinterEvent extends PrinterEvent {
  final PrintType type;
  final String printer;
  final String path;
  const _PrintPrinterEvent(this.type, this.printer, this.path);
}

class _SelectPrinterEvent extends PrinterEvent {
  final String? current;
  const _SelectPrinterEvent(this.current);
}

sealed class PrinterState {
  const PrinterState();
  const factory PrinterState.loading() = LoadingPrinterState;
  const factory PrinterState.success(List<String> list, String? current) = SuccessPrinterState;
}

class LoadingPrinterState extends PrinterState {
  const LoadingPrinterState();
}

class SuccessPrinterState extends PrinterState {
  final List<String> list;
  final String? current;
  const SuccessPrinterState(this.list, this.current);
}

class PrinterBLoC extends Bloc<PrinterEvent, PrinterState> {
  final PrinterSource _printerSource;

  PrinterBLoC({required PrinterSource printerSource})
      : _printerSource = printerSource,
        super(const PrinterState.loading()) {
    on<PrinterEvent>(
      (event, emitter) => switch (event) {
        _InitPrinterEvent() => _init(emitter),
        _PrintPrinterEvent() => _print(event, emitter),
        _SelectPrinterEvent() => _select(event, emitter),
      },
    );

    add(const PrinterEvent.init());
  }

  Future<void> _init(Emitter<PrinterState> emitter) async {
    emitter(const PrinterState.loading());
    final list = await _printerSource.loadPrinters();
    emitter(PrinterState.success(list, null));
  }

  Future<void> _print(_PrintPrinterEvent event, Emitter<PrinterState> emitter) async {
    final old = state;
    if (old is SuccessPrinterState) {
      if (event.type == PrintType.text) {
        await _printerSource.print(event.printer, event.path);
      } else {
        await _printerSource.printRaw(event.printer, event.path);
      }
      emitter(PrinterState.success(old.list, event.printer));
    }
  }

  void _select(_SelectPrinterEvent event, Emitter<PrinterState> emitter) {
    final old = state;
    if (old is SuccessPrinterState) {
      emitter(PrinterState.success(old.list, event.current));
    }
  }
}
