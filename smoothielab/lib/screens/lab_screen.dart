import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/smoothie_item.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/floating_cart_button.dart';
import '../data/ingredients_data.dart';
import '../widgets/cup_painter.dart';


class LabScreen extends StatefulWidget {
  const LabScreen({super.key});
  @override
  State<LabScreen> createState() => LabScreenState();
}

class LabScreenState extends State<LabScreen> {
  final Set<int> _fruits = {};
  final Set<int> _extras = {};
  final Set<int> _veggies = {};
  final Set<int> _toppings = {};

  String _size = 'S';
  int _sweetnessIndex = 2; // หวานปกติ default
  static const double _base = 25;

  String? _presetMenuName; // null = custom, มีค่า = เมนูจาก list
  String? _presetMenuEmoji;

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

  void presetFruits(
    List<int> fruitIndexes, {
    List<int> extrasIndexes = const [],
    List<int> veggieIndexes = const [],
    String? menuName,
    String? menuEmoji,
  }) {
    setState(() {
      _fruits.clear();
      _fruits.addAll(fruitIndexes);

      _extras.clear();
      _extras.addAll(extrasIndexes);

      _veggies.clear();
      _veggies.addAll(veggieIndexes);

      _toppings.clear();
      _size = 'S';
      _sweetnessIndex = 2;
      _presetMenuName = menuName;
      _presetMenuEmoji = menuEmoji;
    });
  }

  void _resetSelection() {
    setState(() {
      _fruits.clear();
      _extras.clear();
      _toppings.clear();
      _veggies.clear();
      _size = 'S';
      _sweetnessIndex = 2;
      _presetMenuName = null;
      _presetMenuEmoji = null;
    });
  }

  Widget _buildSizeButton(String size) {
    final isSelected = _size == size;
    return GestureDetector(
      onTap: () => setState(() => _size = size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          size,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  double get _total {
    double t = _base;
    for (final i in _fruits) t += kFruitsData[i].$3;
    for (final i in _extras) t += kExtrasData[i].$3;
    for (final i in _veggies) t += kVeggiesData[i].$3;
    for (final i in _toppings) t += kToppingItems[i].price;

    // เพิ่มราคาตามไซส์แก้ว (S: 0, M: +7, L: +15)
    final sizeUpgrade = _size == 'L' ? 15.0 : (_size == 'M' ? 7.0 : 0.0);
    t += sizeUpgrade;

    return t;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final nav = context.watch<NavigationProvider>();
    final isEditing = nav.editingCartIndex != null;

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
                            : _fruits.map((i) => kFruitsData[i].$2).join(' + '),
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
                                  vertical: 8,
                                  horizontal: 4,
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
                                    if (s == 'M' || s == 'L')
                                      Text(
                                        s == 'M' ? '+฿7' : '+฿15',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: sel
                                              ? Colors.orange
                                              : Colors.orange.shade700,
                                          fontWeight: FontWeight.bold,
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
                    children: List.generate(kSweetnessLevels.length, (i) {
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
                                  kSweetnessLevels[i].$1,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  kSweetnessLevels[i].$2,
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
                        itemCount: kFruitsData.length,
                        itemBuilder: (_, i) {
                          final d = kFruitsData[i];
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

                  // ── Fruits ─────────────────────────────────
                  const Text(
                    '🥦 ผัก',
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
                        itemCount: kVeggiesData.length,
                        itemBuilder: (_, i) {
                          final d = kVeggiesData[i];
                          final sel = _veggies.contains(i);
                          return GestureDetector(
                            onTap: () => setState(() {
                              if (sel)
                                _veggies.remove(i);
                              else
                                _veggies.add(i);
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
                    itemCount: kExtrasData.length,
                    itemBuilder: (_, i) {
                      final d = kExtrasData[i];
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
                      Text(
                        '${_fruits.length + _extras.length + _veggies.length} รายการ • ไซส์ $_size',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // ปุ่มถังขยะ
                      IconButton(
                        onPressed: _resetSelection,
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.grey.shade600,
                        tooltip: 'ล้างทั้งหมด',
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                    onPressed: (_fruits.isEmpty && _veggies.isEmpty)
                        ? null
                        : () {
                            final sweetness =
                                kSweetnessLevels[_sweetnessIndex].$2;

                            // ถ้ามาจากเมนู ใช้ชื่อและ emoji เมนูนั้น
                            final isFromMenu = _presetMenuName != null;
                            final itemName = _presetMenuName ?? 'My Formula';
                            final itemEmoji = _presetMenuEmoji ?? '🧪';

                            final newItem = SmoothieItem(
                              name: itemName,
                              emoji: itemEmoji,
                              basePrice: _total / _sizeMultiplier,
                              ingredients: [
                                ..._fruits.map((i) => kFruitsData[i].$2),
                                ..._extras.map((i) => kExtrasData[i].$2),
                                ..._veggies.map((i) => kVeggiesData[i].$2),
                              ],
                              category: 'green',
                            );

                            final nav = context.read<NavigationProvider>();

                            if (isEditing) {
                              cart.updateItemAt(
                                nav.editingCartIndex!,
                                newItem,
                                size: _size,
                                toppings: _toppings
                                    .map((i) => kToppingItems[i])
                                    .toList(),
                                sweetness: sweetness,
                                fruitIndexes: _fruits.toList(),
                                extrasIndexes: _extras.toList(),
                                veggieIndexes: _veggies.toList(),
                                isCustom: !isFromMenu, // ✅
                              );
                              nav.clearEditingIndex();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('อัพเดตตะกร้าแล้ว ✅'),
                                  backgroundColor: const Color(0xFF4CAF50),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              cart.addItem(
                                newItem,
                                size: _size,
                                toppings: _toppings
                                    .map((i) => kToppingItems[i])
                                    .toList(),
                                sweetness: sweetness,
                                isCustom:
                                    !isFromMenu, // false ถ้าเป็นเมนูจาก list
                                fruitIndexes: _fruits.toList(),
                                extrasIndexes: _extras.toList(),
                                veggieIndexes: _veggies.toList(),
                              );
                              // snackbar แสดงชื่อเมนูจริง
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'เพิ่ม $itemName แล้ว! ${isFromMenu ? itemEmoji : "🧪"}',
                                  ),
                                  backgroundColor: const Color(0xFF4CAF50),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }

                            // clear
                            setState(() {
                              _fruits.clear();
                              _extras.clear();
                              _toppings.clear();
                              _veggies.clear();
                              _size = 'M';
                              _sweetnessIndex = 2;
                              _presetMenuName = null; // ✅ reset
                              _presetMenuEmoji = null; // ✅
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditing
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF4CAF50),
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
                    // เปลี่ยนข้อความปุ่มตาม mode
                    child: Text(
                      isEditing ? 'อัพเดตตะกร้า' : 'ใส่ตะกร้า →',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
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
