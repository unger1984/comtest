import 'package:flutter_bloc/flutter_bloc.dart';

sealed class ScannerState {
  const ScannerState();
  const factory ScannerState.wait() = WaitScannerState;
  const factory ScannerState.barcode(String code) = BarcodeScannerState;
}

class WaitScannerState extends ScannerState {
  const WaitScannerState();
}

class BarcodeScannerState extends ScannerState {
  final String code;
  const BarcodeScannerState(this.code);
}

class ScannerCubit extends Cubit<ScannerState> {
  ScannerCubit() : super(const WaitScannerState());

  void scan(String code) {
    emit(ScannerState.barcode(code));
  }
}
