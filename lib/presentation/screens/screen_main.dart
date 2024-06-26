import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:comtest/presentation/blocs/printer_bloc.dart';
import 'package:comtest/presentation/blocs/scanner_cubit.dart';
import 'package:comtest/presentation/popup_alert.dart';
import 'package:enough_convert/windows.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:random_string/random_string.dart';

enum SingingCharacter { lafayette, jefferson }

extension IntToString on int {
  String toHex() => '0x${toRadixString(16)}';
  String toPadded([int width = 3]) => toString().padLeft(width, '0');
  String toTransport() {
    switch (this) {
      case SerialPortTransport.usb:
        return 'USB';
      case SerialPortTransport.bluetooth:
        return 'Bluetooth';
      case SerialPortTransport.native:
        return 'Native';
      default:
        return 'Unknown';
    }
  }
}

@immutable
class ScreenMain extends StatefulWidget {
  const ScreenMain({super.key});

  @override
  State<ScreenMain> createState() => _ScreenMainState();
}

class _ScreenMainState extends State<ScreenMain> {
  bool _swithc = false;
  bool _check = false;
  bool _isUTF8 = false;
  SingingCharacter? _character = SingingCharacter.lafayette;
  SerialPort? _com;
  StreamSubscription<Uint8List>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    _com?.close();
    super.dispose();
  }

  void _comListener(Uint8List data) {
    print('DATA ${String.fromCharCodes(data)}');
    BlocProvider.of<ScannerCubit>(context).scan(String.fromCharCodes(data));
  }

  void _handleSelectCom(String? com) {
    _subscription?.cancel();
    final old = _com;
    if (old != null) {
      old.close();
    }
    if (com != null) {
      _com = SerialPort(com);
      final port = SerialPort(com);
      port.openRead();
      _subscription = SerialPortReader(port).stream.listen(_comListener);
      setState(() {});
    }
  }

  void _handleSelectPrinter1(String? printer) {
    BlocProvider.of<PrinterBLoC>(context).add(PrinterEvent.select1(printer));
  }

  void _handleSelectPrinter2(String? printer) {
    BlocProvider.of<PrinterBLoC>(context).add(PrinterEvent.select2(printer));
  }

  Future<void> _handlePrintCPCL(String? printer) async {
    final current = printer;
    if (current == null) {
      showDialog(context: context, builder: (context) => const PopupAlert(text: 'Не выбран принтер!'));
    } else {
      final dir = Directory.systemTemp.createTempSync();
      final path = "${dir.path}/${randomAlpha(12)}";
      final temp = File(path)..createSync();

      final data = await rootBundle.loadString("assets/cpcl.tpl");
      final codec = _isUTF8 ? const Utf8Codec() : const Windows1251Codec();
      final list = Uint8List.fromList(codec.encode(data.replaceAll(RegExp("\n"), "\r\n")));
      //
      await temp.writeAsBytes(list);

      if (mounted) BlocProvider.of<PrinterBLoC>(context).add(PrinterEvent.print(PrintType.cpcl, current, path));
    }
  }

  Future<void> _handlePrintZPL(String? printer) async {
    final current = printer;
    if (current == null) {
      showDialog(context: context, builder: (context) => const PopupAlert(text: 'Не выбран принтер!'));
    } else {
      final dir = Directory.systemTemp.createTempSync();
      final path = "${dir.path}/${randomAlpha(12)}";
      final temp = File(path)..createSync();

      final data = await rootBundle.loadString("assets/zpl.tpl");
      final codec = _isUTF8 ? const Utf8Codec() : const Windows1251Codec();
      final list = Uint8List.fromList(codec.encode(data.replaceAll(RegExp("\n"), "\r\n")));
      //
      await temp.writeAsBytes(list);

      if (mounted) BlocProvider.of<PrinterBLoC>(context).add(PrinterEvent.print(PrintType.cpcl, current, path));
    }
  }

  Future<void> _handlePrintTemplate(String template, String? printer) async {
    final current = printer;
    if (current == null) {
      showDialog(context: context, builder: (context) => const PopupAlert(text: 'Не выбран принтер!'));
    } else {
      final dir = Directory.systemTemp.createTempSync();
      final path = "${dir.path}/${randomAlpha(12)}";
      final temp = File(path)..createSync();

      final data = await rootBundle.load("assets/$template");
      // final codec = _isUTF8 ? const Utf8Codec() : const Windows1251Codec();
      final list = data.buffer.asUint8List();
      // final list = Uint8List.fromList(data.buffer);
      //
      await temp.writeAsBytes(list);

      if (mounted) BlocProvider.of<PrinterBLoC>(context).add(PrinterEvent.print(PrintType.cpcl, current, path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final com = _com;

    return Scaffold(
      body: BlocBuilder<PrinterBLoC, PrinterState>(
        builder: (context, state) => switch (state) {
          SuccessPrinterState(:List<String> list, :String? current1, :String? current2) => Padding(
              padding: const EdgeInsets.all(40.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownMenu<String?>(
                                // controller: colorController,
                                label: const Text('COM порт'),
                                initialSelection: com?.name,
                                dropdownMenuEntries: [null, ...SerialPort.availablePorts]
                                    .map((itm) => DropdownMenuEntry<String?>(value: itm, label: itm ?? 'Не выбрано'))
                                    .toList(),
                                inputDecorationTheme: const InputDecorationTheme(filled: true),
                                onSelected: _handleSelectCom,
                                //   setState(() {
                                //     selectedColor = color;
                                //   });
                                // },
                              ),
                              if (com != null) const SizedBox(height: 20),
                              if (com != null)
                                ExpansionTile(
                                  title: Text(com.name ?? ''),
                                  children: [
                                    CardListTile('Description', com.description),
                                    CardListTile('Transport', com.transport.toTransport()),
                                    CardListTile('USB Bus', com.busNumber?.toPadded()),
                                    CardListTile('USB Device', com.deviceNumber?.toPadded()),
                                    CardListTile('Vendor ID', com.vendorId?.toHex()),
                                    CardListTile('Product ID', com.productId?.toHex()),
                                    CardListTile('Manufacturer', com.manufacturer),
                                    CardListTile('Product Name', com.productName),
                                    CardListTile('Serial Number', com.serialNumber),
                                    CardListTile('MAC Address', com.macAddress),
                                  ],
                                ),
                              const SizedBox(height: 20),
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
                        Column(
                          children: [
                            Row(
                              children: [
                                const Text('Печать в Windows1251'),
                                const SizedBox(width: 10),
                                Switch(
                                  value: _isUTF8,
                                  onChanged: (val) {
                                    setState(() {
                                      _isUTF8 = val;
                                    });
                                  },
                                ),
                                const SizedBox(width: 10),
                                const Text('Печать в UTF-8'),
                              ],
                            ),
                            Row(
                              children: [
                                DropdownMenu<String?>(
                                  // controller: colorController,
                                  label: const Text('Принтер 1'),
                                  initialSelection: current1,
                                  dropdownMenuEntries: [null, ...list]
                                      .map((itm) => DropdownMenuEntry<String?>(value: itm, label: itm ?? 'Не выбрано'))
                                      .toList(),
                                  inputDecorationTheme: const InputDecorationTheme(filled: true),
                                  onSelected: _handleSelectPrinter1,
                                  //   setState(() {
                                  //     selectedColor = color;
                                  //   });
                                  // },
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: current1 == null ? null : () => _handlePrintCPCL(current1),
                                      child: const Text('Печать CPCL'),
                                    ),
                                    const SizedBox(height: 5),
                                    ElevatedButton(
                                      onPressed: current1 == null ? null : () => _handlePrintZPL(current1),
                                      child: const Text('Печать ZPL'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Text('Шаблоны:'),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed:
                                      current1 == null ? null : () => _handlePrintTemplate('Tosh01.lbl', current1),
                                  child: const Text('1'),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed:
                                      current1 == null ? null : () => _handlePrintTemplate('Tosh02.lbl', current1),
                                  child: const Text('2'),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed:
                                      current1 == null ? null : () => _handlePrintTemplate('tosh_cennik.lbl', current1),
                                  child: const Text('3'),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed: current1 == null
                                      ? null
                                      : () => _handlePrintTemplate('tosh_DataMatrix.lbl', current1),
                                  child: const Text('4'),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed: current1 == null
                                      ? null
                                      : () => _handlePrintTemplate('tosh_new_price.lbl', current1),
                                  child: const Text('5'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                DropdownMenu<String?>(
                                  // controller: colorController,
                                  label: const Text('Принтер 2'),
                                  initialSelection: current2,
                                  dropdownMenuEntries: [null, ...list]
                                      .map((itm) => DropdownMenuEntry<String?>(value: itm, label: itm ?? 'Не выбрано'))
                                      .toList(),
                                  inputDecorationTheme: const InputDecorationTheme(filled: true),
                                  onSelected: _handleSelectPrinter2,
                                  //   setState(() {
                                  //     selectedColor = color;
                                  //   });
                                  // },
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: current2 == null ? null : () => _handlePrintCPCL(current2),
                                      child: const Text('Печать CPCL'),
                                    ),
                                    const SizedBox(height: 5),
                                    ElevatedButton(
                                      onPressed: current2 == null ? null : () => _handlePrintZPL(current2),
                                      child: const Text('Печать ZPL'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Text('Шаблоны:'),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed:
                                      current2 == null ? null : () => _handlePrintTemplate('Tosh01.lbl', current2),
                                  child: const Text('1'),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed:
                                      current2 == null ? null : () => _handlePrintTemplate('Tosh02.lbl', current2),
                                  child: const Text('2'),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed:
                                      current2 == null ? null : () => _handlePrintTemplate('tosh_cennik.lbl', current2),
                                  child: const Text('3'),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed: current2 == null
                                      ? null
                                      : () => _handlePrintTemplate('tosh_DataMatrix.lbl', current2),
                                  child: const Text('4'),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed: current2 == null
                                      ? null
                                      : () => _handlePrintTemplate('tosh_new_price.lbl', current2),
                                  child: const Text('5'),
                                ),
                              ],
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
            ),
          _ => const Center(
              child: CircularProgressIndicator(),
            ),
        },
      ),
    );
  }
}

class CardListTile extends StatelessWidget {
  final String name;
  final String? value;

  CardListTile(this.name, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(value ?? 'N/A'),
        subtitle: Text(name),
      ),
    );
  }
}
