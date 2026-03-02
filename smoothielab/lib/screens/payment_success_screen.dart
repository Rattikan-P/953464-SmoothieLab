import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});
  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late String _orderId;

  @override
  void initState() {
    super.initState();
    _orderId = '#SML-${const Uuid().v4().substring(0, 4).toUpperCase()}';
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
    _saveOrder();
  }

  Future<void> _saveOrder() async {
    final cart = context.read<CartProvider>();
    final box = Hive.box<OrderModel>('orders');

    for (final item in cart.items) {
      final order = OrderModel()
        ..orderId = _orderId
        ..menuName = item.smoothie.name
        ..menuEmoji = item.smoothie.emoji
        ..size = item.size
        ..toppings = item.toppings.map((t) => t.name).toList()
        ..totalPrice = item.itemPrice
        ..orderDate = DateTime.now()
        ..status = 'processing'
        ..subtotal = cart.subtotal
        ..discount = cart.discount
        ..vat = cart.vat;
      await box.add(order);
    }
    cart.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Floating fruits
              Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: const [Text('✨', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8), Text('🍏', style: TextStyle(fontSize: 28)),
                    SizedBox(width: 8), Text('💜', style: TextStyle(fontSize: 24))]),
              const SizedBox(height: 20),

              // Checkmark
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 100, height: 100,
                  decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 56),
                ),
              ),
              const SizedBox(height: 24),
              const Text('ชำระเงินสำเร็จ! 🎉',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('PAYMENT CONFIRMED',
                  style: TextStyle(color: Colors.grey, letterSpacing: 2, fontSize: 12)),
              const SizedBox(height: 32),

              // Order detail card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('ORDER NUMBER', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(_orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                        child: const Text('✓ PAID', style: TextStyle(color: Colors.green, fontSize: 12)),
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Pickup info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(children: [
                  Text('📍', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('PICKUP DETAILS', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text('SmoothieLab สาขาสยาม', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('เวลาโดยประมาณ: 10-15 นาที', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                ]),
              ),

              const Spacer(),

              // View Order History button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    // Switch to ORDER tab (index 2)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('ดูประวัติออเดอร์ →', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}