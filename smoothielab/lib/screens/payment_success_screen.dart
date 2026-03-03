import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../data/ingredients_data.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});
  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late Animation<double> _checkScale;
  late String _orderId;

  int _currentStep = 0;
  Timer? _stepTimer;
  double _stepProgress = 0.0;
  Timer? _progressTimer;

  final _steps = const [
    (
      icon: '📋',
      label: 'Order\nReceived',
      sublabel: 'Your order has been received',
    ),
    (
      icon: '🧪',
      label: 'Blending\nNow',
      sublabel: 'Preparing your smoothie...',
    ),
    (
      icon: '✅',
      label: 'Ready\nfor Pickup',
      sublabel: 'Come pick up at the counter!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orderId = '#SML-${const Uuid().v4().substring(0, 4).toUpperCase()}';
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
    _checkCtrl.forward();
    _saveOrder();
    _startProgress();
  }

  void _startProgress() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!mounted) return;
      setState(() {
        _stepProgress += 0.008;
        if (_stepProgress >= 1.0) _stepProgress = 0.0;
      });
    });

    _stepTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 1;
        _stepProgress = 0.0;
      });
    });
  }

  Future<void> _saveOrder() async {
    final cart = context.read<CartProvider>();
    final box = Hive.box<OrderModel>('orders');
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
        ..orderId = _orderId
        ..menuName = item.smoothie.name
        ..menuEmoji = item.smoothie.emoji
        ..size = item.size
        ..toppings = item.toppings.map((t) => t.name).toList()
        ..totalPrice = (item.itemPrice / cart.subtotal) * cart.total
        ..itemPriceRaw = item.itemPrice
        ..orderDate = DateTime.now()
        ..status = 'processing'
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
    cart.clear();
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _stepTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isLast = _currentStep == _steps.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // ── Success header ────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _checkScale,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Payment Successful! 🎉',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'PAYMENT CONFIRMED',
                      style: TextStyle(
                        color: Colors.grey,
                        letterSpacing: 2,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Order Status Card ─────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              step.icon,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.label.replaceAll('\n', ' '),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              step.sublabel,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Step bubbles + lines
                    Row(
                      children: List.generate(_steps.length, (i) {
                        final done = i < _currentStep;
                        final current = i == _currentStep;
                        return Expanded(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: done || current
                                          ? const Color(0xFF4CAF50)
                                          : Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                      boxShadow: current
                                          ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF4CAF50,
                                                ).withOpacity(0.4),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Center(
                                      child: done
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : Text(
                                              _steps[i].icon,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              if (i < _steps.length - 1)
                                Expanded(
                                  child: Container(
                                    height: 3,
                                    margin: const EdgeInsets.only(bottom: 0),
                                    decoration: BoxDecoration(
                                      color: done
                                          ? const Color(0xFF4CAF50)
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),

                    // Labels under bubbles
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: List.generate(_steps.length, (i) {
                          final active = i <= _currentStep;
                          return Expanded(
                            child: Text(
                              _steps[i].label,
                              style: TextStyle(
                                fontSize: 9,
                                color: active
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey,
                                fontWeight: active
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Progress bar (เฉพาะ step กำลังปั่น)
                    if (!isLast) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            step.sublabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '~10-15 min',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _stepProgress,
                          minHeight: 7,
                          backgroundColor: Colors.green.shade100,
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ] else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const LinearProgressIndicator(
                          value: 1.0,
                          minHeight: 7,
                          backgroundColor: Color(0xFFC8E6C9),
                          valueColor: AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Order Number + Pickup ─────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Order number
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ORDER NUMBER',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _orderId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'PAID',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1),
                    ),

                    // Pickup
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('📍', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PICKUP DETAILS',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'SmoothieLab — Siam Branch',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Est. time: 10-15 minutes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'View Order History',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
