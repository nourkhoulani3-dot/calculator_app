
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator State Lab',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String display = '0';
  double? accumulator;
  String? pendingOperator;
  bool awaitingOperand = false;
  bool justCalculated = false;
  bool hasError = false;

  final List<String> buttons = [
    'AC', '÷', '×', '−',
    '7', '8', '9', '+',
    '4', '5', '6', '=',
    '1', '2', '3', '0',
  ];

  void clearCalculator() {
    setState(() {
      display = '0';
      accumulator = null;
      pendingOperator = null;
      awaitingOperand = false;
      justCalculated = false;
      hasError = false;
    });
  }

  String formatNumber(double number) {
    if (!number.isFinite) {
      return 'Error';
    }

    if (number == number.truncateToDouble()) {
      return number.toStringAsFixed(0);
    }

    return number.toString();
  }

  void enterDigit(String digit) {
    setState(() {
      if (hasError || justCalculated) {
        display = digit;
        accumulator = null;
        pendingOperator = null;
        awaitingOperand = false;
        justCalculated = false;
        hasError = false;
      } else if (awaitingOperand) {
        display = digit;
        awaitingOperand = false;
      } else {
        display = display == '0' ? digit : display + digit;
      }
    });
  }

  double? calculate(double first, double second, String op) {
    switch (op) {
      case '+':
        return first + second;
      case '−':
        return first - second;
      case '×':
        return first * second;
      case '÷':
        if (second == 0) {
          return null;
        }
        return first / second;
      default:
        return null;
    }
  }

  void showError() {
    display = 'Cannot divide by zero';
    accumulator = null;
    pendingOperator = null;
    awaitingOperand = false;
    justCalculated = false;
    hasError = true;
  }

  void chooseOperator(String op) {
    setState(() {
      if (hasError) return;

      if (pendingOperator != null && awaitingOperand) {
        pendingOperator = op;
        return;
      }

      final current = double.parse(display);

      if (pendingOperator != null && accumulator != null) {
        final result = calculate(
          accumulator!,
          current,
          pendingOperator!,
        );

        if (result == null || !result.isFinite) {
          showError();
          return;
        }

        accumulator = result;
        display = formatNumber(result);
      } else {
        accumulator = current;
      }

      pendingOperator = op;
      awaitingOperand = true;
      justCalculated = false;
    });
  }

  void pressEquals() {
    setState(() {
      if (hasError ||
          pendingOperator == null ||
          accumulator == null ||
          awaitingOperand) {
        return;
      }

      final current = double.parse(display);

      final result = calculate(
        accumulator!,
        current,
        pendingOperator!,
      );

      if (result == null || !result.isFinite) {
        showError();
        return;
      }

      display = formatNumber(result);
      accumulator = null;
      pendingOperator = null;
      awaitingOperand = false;
      justCalculated = true;
    });
  }

  void buttonPressed(String value) {
    if (value == 'AC') {
      clearCalculator();
    } else if (value == '=') {
      pressEquals();
    } else if (['+', '−', '×', '÷'].contains(value)) {
      chooseOperator(value);
    } else {
      enterDigit(value);
    }
  }

  Color buttonColor(String value) {
    if (value == 'AC') {
      return Colors.red.shade100;
    }

    if (['+', '−', '×', '÷', '='].contains(value)) {
      return Colors.deepPurple.shade200;
    }

    return Colors.grey.shade200;
  }

  Widget buildButton(String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: buttonColor(value),
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => buttonPressed(value),
            splashColor: Colors.deepPurple.withValues(alpha: 0.25),
            child: SizedBox(
              height: 65,
              child: Center(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Calculator'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        display,
                        style: TextStyle(
                          fontSize: hasError ? 26 : 55,
                          fontWeight: FontWeight.bold,
                          color: hasError
                              ? Colors.red
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      for (int row = 0; row < 4; row++)
                        Row(
                          children: [
                            for (int col = 0; col < 4; col++)
                              buildButton(buttons[row * 4 + col]),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
