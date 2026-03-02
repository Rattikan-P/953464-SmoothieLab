import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../widgets/floating_cart_button.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _filter = 'all';

  Color _statusColor(String s) {
    switch (s) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'completed':
        return '✓ เสร็จสิ้น';
      case 'cancelled':
        return '✗ ยกเลิก';
      default:
        return '⏳ กำลังทำ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'ประวัติออเดอร์',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [CartIconButton()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in [
                    ('all', 'ทั้งหมด'),
                    ('processing', 'กำลังทำ'),
                    ('completed', 'เสร็จสิ้น'),
                    ('cancelled', 'ยกเลิก'),
                  ])
                    GestureDetector(
                      onTap: () => setState(() => _filter = f.$1),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _filter == f.$1
                              ? const Color(0xFF4CAF50)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _filter == f.$1
                                ? const Color(0xFF4CAF50)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          f.$2,
                          style: TextStyle(
                            color: _filter == f.$1
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<OrderModel>('orders').listenable(),
              builder: (_, Box<OrderModel> box, __) {
                final orders =
                    box.values
                        .where((o) => _filter == 'all' || o.status == _filter)
                        .toList()
                      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

                final Map<String, List<OrderModel>> grouped = {};
                for (final o in orders) {
                  grouped.putIfAbsent(o.orderId, () => []).add(o);
                }

                if (grouped.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🛒', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 8),
                        Text(
                          'ยังไม่มีออเดอร์',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: grouped.length,
                  itemBuilder: (_, i) {
                    final id = grouped.keys.elementAt(i);
                    final items = grouped[id]!;
                    final first = items.first;
                    final total = items.fold(0.0, (s, o) => s + o.totalPrice);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    first.status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _statusLabel(first.status),
                                  style: TextStyle(
                                    color: _statusColor(first.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            DateFormat('dd MMM HH:mm').format(first.orderDate),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const Divider(height: 16),
                          for (final item in items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Text(
                                    item.menuEmoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.menuName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'SIZE: ${item.size}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '฿${item.totalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Divider(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '฿${total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (first.status == 'processing')
                                ElevatedButton(
                                  onPressed: () {
                                    for (final o in items) {
                                      o.status = 'completed';
                                      o.save();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text('ติดตามออเดอร์'),
                                )
                              else
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('สั่งอีกครั้ง'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
