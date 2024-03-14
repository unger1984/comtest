abstract class PrinterSource {
  Future<List<String>> loadPrinters();
  Future<void> print(String printer, String file);
  Future<void> printRaw(String printer, String file);
}
