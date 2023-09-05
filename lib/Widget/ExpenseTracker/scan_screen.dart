import 'dart:io';
import 'package:flutter/material.dart';
import 'package:funds_minder/ML/image_input.dart';
import 'package:funds_minder/Model/expense.dart';
import 'package:funds_minder/Widget/ExpenseTracker/new_scan_record.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File _pickedImage = File("");
  String? _scannedAmountString;
  String? _scanTitleString;
  String? _scanDateString;
  bool isScanning = false;
  String _exceptionString = "Upload a receipt to scan a transaction record";

  void _selectImage(File pickedImage) async {
    _scannedAmountString = "";
    _pickedImage = pickedImage;

    setState(() {
      isScanning = true;

      _exceptionString = "Wait for some moments...";
    });
    await getRcognizedText(_pickedImage);
    setState(() {
      isScanning = false;
    });
  }

  Future<void> getRcognizedText(File image) async {
    _scanDateString = null;
    _scanTitleString = null;
    _scanDateString = null;
    InputImage inputImage = InputImage.fromFile(image);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    _scannedAmountString = "";
    List<String> scannedLines = [];
    List<double> scannedValues = [];
    List<double> sortedScannedValues = [];
    double maxBoundingBoxHeight = 0;

    //Text to List of String
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine textLine in block.lines) {
        //determining title
        if (textLine.boundingBox.bottom - textLine.boundingBox.top >
            maxBoundingBoxHeight) {
          maxBoundingBoxHeight =
              textLine.boundingBox.bottom - textLine.boundingBox.top;
          _scanTitleString = null;
          final pattern =
              RegExp(r"^(?![0-9]+$)(?:[a-zA-Z0-9]+(?:[-&_ ][a-zA-Z0-9]+)*)$");
          RegExpMatch? titleMatch = pattern.firstMatch(textLine.text);
          if (titleMatch != null) {
            _scanTitleString = textLine.text;
          }
        }
        scannedLines.add(textLine.text);
      }
    }

    //makeing it double list and sort out
    if (scannedLines.isNotEmpty) {
      scannedLines = scannedLines.reversed.toList();
      scannedValues = lineTextToDouble(scannedLines);

      if (scannedValues.isNotEmpty) {
        sortedScannedValues.clear();
        sortedScannedValues = [...scannedValues];

        sortedScannedValues.sort((b, a) => a.compareTo(b));
        //making sorted list non repeatative
        var uniqueSet = sortedScannedValues.toSet();
        sortedScannedValues.clear();
        sortedScannedValues = uniqueSet.toList();

        RegExpMatch? matc;

        String? dateString;
        String? formatString;

        _scanDateString = dateFinder(
                scannedLines, matc, dateString, formatString) ??
            "${DateTime.now().year}-${(DateTime.now().month < 10) ? "0${DateTime.now().month}" : DateTime.now().month}-${(DateTime.now().day < 10) ? "0${DateTime.now().day}" : DateTime.now().day}";

        if (_scanTitleString != null) {
          _scanTitleString = (_scanTitleString!.length > 20)
              ? "${_scanTitleString!.substring(0, 15)}..."
              : _scanTitleString;
        } else {
          _scanTitleString = "Scanned_Doc(Auto)";
        }
        _scannedAmountString = sortedScannedValues[scanAndFindTotal(
                scannedLines, scannedValues, sortedScannedValues)]
            .toString();
      } else {
        //isScanning = false;
        _exceptionString =
            "No total found! Maybe this is not a receipt! \nor receipt is blurry or distorted";
      }
    } else {
      //isScanning = false;
      _exceptionString =
          "No title, date, total found! \nReceipt is blurry or distorted";
    }
  }

  String? dateFinder(List<String> scannedLines, RegExpMatch? matc,
      String? dateString, String? formatString) {
    var rDate = RegExp(r'(\d{1,2})[-\/.](\d{1,2})[-\/.](\d{2,4})');

    for (var line in scannedLines) {
      matc = rDate.firstMatch(line);
      if (matc != null) {
        dateString = matc.group(0);
        break;
      }
    }
    if (dateString != null) {
      String? year, month, day;
      for (Match match in rDate.allMatches(dateString)) {
        if (year == null && month == null && day == null) {
          year = match[3]!.length == 2
              ? '20${match[3]}'
              : match[3] ?? DateTime.now().year.toString();
          month = match[2]!.length == 1
              ? '0${match[2]}'
              : match[2] ?? DateTime.now().month.toString();
          day = match[1]!.length == 1
              ? '0${match[1]}'
              : match[1] ?? DateTime.now().day.toString();

          formatString = '$year-$month-$day';
        }
      }
    }
    return formatString;
  }

  int scanAndFindTotal(
      List<String> mainList, List<double> unsortedList, List<double> sortList) {
    List<String> subtotalKW = ["subtotal", "sub total", "sub-total"];
    List<String> savingKW = [
      'Total savings',
      'save',
      'discount',
      'discounts',
      'off item',
      'loyalty'
    ];
    List<String> cashKW = [
      "cash",
      "tend",
      "tendered",
      "full amount due",
      "card",
      "total debit purchase",
      "snap",
      'mastercard',
      'paypal',
      'apple pay',
      'google pay',
      'discover',
      'maestro'
    ];
    List<String> changeKW = ['change', 'remaining amount due'];
    bool didCashFound = false;
    bool didChangeFound = false;
    bool didBonusFound = false;
    bool didSubtotalfound = false;
    double reserveValue = 0;

    for (var st in mainList) {
      st = st.trim().toLowerCase();
      if (!didCashFound) {
        didCashFound = cashKW.any((element) => st.contains(element));
      }
      if (!didChangeFound) {
        didChangeFound = changeKW.any((element) => st.contains(element));
      }
      if (!didBonusFound) {
        didBonusFound = savingKW.any((element) => st.contains(element));
      }
      if (!didSubtotalfound) {
        didSubtotalfound = subtotalKW.any((element) => st.contains(element));
      }
    }

    if (didCashFound && didChangeFound) {
      reserveValue =
          (sortList[0] - unsortedList[unsortedList.indexOf(sortList[0]) - 1]) ==
                  0
              ? unsortedList[unsortedList.indexOf(sortList[0]) - 2]
              : unsortedList[unsortedList.indexOf(sortList[0]) - 1];
      //if total and change stand beside or not after cash

      var ttl = sortList[0] - reserveValue;
      if (!sortList.contains(ttl)) {
        sortList.add(ttl);
        sortList.sort((b, a) => a.compareTo(b));
      }
      return sortList.indexOf(ttl);
    } else {
      if (didSubtotalfound && didBonusFound) {
        return 1;
      }
    }

    return 0;
  }

  List<double> lineTextToDouble(List<String> lineTxts) {
    List<double> doubleList = [];
    var ttl = RegExp(r"\d+(\.\s?|,\s?|[^a-zA-Z\d])\d{1,2}");

    RegExpMatch? match;
    for (var lT in lineTxts) {
      match = ttl.firstMatch(lT);
      if (match != null) {
        String tVal = match.group(0) ?? "";
        tVal = tVal.replaceAll(",", ".");

        double? tValD = double.tryParse(tVal);
        if (tValD != null) {
          doubleList.add(tValD);
        }
      }
    }

    return doubleList;
  }

  List<Widget> screenChildren(Size screenSize) {
    return [
      ImageInput(_selectImage),
      const SizedBox(
        height: 20,
      ),
      if (screenSize.height < 600)
        const SizedBox(
          width: 30,
        ),
      if (!isScanning &&
          _scanDateString != null &&
          _scanTitleString != null &&
          _scannedAmountString != null)
        NewScanRecord(_scanTitleString, _scannedAmountString,
            DateTime.tryParse(_scanDateString ?? ""), Category.other),
      if (isScanning ||
          _scanDateString == null ||
          _scannedAmountString == null ||
          _scanDateString == null)
        Container(
            height: (screenSize.height > 600)
                ? screenSize.height * 0.25
                : screenSize.height * 0.7,
            width: (screenSize.height > 600)
                ? screenSize.width * 1
                : screenSize.width * 0.54,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(width: 1)),
            child: Center(child: Text(_exceptionString))),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size scSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Funds Minder"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: (scSize.height > 600)
                    ? Column(
                        children: screenChildren(scSize),
                      )
                    : Row(
                        children: screenChildren(scSize),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
