import 'dart:io';

import 'package:comtest/presentation/blocs/printer_bloc.dart';
import 'package:comtest/presentation/blocs/scanner_cubit.dart';
import 'package:comtest/presentation/popup_alert.dart';
import 'package:enough_convert/windows.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_string/random_string.dart';

enum SingingCharacter { lafayette, jefferson }

@immutable
class ScreenMain extends StatefulWidget {
  const ScreenMain({super.key});

  @override
  State<ScreenMain> createState() => _ScreenMainState();
}

class _ScreenMainState extends State<ScreenMain> {
  bool _swithc = false;
  bool _check = false;
  SingingCharacter? _character = SingingCharacter.lafayette;

  void _handleSelectPrinter(String? printer) {
    BlocProvider.of<PrinterBLoC>(context).add(PrinterEvent.select(printer));
  }

  Future<void> _handlePrintCPCL(String? printer) async {
    final current = printer;
    if (current == null) {
      showDialog(context: context, builder: (context) => PopupAlert(text: 'Не выбран принтер!'));
    } else {
      final dir = Directory.systemTemp.createTempSync();
      final path = "${dir.path}/${randomAlpha(12)}";
      final temp = File(path)..createSync();

      final data = await rootBundle.loadString("assets/cpcl.tpl");
      const codec = Windows1251Codec();
      final list = Uint8List.fromList(codec.encode(data.replaceAll(RegExp("\n"), "\r\n")));
      //
      await temp.writeAsBytes(list);

      BlocProvider.of<PrinterBLoC>(context).add(PrinterEvent.print(PrintType.cpcl, current, path));
    }
  }

  Future<void> _handlePrintZPL(String? printer) async {
    final current = printer;
    if (current == null) {
      showDialog(context: context, builder: (context) => PopupAlert(text: 'Не выбран принтер!'));
    } else {
      final dir = Directory.systemTemp.createTempSync();
      final path = "${dir.path}/${randomAlpha(12)}";
      final temp = File(path)..createSync();

      final data = await rootBundle.loadString("assets/zpl.tpl");
      const codec = Windows1251Codec();
      final list = Uint8List.fromList(codec.encode(data.replaceAll(RegExp("\n"), "\r\n")));
      //
      await temp.writeAsBytes(list);

      BlocProvider.of<PrinterBLoC>(context).add(PrinterEvent.print(PrintType.cpcl, current, path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PrinterBLoC, PrinterState>(
        builder: (context, state) => switch (state) {
          SuccessPrinterState(:List<String> list, :String? current) => Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Отсканировано:'),
                            BlocBuilder<ScannerCubit, ScannerState>(
                              builder: (context, state) => switch (state) {
                                BarcodeScannerState(:String code) => Text(code),
                                _ => const SizedBox(),
                              },
                            ),
                          ],
                        ),
                      ),
                      DropdownMenu<String?>(
                        // controller: colorController,
                        label: const Text('Принтер'),
                        initialSelection: current,
                        dropdownMenuEntries: [null, ...list]
                            .map((itm) => DropdownMenuEntry<String?>(value: itm, label: itm ?? 'Не выбрано'))
                            .toList(),
                        inputDecorationTheme: const InputDecorationTheme(filled: true),
                        onSelected: _handleSelectPrinter,
                        //   setState(() {
                        //     selectedColor = color;
                        //   });
                        // },
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: current == null ? null : () => _handlePrintCPCL(current),
                            child: const Text('Печать CPCL'),
                          ),
                          const SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: current == null ? null : () => _handlePrintZPL(current),
                            child: const Text('Печать ZPL'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 0.0),
                            ),
                            hintText: 'Текстовое поле',
                          ),
                          maxLines: 10,
                          minLines: 10,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const DropdownMenu<String>(
                              initialSelection: 'Тест 1',
                              dropdownMenuEntries: [
                                DropdownMenuEntry<String>(value: 'Тест 1', label: 'Тест 1'),
                                DropdownMenuEntry<String>(value: 'Тест 2', label: 'Тест 2'),
                                DropdownMenuEntry<String>(value: 'Тест 3', label: 'Тест 3'),
                              ],
                            ),
                            Row(
                              children: [
                                Switch(
                                  value: _swithc,
                                  onChanged: (val) {
                                    setState(() {
                                      _swithc = val;
                                    });
                                  },
                                ),
                                Checkbox(
                                  value: _check,
                                  onChanged: (val) {
                                    setState(() {
                                      _check = val ?? false;
                                    });
                                  },
                                ),
                                Radio<SingingCharacter>(
                                  value: SingingCharacter.lafayette,
                                  groupValue: _character,
                                  onChanged: (SingingCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                ),
                                Radio<SingingCharacter>(
                                  value: SingingCharacter.jefferson,
                                  groupValue: _character,
                                  onChanged: (SingingCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Кнопка 1'),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Кнопка 2'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          _ => const Center(
              child: CircularProgressIndicator(),
            ),
        },
      ),
    );
  }
}
