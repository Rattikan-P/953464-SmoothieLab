import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../providers/cart_provider.dart';
import '../models/order_model.dart';
import '../data/ingredients_data.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _seconds = 300;
  Timer? _timer;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        _timer?.cancel();
        if (!_expired) {
          _expired = true;
          _showExpiredDialog();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _saveExpiredOrder() async {
    final cart = context.read<CartProvider>();
    final box = await Hive.openBox<OrderModel>('orders');
    final orderId = '#SML-${const Uuid().v4().substring(0, 4).toUpperCase()}';

    for (final item in cart.items) {
      // Convert ToppingItems to indexes for editing
      final toppingIndexes = <int>[];
      for (final topping in item.toppings) {
        final index = kToppingData.indexWhere(
          (t) => t.name == topping.name &&
                t.emoji == topping.emoji &&
                t.price == topping.price,
        );
        if (index != -1) {
          toppingIndexes.add(index);
        }
      }

      final order = OrderModel()
        ..orderId = orderId
        ..menuName = item.smoothie.name
        ..menuEmoji = item.smoothie.emoji
        ..size = item.size
        ..toppings = item.toppings.map((t) => t.name).toList()
        ..totalPrice = (item.itemPrice / cart.subtotal) * cart.total
        ..itemPriceRaw = item.itemPrice
        ..orderDate = DateTime.now()
        ..status = 'cancelled'
        ..subtotal = cart.subtotal
        ..discount = cart.discount
        ..vat = cart.vat
        ..ingredients = item.smoothie.ingredients
        ..sweetness = item.sweetness
        ..fruitIndexes = item.fruitIndexes
        ..extrasIndexes = item.extrasIndexes
        ..veggieIndexes = item.veggieIndexes
        ..herbsIndexes = item.herbsIndexes
        ..toppingsIndexes = toppingIndexes;
      await box.add(order);
    }
  }

  Future<void> _showExpiredDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Column(children: [
          Text('⏰', style: TextStyle(fontSize: 40)),
          SizedBox(height: 8),
          Text('QR Expired',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        content: const Text(
          'Your QR code has expired.\nThis order has been automatically cancelled.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Save the order as cancelled before clearing cart
                await _saveExpiredOrder();
                context.read<CartProvider>().clear();
                if (mounted) {
                  // Pop dialog and payment screen
                  Navigator.of(context)..pop()..pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Got it',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  String get _timerStr {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.total;
    final isAlmostExpired = _seconds <= 60;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Checkout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // ── Amount ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(children: [
                const Text('TOTAL AMOUNT',
                    style: TextStyle(
                        color: Colors.grey, letterSpacing: 2, fontSize: 11)),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: '฿${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 52, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: '.00',
                        style: TextStyle(fontSize: 24, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ]),
            ),

            // ── QR Card ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(children: [
                const Text('Scan to Pay',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                const Text('Use any banking app to scan',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 20),

                // QR
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _expired ? Colors.grey.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ColorFiltered(
                    colorFilter: _expired
                        ? const ColorFilter.matrix([
                            0.3, 0, 0, 0, 0,
                            0, 0.3, 0, 0, 0,
                            0, 0, 0.3, 0, 0,
                            0, 0, 0, 1, 0,
                          ])
                        : const ColorFilter.matrix([
                            1, 0, 0, 0, 0,
                            0, 1, 0, 0, 0,
                            0, 0, 1, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                    child: QrImageView(
                      data: 'PROMPTPAY:0812345678:${total.toStringAsFixed(2)}',
                      version: QrVersions.auto,
                      size: 180,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3949AB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_rounded,
                          size: 14, color: Color(0xFF3949AB)),
                      SizedBox(width: 6),
                      Text('PromptPay',
                          style: TextStyle(
                              color: Color(0xFF3949AB),
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            // ── Timer Card ────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isAlmostExpired
                    ? Colors.red.shade50
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isAlmostExpired
                      ? Colors.red.shade300
                      : Colors.grey.shade200,
                  width: isAlmostExpired ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAlmostExpired
                          ? Icons.warning_amber_rounded
                          : Icons.timer_outlined,
                      size: 16,
                      color: isAlmostExpired ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAlmostExpired ? 'Expiring soon!' : 'QR expires in',
                      style: TextStyle(
                        color: isAlmostExpired ? Colors.red : Colors.grey,
                        fontSize: 12,
                        fontWeight: isAlmostExpired
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Timer display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _timerStr.split(':')[0],
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: isAlmostExpired ? Colors.red : Colors.black,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(' : ',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isAlmostExpired
                                  ? Colors.red
                                  : Colors.grey)),
                    ),
                    Text(
                      _timerStr.split(':')[1],
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: isAlmostExpired ? Colors.red : Colors.black,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TimeLabel('MIN'),
                    const SizedBox(width: 32),
                    _TimeLabel('SEC'),
                  ],
                ),

                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _seconds / 300,
                    minHeight: 6,
                    backgroundColor: isAlmostExpired
                        ? Colors.red.shade100
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      _seconds > 60 ? const Color(0xFF4CAF50) : Colors.red,
                    ),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 24),

            // ── Confirm Button ────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _expired
                    ? null
                    : () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PaymentSuccessScreen()),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Confirm Payment',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String label;
  const _TimeLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
            fontSize: 11, color: Colors.grey, letterSpacing: 1),
      );
}