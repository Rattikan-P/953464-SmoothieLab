import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../models/smoothie_item.dart';
import '../data/ingredients_data.dart';
import '../providers/cart_provider.dart';
import '../widgets/floating_cart_button.dart';
import 'track_order_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  String _filter = 'all';
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return Colors.red.shade400;
      default:
        return const Color(0xFFFF9800);
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'completed':
        return const Color(0xFFE8F5E9);
      case 'cancelled':
        return Colors.red.shade50;
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'completed':
        return '✓  Completed';
      case 'cancelled':
        return '✗  Cancelled';
      default:
        return '⏳  Processing';
    }
  }

  String _statusEmoji(String s) {
    switch (s) {
      case 'completed':
        return '✅';
      case 'cancelled':
        return '❌';
      default:
        return '🔄';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // AppBar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order History',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Track your smoothie journey',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const CartIconButton(),
                  ],
                ),
              ),

              // Filter Tabs
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final f in [
                        ('all', 'All', '📋'),
                        ('processing', 'Processing', '🔄'),
                        ('completed', 'Completed', '✅'),
                        ('cancelled', 'Cancelled', '❌'),
                      ])
                        _FilterChip(
                          label: f.$2,
                          emoji: f.$3,
                          selected: _filter == f.$1,
                          onTap: () => setState(() => _filter = f.$1),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 2),

              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<OrderModel>('orders').listenable(),
                  builder: (_, Box<OrderModel> box, __) {
                    final orders =
                        box.values
                            .where(
                              (o) => _filter == 'all' || o.status == _filter,
                            )
                            .toList()
                          ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

                    final Map<String, List<OrderModel>> grouped = {};
                    for (final o in orders) {
                      grouped.putIfAbsent(o.orderId, () => []).add(o);
                    }

                    if (grouped.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '🛒',
                                  style: TextStyle(fontSize: 42),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No orders yet',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your order history will appear here',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: grouped.length,
                      itemBuilder: (_, i) {
                        final id = grouped.keys.elementAt(i);
                        final items = grouped[id]!;
                        final first = items.first;
                        final total = items.fold(
                          0.0,
                          (s, o) => s + o.totalPrice,
                        );
                        return _OrderCard(
                          id: id,
                          items: items,
                          first: first,
                          total: total,
                          statusColor: _statusColor(first.status),
                          statusBg: _statusBg(first.status),
                          statusLabel: _statusLabel(first.status),
                          statusEmoji: _statusEmoji(first.status),
                          cardIndex: i,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: แปลง OrderModel → CartItem แล้ว add เข้า CartProvider
// ─────────────────────────────────────────────────────────────────────────────

/// ค้นหา ToppingItem จากชื่อใน kToppingData
ToppingItem? _findTopping(String name) {
  try {
    return kToppingData.firstWhere((t) => t.name == name);
  } catch (_) {
    return null;
  }
}

SmoothieItem _smoothieFromOrder(OrderModel order) {
  // ลอง match กับ kMenuItems ก่อน (preset menu)
  try {
    return kMenuItems.firstWhere(
      (m) => m.name == order.menuName && m.emoji == order.menuEmoji,
    );
  } catch (_) {
    // custom smoothie — back-calculate basePrice จาก itemPriceRaw
    // itemPriceRaw = (basePrice * sizeMultiplier + toppingTotal) * qty
    // qty ของแต่ละ row ใน history = 1 เสมอ
    // ดังนั้น: basePrice = (itemPriceRaw - toppingTotal) / sizeMultiplier
    final toppings = order.toppings
        .map((name) => _findTopping(name))
        .whereType<ToppingItem>()
        .toList();
    final toppingTotal = toppings.fold(0.0, (s, t) => s + t.price);
    final multiplier = kSizeMultiplier[order.size] ?? 1.3;
    final basePrice = (order.itemPriceRaw - toppingTotal) / multiplier;

    return SmoothieItem(
      name: order.menuName,
      emoji: order.menuEmoji,
      basePrice: basePrice,
      ingredients: order.ingredients,
      category: 'custom',
    );
  }
}

void _orderAgain(BuildContext context, List<OrderModel> orders) {
  final cart = context.read<CartProvider>();

  for (final order in orders) {
    final smoothie = _smoothieFromOrder(order);
    final toppings = order.toppings
        .map((name) => _findTopping(name))
        .whereType<ToppingItem>()
        .toList();

    // Use indexes directly from OrderModel (saved during payment)
    // These already include the proper offsets
    final fruitIndexes = order.fruitIndexes;
    final extrasIndexes = order.extrasIndexes;
    final veggieIndexes = order.veggieIndexes;
    final herbsIndexes = order.herbsIndexes;

    final isCustom = !kMenuItems.any(
      (m) => m.name == order.menuName && m.emoji == order.menuEmoji,
    );

    cart.addItem(
      smoothie,
      size: order.size,
      toppings: toppings,
      sweetness: order.sweetness,
      isCustom: isCustom,
      fruitIndexes: fruitIndexes,
      extrasIndexes: extrasIndexes,
      veggieIndexes: veggieIndexes,
      herbsIndexes: herbsIndexes,
      toppingsIndexes: order.toppingsIndexes,
    );
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Text('🛒', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(
            'Added ${orders.length} item${orders.length > 1 ? 's' : ''} to cart!',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label, emoji;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2E7D32) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String id;
  final List<OrderModel> items;
  final OrderModel first;
  final double total;
  final Color statusColor, statusBg;
  final String statusLabel, statusEmoji;
  final int cardIndex;

  const _OrderCard({
    required this.id,
    required this.items,
    required this.first,
    required this.total,
    required this.statusColor,
    required this.statusBg,
    required this.statusLabel,
    required this.statusEmoji,
    required this.cardIndex,
  });

  /// Dialog ยืนยันยกเลิกออเดอร์
  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Column(
          children: [
            Text('🚫', style: TextStyle(fontSize: 36)),
            SizedBox(height: 8),
            Text(
              'Cancel Order?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        content: Text(
          'Cancel order "$id"?\nThis action cannot be undone.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Keep Order',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final box = Hive.box<OrderModel>('orders');
      for (final entry in box.toMap().entries) {
        if (entry.value.orderId == id) {
          entry.value.status = 'cancelled';
          entry.value.save();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + cardIndex * 80),
      curve: Curves.easeOut,
      builder: (_, value, child) => Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: statusColor.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: statusBg.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        statusEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          id,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          DateFormat(
                            'dd MMM yyyy  •  HH:mm',
                          ).format(first.orderDate),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Items ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FFF4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                item.menuEmoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.menuName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'SIZE ${item.size}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (item.ingredients.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: item.ingredients
                                        .take(4)
                                        .map(
                                          (ing) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              ing,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                                if (item.sweetness.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9C4),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '🍭 ${item.sweetness}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFF57F17),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                if (item.toppings.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: item.toppings
                                        .map(
                                          (t) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.pink.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              t,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.pink.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '฿${item.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ── Footer ───────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL PAID',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '฿${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFF6B35),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  // Buttons
                  if (first.status == 'processing')
                    // Track only
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TrackOrderScreen(orderId: id, items: items),
                        ),
                      ),
                      icon: const Icon(Icons.location_on_rounded, size: 15),
                      label: const Text(
                        'Track Order',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    )
                  else
                    // Order Again
                    OutlinedButton.icon(
                      onPressed: () => _orderAgain(context, items),
                      icon: const Icon(Icons.replay_rounded, size: 15),
                      label: const Text(
                        'Order Again',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        side: const BorderSide(
                          color: Color(0xFF4CAF50),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
