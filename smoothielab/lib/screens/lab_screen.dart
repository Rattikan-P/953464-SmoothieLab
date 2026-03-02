import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/smoothie_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/floating_cart_button.dart';

const _fruitsData = [
  ('🍓', 'สตรอว์เบอร์รี่', 15.0),
  ('🥭', 'มะม่วง', 12.0),
  ('🍌', 'กล้วย', 8.0),
  ('💜', 'บลูเบอร์รี่', 18.0),
  ('🥝', 'กีวี', 15.0),
  ('🍑', 'พีช', 14.0),
];

const _extrasData = [
  ('🥛', 'นม', 10.0),
  ('🥥', 'กะทิ', 12.0),
  ('🧃', 'น้ำผลไม้', 8.0),
];

const _sweetnessLevels = [
  ('🚫', 'ไม่หวาน'),
  ('🌿', 'หวานน้อย'),
  ('😊', 'หวานปกติ'),
  ('🍓', 'หวานมาก'),
  ('🤩', 'หวานสุด'),
];

class LabScreen extends StatefulWidget {
  const LabScreen({super.key});
  @override
  State<LabScreen> createState() => LabScreenState();
}

class LabScreenState extends State<LabScreen> {
  final Set<int> _fruits = {};
  final Set<int> _extras = {};
  final Set<int> _toppings = {};

  String _size = 'M';
  int _sweetnessIndex = 2; // หวานปกติ default
  static const double _base = 25;

  double get _sizeMultiplier {
    switch (_size) {
      case 'S':
        return 1.0;
      case 'L':
        return 1.6;
      default:
        return 1.3; // M
    }
  }

  // เพิ่ม method presetFruits ให้ล้าง topping ด้วย
  void presetFruits(List<int> indexes) {
    setState(() {
      _fruits.clear();
      _fruits.addAll(indexes);
      _extras.clear();
      _toppings.clear(); // ✅ clear topping ด้วย
      _size = 'M';
      _sweetnessIndex = 2;
    });
  }

  // คำนวณราคารวม topping ด้วย
  double get _total {
    double t = _base;
    for (final i in _fruits) t += _fruitsData[i].$3;
    for (final i in _extras) t += _extrasData[i].$3;
    for (final i in _toppings) t += kToppingItems[i].price;
    t *= _sizeMultiplier;
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🧪 '),
            Text('Lab', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [CartIconButton()],
      ),
      body: Column(
        children: [
          // ── Formula preview ───────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '// YOUR FORMULA',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fruits.isEmpty
                            ? '—'
                            : _fruits.map((i) => _fruitsData[i].$2).join(' + '),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'เลือก ${_fruits.length + _extras.length} วัตถุดิบ',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '฿${_total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable content ────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Size ───────────────────────────────────
                  const Text(
                    '🥤 เลือกขนาดแก้ว',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (_, constraints) {
                      return Row(
                        children: ['S', 'M', 'L'].map((s) {
                          final sel = _size == s;
                          final labels = {
                            'S': ('เล็ก', '350 ml'),
                            'M': ('กลาง', '500 ml'),
                            'L': ('ใหญ่', '700 ml'),
                          };
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _size = s),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? const Color(0xFFE8F5E9)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: sel
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey.shade300,
                                    width: sel ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      s == 'S'
                                          ? '🥤'
                                          : s == 'M'
                                          ? '🧋'
                                          : '🍹',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      s,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: sel
                                            ? const Color(0xFF4CAF50)
                                            : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      labels[s]!.$1,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: sel ? Colors.green : Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      labels[s]!.$2,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: sel ? Colors.green : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Sweetness ──────────────────────────────
                  const Text(
                    '🍭 ระดับความหวาน',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(_sweetnessLevels.length, (i) {
                      final sel = _sweetnessIndex == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _sweetnessIndex = i),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFFFFF9C4)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sel
                                    ? Colors.amber
                                    : Colors.grey.shade300,
                                width: sel ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _sweetnessLevels[i].$1,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _sweetnessLevels[i].$2,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: sel
                                        ? Colors.amber.shade800
                                        : Colors.grey,
                                    fontWeight: sel
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // ── Fruits ─────────────────────────────────
                  const Text(
                    '🍓 ผลไม้',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final cols = constraints.maxWidth > 400 ? 3 : 3;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: _fruitsData.length,
                        itemBuilder: (_, i) {
                          final d = _fruitsData[i];
                          final sel = _fruits.contains(i);
                          return GestureDetector(
                            onTap: () => setState(() {
                              if (sel)
                                _fruits.remove(i);
                              else
                                _fruits.add(i);
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFFE8F5E9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: sel
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey.shade200,
                                  width: sel ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    d.$1,
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    d.$2,
                                    style: const TextStyle(fontSize: 11),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    '+฿${d.$3.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFFF6B35),
                                    ),
                                  ),
                                  if (sel)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF4CAF50),
                                      size: 14,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Extras ─────────────────────────────────
                  const Text(
                    '🥛 ของเหลว',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    itemCount: _extrasData.length,
                    itemBuilder: (_, i) {
                      final d = _extrasData[i];
                      final sel = _extras.contains(i);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (sel)
                            _extras.remove(i);
                          else
                            _extras.add(i);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFFE8F5E9) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: sel
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey.shade200,
                              width: sel ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(d.$1, style: const TextStyle(fontSize: 26)),
                              const SizedBox(height: 4),
                              Text(d.$2, style: const TextStyle(fontSize: 11)),
                              Text(
                                '+฿${d.$3.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                              if (sel)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF4CAF50),
                                  size: 14,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Toppings ───────────────────────────────────────
                  const Text(
                    '🍓 ท้อปปิ้ง',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(kToppingItems.length, (i) {
                      final t = kToppingItems[i];
                      final sel = _toppings.contains(i);
                      return FilterChip(
                        label: Text(
                          '${t.emoji} ${t.name}\n+฿${t.price.toStringAsFixed(0)}',
                        ),
                        selected: sel,
                        onSelected: (_) => setState(() {
                          if (sel)
                            _toppings.remove(i);
                          else
                            _toppings.add(i);
                        }),
                        selectedColor: const Color(0xFFE8F5E9),
                        checkmarkColor: const Color(0xFF4CAF50),
                        labelStyle: const TextStyle(fontSize: 12),
                      );
                    }),
                  ),
                                    const SizedBox(height: 30),

                ],
                
              ),
            ),
          ),

          // ── Bottom bar ────────────────────────────────────
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        '฿${_total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _fruits.isEmpty
                        ? null
                        : () {
                            final sweetness =
                                _sweetnessLevels[_sweetnessIndex].$2;
                            cart.addItem(
                              SmoothieItem(
                                name: 'My Formula',
                                emoji: '🧪',
                                basePrice: _total / _sizeMultiplier,
                                ingredients: [
                                  ..._fruits.map((i) => _fruitsData[i].$2),
                                  ..._extras.map((i) => _extrasData[i].$2),
                                ],
                                category: 'green',
                              ),
                              size: _size,
                              toppings: _toppings.map((i) => kToppingItems[i]).toList(),
                              sweetness: sweetness,
                            );

                            // ✅ เพิ่มตรงนี้ — clear ทุกอย่างหลังใส่ตะกร้า
                            setState(() {
                              _fruits.clear();
                              _extras.clear();
                              _toppings.clear();
                              _size = 'M';
                              _sweetnessIndex = 2;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'เพิ่ม My Formula (${_size}, $sweetness) แล้ว! 🧪',
                                ),
                                backgroundColor: const Color(0xFF4CAF50),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'ใส่ตะกร้า →',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}