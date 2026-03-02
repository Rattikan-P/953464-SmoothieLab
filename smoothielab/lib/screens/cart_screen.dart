import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('Cart  ', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Text('${cart.totalCount} ITEMS  ', style: const TextStyle(color: Colors.grey)),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('ตะกร้าว่างเปล่า 🛒'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(item.smoothie.emoji, style: const TextStyle(fontSize: 36)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(item.smoothie.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  item.toppings.isEmpty
                                      ? item.smoothie.ingredients.join(' · ')
                                      : item.toppings.map((t) => t.name).join(' · '),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                Text('SIZE: ${item.size}', style: const TextStyle(fontSize: 12)),
                                Text('฿${item.itemPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold)),
                              ]),
                            ),
                            // Qty controls
                            Row(children: [
                              GestureDetector(
                                onTap: () => cart.decrementAt(i),
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.remove, size: 16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              GestureDetector(
                                onTap: () => cart.incrementAt(i),
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.add, size: 16),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ── Summary ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      _PriceRow('Subtotal', cart.subtotal),
                      if (cart.discount > 0)
                        _PriceRow('ส่วนลด (ยอดเกิน 100฿)', -cart.discount, color: Colors.green),
                      _PriceRow('VAT 7%', cart.vat),
                      const Divider(),
                      _PriceRow('TOTAL', cart.total, bold: true, color: const Color(0xFFFF6B35)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PaymentScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('💳 ชำระเงิน ฿${cart.total.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  final Color? color;
  const _PriceRow(this.label, this.amount, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(
            '฿${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}