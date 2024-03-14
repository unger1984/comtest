import 'package:comtest/domain/datasources/printer_source.dart';
import 'package:logging/logging.dart';
import 'package:process_run/process_run.dart';

class PrinterSourceCups extends PrinterSource {
  final _shell = Shell();
  static final _log = Logger('PrinterSourceCups');

  @override
  Future<List<String>> loadPrinters() async {
    final result = <String>[];
    try {
      final res = await _shell.run('lpstat -p');
      final lines = res.first.outText.split(RegExp('\n'));
      for (String line in lines) {
        final parts = line.split(RegExp(r'\s'));
        if (parts.length >= 2) {
          result.add(parts.elementAt(1).trim());
        }
      }
    } catch (exception, stack) {
      _log.severe('loadPrinters', exception, stack);
    }

    return result;
  }

  @override
  Future<void> print(String printer, String file) async {
    try {
      await _shell.run('lp -d $printer $file');
    } catch (exception, stack) {
      _log.severe('print', exception, stack);
    }
  }

  @override
  Future<void> printRaw(String printer, String file) async {
    try {
      await _shell.run('lpr -P $printer -o raw $file');
    } catch (exception, stack) {
      _log.severe('printRaw', exception, stack);
    }
  }
}
