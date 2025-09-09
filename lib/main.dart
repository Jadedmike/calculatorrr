import 'package:flutter/material.dart';

//first part
void main() => runApp(const MyApp());

//second part
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calc', //عنوان التطبيق

      debugShowCheckedModeBanner:
          false, // لإخفاء شعار الشبح التجريبي في الزاوية
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E0E10),
        primaryColor: const Color(0xFF1F1F1F),
      ), // تحديد الثيم بشكل داكن مع ألوان مخصصة
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  // لأنه يحتاج لإدارة الحالة (الأرقام، العمليات، النتيجة)
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0'; // النص المعروض على الشاشة
  double? _firstOperand; // الرقم الأول المدخل
  String? _operator; // العملية (+، -، ×، ÷)
  bool _shouldResetDisplay =
      false; // لتحديد ما إذا يجب إعادة تعيين شاشة الإدخال

  void _onDigitPressed(String digit) {
    setState(() {
      if (_display == '0' || _shouldResetDisplay) {
        _display =
            digit; // استبدال اذا كانت الشاشة 0 أو كانت بحاجة لإعادة التعيين
        _shouldResetDisplay = false;
      } else {
        _display += digit; // إضافة الرقم للنص الحالي
      }
    });
  }

  //ضغط النقطة العشرية
  void _onDecimalPressed() {
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
        return;
      }
      if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  // المسح
  void _onClear() {
    setState(() {
      _display = '0';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  //ضغط عملية حسابية
  void _onOperatorPressed(String op) {
    setState(() {
      final current = double.tryParse(_display) ?? 0.0;
      if (_firstOperand == null) {
        _firstOperand = current; // حفظ الرقم الحالي كأول رقم
      } else if (_operator != null && !_shouldResetDisplay) {
        // إذا كانت عملية سابقة، نحسبها الآن ونخزن النتيجة
        _firstOperand = _compute(_firstOperand!, current, _operator!);
        _display = _formatResult(_firstOperand!);
      }
      _operator = op; // حفظ العملية المختارة
      _shouldResetDisplay = true; // لتحضير الشاشة لرقم جديد
    });
  }

  //اليساوي
  void _onEqualPressed() {
    setState(() {
      if (_operator == null || _firstOperand == null)
        return; // لا يوجد عملية أو رقم أول
      final second = double.tryParse(_display) ?? 0.0; // الرقم الثاني من الشاشة
      final res = _compute(
        _firstOperand!,
        second,
        _operator!,
      ); // تنفيذ العملية الحسابية
      _display = _formatResult(res); // عرض النتيجة بشكل منسجم
      _firstOperand = res; // تخزين النتيجة كرقم أول لاحقاً
      _operator = null; // إلغاء العملية
      _shouldResetDisplay = true; // لبدء إدخال رقم جديد بعد النتيجة
    });
  }

  //وظيفة الحساب
  double _compute(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) return 0; //— نتجنب القسمة على صفر
        return a / b;
      default:
        return b; // في حالة خطأ أو عملية غير معروفة
    }
  }

  //تنسيق النتيجة
  String _formatResult(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString(); // إزالة الأصفار غير الضرورية من الأعداد
    } else {
      // تقليل الأصفار بعد العلامة العشرية
      return value.toStringAsFixed(10).replaceFirst(RegExp(r'\.?0+$'), '');
    }
  }

  // إنشاء زر
  //هو دالة تساعد على إنشاء الأزرار بشكل موحد
  // flex لتحديد حجم الزر
  //bg لتحديد لون الخلفية
  //onTap هو الوظيفة التي تنفذ عند الضغط
  Widget _buildButton(
    String text, {
    double flex = 1,
    Color? bg,
    VoidCallback? onTap,
  }) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            backgroundColor: bg ?? const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  //بناء واجهة المستخدم
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Calculator'),
        centerTitle: true,
        backgroundColor: const Color(0xFF161616),
      ),
      body: Column(
        children: [
          // مساحة لعرض الرقم/النتيجة
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              alignment: Alignment.bottomRight,
              child: SingleChildScrollView(
                reverse: true,
                scrollDirection: Axis.horizontal,
                child: Text(
                  _display,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ),
          //// الصفوف الداخلية للأزرار
          // الازرار
          Column(
            children: [
              Row(
                children: [
                  _buildButton(
                    'C',
                    bg: const Color(0xFFB00020),
                    onTap: _onClear,
                  ),
                  _buildButton(
                    '÷',
                    bg: const Color(0xFF3E3E3E),
                    onTap: () => _onOperatorPressed('÷'),
                  ),
                  _buildButton(
                    '×',
                    bg: const Color(0xFF3E3E3E),
                    onTap: () => _onOperatorPressed('×'),
                  ),
                  _buildButton(
                    '−',
                    bg: const Color(0xFF3E3E3E),
                    onTap: () => _onOperatorPressed('-'),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildButton('7', onTap: () => _onDigitPressed('7')),
                  _buildButton('8', onTap: () => _onDigitPressed('8')),
                  _buildButton('9', onTap: () => _onDigitPressed('9')),
                  _buildButton(
                    '+',
                    bg: const Color(0xFF3E3E3E),
                    onTap: () => _onOperatorPressed('+'),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildButton('4', onTap: () => _onDigitPressed('4')),
                  _buildButton('5', onTap: () => _onDigitPressed('5')),
                  _buildButton('6', onTap: () => _onDigitPressed('6')),
                  _buildButton(
                    '=',
                    bg: const Color(0xFF0A84FF),
                    onTap: _onEqualPressed,
                  ),
                ],
              ),
              Row(
                children: [
                  _buildButton('1', onTap: () => _onDigitPressed('1')),
                  _buildButton('2', onTap: () => _onDigitPressed('2')),
                  _buildButton('3', onTap: () => _onDigitPressed('3')),
                  _buildButton('.', onTap: _onDecimalPressed),
                ],
              ),
              Row(
                children: [
                  _buildButton('0', flex: 2, onTap: () => _onDigitPressed('0')),
                  _buildButton('00', onTap: () => _onDigitPressed('00')),
                  _buildButton(
                    '%',
                    onTap: () {
                      // تحويل القيمة إلى نسبة بسيطة
                      setState(() {
                        final cur = double.tryParse(_display) ?? 0.0;
                        _display = _formatResult(cur / 100);
                        _shouldResetDisplay = true;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
