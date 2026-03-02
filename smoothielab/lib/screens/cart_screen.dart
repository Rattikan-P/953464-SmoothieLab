import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(
          'Cart  ${cart.totalCount > 0 ? "(${cart.totalCount} items)" : ""}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🛒', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 8),
                  Text('ตะกร้าว่างเปล่า', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) => _CartItemCard(index: i),
                  ),
                ),
                _SummaryPanel(cart: cart),
              ],
            ),
    );
  }
}

// ── Cart Item Card ────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final int index;
  const _CartItemCard({required this.index});

  Future<void> _confirmDelete(
    BuildContext context,
    CartProvider cart,
    int i,
  ) async {
    final item = cart.items[i];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ลบรายการ?'),
        content: Text('ต้องการลบ "${item.displayName}" ออกจากตะกร้าใช่ไหม?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirmed == true) cart.removeAt(i);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    // guard: ถ้า index เกิน (หลังลบ) ไม่ render
    if (index >= cart.items.length) return const SizedBox.shrink();
    final item = cart.items[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    item.smoothie.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่อ: เมนูจริง หรือ ผลไม้+ของเหลว ถ้า custom
                    Text(
                      item.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Size + Sweetness
                    Row(
                      children: [
                        _Tag(item.size, color: const Color(0xFF4CAF50)),
                        const SizedBox(width: 6),
                        _Tag(item.sweetness, color: Colors.amber.shade700),
                      ],
                    ),

                    // Toppings (ถ้ามี)
                    if (item.toppings.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.toppings
                            .map((t) => '${t.emoji} ${t.name}')
                            .join('  '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),
                    Text(
                      '฿${item.itemPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              // ปุ่มแก้ไข (กลับไป Lab)
              IconButton(
                onPressed: () {
                  final nav = context.read<NavigationProvider>();
                  Navigator.pop(context);
                  nav.goToLabWithPreset(
                    item.fruitIndexes,
                    extrasIndexes: item.extrasIndexes,
                    veggieIndexes: item.veggieIndexes,
                    menuName: item.isCustom ? null : item.smoothie.name,
                    menuEmoji: item.isCustom ? null : item.smoothie.emoji,
                    editIndex: index,
                  );
                },
                icon: const Icon(
                  Icons.edit_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Qty controls + Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // ลบ
              GestureDetector(
                onTap: () async {
                  final needConfirm = cart.decrementAt(index);
                  if (needConfirm && context.mounted) {
                    await _confirmDelete(context, cart, index);
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.remove, size: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // เพิ่ม
              GestureDetector(
                onTap: () => cart.incrementAt(index),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tag widget ────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Summary Panel ─────────────────────────────────────
class _SummaryPanel extends StatelessWidget {
  final CartProvider cart;
  const _SummaryPanel({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _Row('Subtotal', cart.subtotal),

            // แสดง discount tier ที่ถัดไปถ้ายังไม่ถึง
            if (cart.discountRate == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_offer_rounded,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'อีก ฿${(100 - cart.subtotal).toStringAsFixed(0)} รับส่วนลด 5%',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),

            if (cart.discount > 0)
              _Row(cart.discountLabel, -cart.discount, color: Colors.green),

            _Row('VAT 7%', cart.vat),
            const Divider(height: 16),
            _Row(
              'TOTAL',
              cart.total,
              bold: true,
              color: const Color(0xFFFF6B35),
            ),
            const SizedBox(height: 12),

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  '💳 ชำระเงิน ฿${cart.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  final Color? color;
  const _Row(this.label, this.amount, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
          Text(
            '฿${amount.abs().toStringAsFixed(0)}',
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
