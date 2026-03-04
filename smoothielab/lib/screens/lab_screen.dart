import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/smoothie_item.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/floating_cart_button.dart';
import '../data/ingredients_data.dart';
import '../widgets/smoothie_cup_widget.dart';

class LabScreen extends StatefulWidget {
  const LabScreen({super.key});
  @override
  State<LabScreen> createState() => LabScreenState();
}

// Widget สำหรับวัตถุดิบที่ลอยในแก้วพร้อม animation
class _FloatingIngredient extends StatefulWidget {
  final String emoji;
  final double size;
  final double rotation;
  final int floatDuration;
  final int floatDelay;

  const _FloatingIngredient({
    required this.emoji,
    required this.size,
    required this.rotation,
    required this.floatDuration,
    required this.floatDelay,
  });

  @override
  State<_FloatingIngredient> createState() => _FloatingIngredientState();
}

class _FloatingIngredientState extends State<_FloatingIngredient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.floatDuration),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: -3,
      end: 3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // เริ่ม animation หลังจาก delay
    Future.delayed(Duration(milliseconds: widget.floatDelay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.rotate(angle: widget.rotation, child: child),
        );
      },
      child: Text(
        widget.emoji,
        style: TextStyle(fontSize: widget.size, height: 1.0),
      ),
    );
  }
}

// Widget สำหรับฟองอากาศ
class _Bubble extends StatefulWidget {
  final double startX;
  final double startY;
  final double endY;
  final double size;

  const _Bubble({
    required this.startX,
    required this.startY,
    required this.endY,
    required this.size,
  });

  @override
  State<_Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<_Bubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    final duration = 2000 + (widget.startX * 10).toInt();

    _controller = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // เริ่ม animation และ repeat เมื่อจบ
    _controller.forward().then((_) {
      if (mounted) {
        _controller.reset();
        _controller.forward().then((_) {
          if (mounted) {
            // สุ่มเวลา delay ก่อนเริ่มใหม่
            Future.delayed(
              Duration(milliseconds: 500 + Random().nextInt(1000)),
              () {
                if (mounted) {
                  _controller.reset();
                  _controller.forward();
                }
              },
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentY =
            widget.startY + (widget.endY - widget.startY) * _animation.value;

        return Positioned(
          left: widget.startX + (currentY * 0.1).clamp(-5, 5),
          top: currentY,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.4),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ข้อมูลตำแหน่งของวัตถุดิบแต่ละชิ้น
class _IngredientPosition {
  final String emoji;
  final double x;
  final double y;
  final double rotation;
  final double size;
  final int floatDuration;

  _IngredientPosition({
    required this.emoji,
    required this.x,
    required this.y,
    required this.rotation,
    required this.size,
    required this.floatDuration,
  });
}

// ข้อมูลวัตถุดิบที่เลือก (เก็บลำดับการเลือก)
class _SelectedIngredient {
  final String emoji;
  final String name;
  final double price;
  final String type; // 'fruit', 'veggie', 'extra'

  _SelectedIngredient({
    required this.emoji,
    required this.name,
    required this.price,
    required this.type,
  });
}

class LabScreenState extends State<LabScreen>
    with SingleTickerProviderStateMixin {
  final Set<int> _fruits = {};
  final Set<int> _extras = {};
  final Set<int> _veggies = {};
  final Set<int> _herbs = {};
  final Set<int> _toppings = {};

  // เก็บตำแหน่งของวัตถุดิบที่ลอยในแก้ว
  final List<_IngredientPosition> _ingredientPositions = [];

  // เก็บลำดับของวัตถุดิบที่เลือก (ตามลำดับที่เลือกจริง)
  final List<_SelectedIngredient> _selectedIngredientsOrder = [];

  // Animation controller สำหรับ shake effect
  late AnimationController _shakeController;
  Animation<double>? _shakeAnimation;

  String _size = 'S';
  int _sweetnessIndex = 2; // หวานปกติ default
  static const double _base = 25;

  String? _presetMenuName; // null = custom, มีค่า = เมนูจาก list
  String? _presetMenuEmoji;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPendingPreset();
  }

  void _loadPendingPreset() {
    final nav = context.read<NavigationProvider>();
    final pendingFruits = nav.pendingFruits;
    final pendingExtras = nav.pendingExtras;
    final pendingVeggies = nav.pendingVeggies;
    final pendingHerbs = nav.pendingHerbs;
    final pendingToppings = nav.pendingToppings;
    final pendingSize = nav.pendingSize;
    final pendingSweetness = nav.pendingSweetness;

    if (pendingFruits != null ||
        pendingExtras != null ||
        pendingVeggies != null ||
        pendingHerbs != null ||
        pendingToppings != null ||
        pendingSize != null ||
        pendingSweetness != null) {
      presetFruits(
        pendingFruits ?? [],
        extrasIndexes: pendingExtras ?? [],
        veggieIndexes: pendingVeggies ?? [],
        herbsIndexes: pendingHerbs ?? [],
        toppingsIndexes: pendingToppings ?? [],
        menuName: nav.pendingMenuName,
        menuEmoji: nav.pendingMenuEmoji,
        size: pendingSize ?? 'S',
        sweetness: pendingSweetness ?? 'หวานปกติ',
      );
      nav.clearPendingPreset();
    } else {
      // ไม่มี preset ให้โหลด → ต้อง reset เพื่อให้ครั้งต่อไปไม่ค้างค่าเก่า
      _resetSelection();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // Shake effect เมื่อเพิ่มวัตถุดิบ
  void _shakeCup() {
    _shakeController.forward(from: 0);
  }

  double get _sizeMultiplier {
    switch (_size) {
      case 'S':
        return 0;
      case 'L':
        return 15;
      default:
        return 7; // M
    }
  }

  void presetFruits(
    List<int> fruitIndexes, {
    List<int> extrasIndexes = const [],
    List<int> veggieIndexes = const [],
    List<int> herbsIndexes = const [],
    List<int> toppingsIndexes = const [],
    String? menuName,
    String? menuEmoji,
    String size = 'S',
    String sweetness = 'หวานปกติ',
  }) {
    setState(() {
      _selectedIngredientsOrder.clear();

      _fruits.clear();
      _extras.clear();
      _veggies.clear();
      _herbs.clear();

      // Process fruit indexes (no offset)
      for (final i in fruitIndexes) {
        if (i < kFruitsData.length) {
          _fruits.add(i);
          _addIngredientToOrder('fruit', i, kFruitsData);
        }
      }

      // Process extras indexes (offset 30)
      for (final i in extrasIndexes) {
        if (i >= 30 && i < 30 + kExtrasData.length) {
          final adjustedIndex = i - 30;
          _extras.add(adjustedIndex);
          _addIngredientToOrder('extra', adjustedIndex, kExtrasData);
        }
      }

      // Process veggie indexes (offset 100)
      for (final i in veggieIndexes) {
        if (i >= 100 && i < 100 + kVeggiesData.length) {
          final adjustedIndex = i - 100;
          _veggies.add(adjustedIndex);
          _addIngredientToOrder('veggie', adjustedIndex, kVeggiesData);
        }
      }

      // Process herbs indexes (offset 260)
      for (final i in herbsIndexes) {
        if (i >= 260 && i < 260 + kHerbsData.length) {
          final adjustedIndex = i - 260;
          _herbs.add(adjustedIndex);
          _addIngredientToOrder('herb', adjustedIndex, kHerbsData);
        }
      }

      // Process toppings indexes
      _toppings.clear();
      for (final i in toppingsIndexes) {
        if (i >= 0 && i < kToppingData.length) {
          _toppings.add(i);
        }
      }

      // Set size
      _size = size;

      // Set sweetness based on string
      switch (sweetness) {
        case 'ไม่หวาน':
        case 'No sugar':
          _sweetnessIndex = 0;
          break;
        case 'หวานน้อย':
        case 'Less sugar':
          _sweetnessIndex = 1;
          break;
        case 'หวานปกติ':
        case 'Normal':
          _sweetnessIndex = 2;
          break;
        case 'หวาน':
        case 'Sweet':
          _sweetnessIndex = 3;
          break;
        case 'หวานมาก':
        case 'Extra sweet':
          _sweetnessIndex = 4;
          break;
        default:
          _sweetnessIndex = 2;
      }

      _presetMenuName = menuName;
      _presetMenuEmoji = menuEmoji;

      _updateIngredientPositions();
    });
  }

  void _resetSelection() {
    setState(() {
      _fruits.clear();
      _extras.clear();
      _veggies.clear();
      _herbs.clear();
      _toppings.clear();
      _size = 'S';
      _sweetnessIndex = 2;
      _presetMenuName = null;
      _presetMenuEmoji = null;
      _ingredientPositions.clear();
      _selectedIngredientsOrder.clear();
    });
  }

  // Helper method to add ingredient to order list
  void _addIngredientToOrder(
    String type,
    int index,
    List<(String, String, double)> dataList,
  ) {
    final data = dataList[index];
    _selectedIngredientsOrder.add(
      _SelectedIngredient(
        emoji: data.$1,
        name: data.$2,
        price: data.$3,
        type: type,
      ),
    );
  }

  // Helper method to remove ingredient from order list
  void _removeIngredientFromOrder(String type, int index) {
    // Get the data for this ingredient
    List<(String, String, double)> dataList;
    switch (type) {
      case 'fruit':
        dataList = kFruitsData;
        break;
      case 'veggie':
        dataList = kVeggiesData;
        break;
      case 'extra':
        dataList = kExtrasData;
        break;
      case 'herb':
        dataList = kHerbsData;
        break;
      default:
        return;
    }

    final data = dataList[index];

    // Find and remove the first matching item from the order list
    // (removes from the end to handle duplicates correctly)
    for (int i = _selectedIngredientsOrder.length - 1; i >= 0; i--) {
      final item = _selectedIngredientsOrder[i];
      if (item.type == type &&
          item.emoji == data.$1 &&
          item.name == data.$2 &&
          item.price == data.$3) {
        _selectedIngredientsOrder.removeAt(i);
        break;
      }
    }
  }

  // อัปเดตตำแหน่งวัตถุดิบเมื่อมีการเปลี่ยนแปลง
  void _updateIngredientPositions({bool forceRecalculate = false}) {
    // ใช้ลำดับการเลือกจริงจาก _selectedIngredientsOrder
    final allEmojis = _selectedIngredientsOrder
        .map((item) => item.emoji)
        .toList();

    final cupW = _cupDimensions.$1;
    final cupH = _cupDimensions.$2;

    // คำนวณตำแหน่งน้ำในแก้ว
    final liquidTop = cupH - (cupH * 0.85) + 12;
    final liquidBottom = cupH + 8;

    // สร้างตำแหน่งใหม่สำหรับวัตถุดิบที่เพิ่มเข้ามา
    final newPositions = <_IngredientPosition>[];

    for (int i = 0; i < allEmojis.length; i++) {
      // ถ้ามีตำแหน่งเดิมอยู่แล้วและไม่ได้บังคับคำนวณใหม่ ให้ใช้ตำแหน่งเดิม
      if (!forceRecalculate && i < _ingredientPositions.length) {
        newPositions.add(_ingredientPositions[i]);
      } else {
        // สร้างตำแหน่งใหม่
        final random = Random(i * 17);

        final randomX = 20 + random.nextDouble() * (cupW - 40);

        final minY = liquidTop + 10;
        final maxY = liquidBottom - 25;
        final randomY = minY + random.nextDouble() * (maxY - minY);

        final randomRotation = (random.nextDouble() * 50 - 25) * 3.14159 / 180;
        final randomSize = 14 + random.nextDouble() * 8;
        final floatDuration = 2000 + random.nextInt(2000);

        newPositions.add(
          _IngredientPosition(
            emoji: allEmojis[i],
            x: randomX,
            y: randomY,
            rotation: randomRotation,
            size: randomSize,
            floatDuration: floatDuration,
          ),
        );
      }
    }

    _ingredientPositions.clear();
    _ingredientPositions.addAll(newPositions);
  }

  Widget _buildSizeButton(String size) {
    final isSelected = _size == size;
    return GestureDetector(
      onTap: () {
        _size = size;
        setState(() {
          _updateIngredientPositions(forceRecalculate: true);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
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
    for (final i in _herbs) t += kHerbsData[i].$3;  // ✅ เพิ่ม herbs
    for (final i in _toppings) t += kToppingData[i].price;

    // เพิ่มราคาตามไซส์แก้ว (S: 0, M: +7, L: +15)
    final sizeUpgrade = _size == 'L' ? 15.0 : (_size == 'M' ? 7.0 : 0.0);
    t += sizeUpgrade;

    return t;
  }

  // Calculate base price WITHOUT toppings (for cart)
  double get _basePriceWithoutToppings {
    double t = _base;
    for (final i in _fruits) t += kFruitsData[i].$3;
    for (final i in _extras) t += kExtrasData[i].$3;
    for (final i in _veggies) t += kVeggiesData[i].$3;
    for (final i in _herbs) t += kHerbsData[i].$3;

    // เพิ่มราคาตามไซส์แก้ว (S: 0, M: +7, L: +15)
    final sizeUpgrade = _size == 'L' ? 15.0 : (_size == 'M' ? 7.0 : 0.0);
    t += sizeUpgrade;

    return t;
  }

  // คำนวณสี blend จากวัตถุดิบที่เลือก
  Color get _blendedColor {
    final allIndices = [..._fruits, ..._extras, ..._veggies, ..._herbs];

    if (allIndices.isEmpty) {
      return const Color(0xFFE8F5E9); // สีเขียวอ่อน default
    }

    int r = 0, g = 0, b = 0;
    int count = 0;

    for (final i in _fruits) {
      final color = kIngredientColors[i] ?? Colors.green;
      r += color.red;
      g += color.green;
      b += color.blue;
      count++;
    }

    for (final i in _extras) {
      // extras ใช้ index 30+
      final color = kIngredientColors[30 + i] ?? Colors.brown;
      r += color.red;
      g += color.green;
      b += color.blue;
      count++;
    }

    for (final i in _veggies) {
      // veggies ใช้ index 100+
      final color = kIngredientColors[100 + i] ?? Colors.green;
      r += color.red;
      g += color.green;
      b += color.blue;
      count++;
    }

    for (final i in _herbs) {
      // herbs ใช้ index 260+
      final color = kIngredientColors[260 + i] ?? Colors.green;
      r += color.red;
      g += color.green;
      b += color.blue;
      count++;
    }

    return Color.fromARGB(255, r ~/ count, g ~/ count, b ~/ count);
  }

  // ขนาดแก้วตามไซส์
  (double, double) get _cupDimensions {
    switch (_size) {
      case 'S':
        return (120.0, 170.0);
      case 'L':
        return (150.0, 210.0);
      default:
        return (135.0, 190.0); // M
    }
  }

  // สร้าง floating ingredients ในแก้ว
  List<Widget> _buildFloatingIngredients() {
    final widgets = <Widget>[];

    // เพิ่ม bubbles ถ้ามีวัตถุดิบ
    if (_ingredientPositions.isNotEmpty) {
      final cupH = _cupDimensions.$2;
      final liquidTop = cupH - (cupH * 0.85) + 12;

      // สร้าง 5-8 bubbles
      final bubbleCount = 5 + (_ingredientPositions.length % 4);
      for (int i = 0; i < bubbleCount; i++) {
        final random = Random(i * 23);
        final startX = 20 + random.nextDouble() * (_cupDimensions.$1 - 40);
        final startY = liquidTop + 20 + random.nextDouble() * 30;
        final endY = liquidTop - 20 - random.nextDouble() * 20;
        final size = 3.0 + random.nextDouble() * 5.0;

        widgets.add(
          KeyedSubtree(
            key: ValueKey('bubble_${_ingredientPositions.length}_$i'),
            child: _Bubble(
              startX: startX,
              startY: startY,
              endY: endY,
              size: size,
            ),
          ),
        );
      }
    }

    for (int i = 0; i < _ingredientPositions.length; i++) {
      final pos = _ingredientPositions[i];

      widgets.add(
        Positioned(
          key: ValueKey('ingredient_$i'),
          left: pos.x + 10,
          top: pos.y,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 800 + i * 100),
            curve: Curves.easeOut,
            builder: (_, value, child) {
              return Transform.translate(
                offset: Offset(0, 15 * (1 - value)),
                child: Opacity(opacity: value * 0.9, child: child),
              );
            },
            child: _FloatingIngredient(
              emoji: pos.emoji,
              size: pos.size,
              rotation: pos.rotation,
              floatDuration: pos.floatDuration,
              floatDelay: i * 200,
            ),
          ),
        ),
      );
    }

    return widgets;
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
        titleSpacing: 20,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CartIconButton(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Cup Hero Section with Formula ───────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.pink.shade50,
                  Colors.white,
                  Colors.green.shade50,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -40,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pink.shade700.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: -10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.shade700.withValues(alpha: 0.05),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      // ── Cup with decorative shadow plate ──────────
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Decorative plate/shadow under cup
                          Container(
                            width: 160,
                            height: 30,
                            margin: const EdgeInsets.only(top: 140),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.06),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                                BoxShadow(
                                  color: Colors.pink.shade700.withValues(
                                    alpha: 0.04,
                                  ),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),

                          // Cup
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: AnimatedBuilder(
                                animation:
                                    _shakeAnimation ??
                                    const AlwaysStoppedAnimation(0),
                                builder: (context, child) {
                                  if (_shakeAnimation == null)
                                    return child ?? const SizedBox();

                                  final shakeOffset =
                                      _shakeAnimation!.value < 0.5
                                      ? _shakeAnimation!.value * 10
                                      : (1 - _shakeAnimation!.value) * 10;

                                  return Transform.translate(
                                    offset: Offset(
                                      shakeOffset * 0.3,
                                      shakeOffset * 0.1,
                                    ),
                                    child: Transform.rotate(
                                      angle: shakeOffset * 0.02,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.pink.shade700.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(-3, 6),
                                      ),
                                      BoxShadow(
                                        color: Colors.green.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 15,
                                        offset: const Offset(3, 3),
                                      ),
                                    ],
                                  ),
                                  child: SmoothieCupWidget(
                                    cupColor: _blendedColor,
                                    fruits: _selectedIngredientsOrder
                                        .map((item) => item.emoji)
                                        .toList(),
                                    size: _cupDimensions.$1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Selected Ingredients Row ───────────────────
                      Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.green.shade50,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Your Formula',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_selectedIngredientsOrder.isEmpty)
                                Text(
                                  'Not selected',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade400,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              else ...[
                                ..._selectedIngredientsOrder.map((item) {
                                  Color chipColor;
                                  Color textColor;

                                        switch (item.type) {
                                          case 'fruit':
                                            chipColor = Colors.pink.shade50;
                                            textColor = Colors.pink.shade700;
                                            break;
                                          case 'veggie':
                                            chipColor = Colors.green.shade50;
                                            textColor = Colors.green;
                                            break;
                                          case 'extra':
                                            chipColor = Colors.amber.shade50;
                                            textColor = Colors.amber.shade700;
                                            break;
                                          case 'herb':
                                            chipColor = Colors.lime.shade50;
                                            textColor = Colors.lime.shade700;
                                            break;
                                          default:
                                            chipColor = Colors.grey.shade50;
                                            textColor = Colors.grey.shade700;
                                        }

                                  return Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: chipColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: textColor.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.emoji,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: textColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_selectedIngredientsOrder.length}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
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
                    '🥤 Select Size',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (_, constraints) {
                      return Row(
                        children: ['S', 'M', 'L'].map((s) {
                          final sel = _size == s;
                          final labels = {
                            'S': ('Small', '350 ml'),
                            'M': ('Medium', '500 ml'),
                            'L': ('Large', '700 ml'),
                          };
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _size = s;
                                setState(() {
                                  _updateIngredientPositions(
                                    forceRecalculate: true,
                                  );
                                });
                              },
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
                                        ? Colors.green
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
                                            ? Colors.green
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
                                    if (s == 'S')
                                      Text(
                                        '฿0',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: sel
                                              ? Colors.grey
                                              : Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
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
                    '🍭 Sweetness',
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
                                    ? Colors.amber.shade700
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
                    '🍓 Fruits',
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
                            onTap: () {
                              if (sel) {
                                _fruits.remove(i);
                                _removeIngredientFromOrder('fruit', i);
                              } else {
                                _fruits.add(i);
                                _addIngredientToOrder('fruit', i, kFruitsData);
                                _shakeCup();
                              }
                              setState(() {
                                _updateIngredientPositions();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFFE8F5E9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: sel
                                      ? Colors.green
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
                                      color: Colors.green,
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
                    '🥦 Vegetables',
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
                            onTap: () {
                              if (sel) {
                                _veggies.remove(i);
                                _removeIngredientFromOrder('veggie', i);
                              } else {
                                _veggies.add(i);
                                _addIngredientToOrder(
                                  'veggie',
                                  i,
                                  kVeggiesData,
                                );
                                _shakeCup();
                              }
                              setState(() {
                                _updateIngredientPositions();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFFE8F5E9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: sel
                                      ? Colors.green
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
                                      color: Colors.green,
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
                    '🥛 Extras',
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
                        onTap: () {
                          if (sel) {
                            _extras.remove(i);
                            _removeIngredientFromOrder('extra', i);
                          } else {
                            _extras.add(i);
                            _addIngredientToOrder('extra', i, kExtrasData);
                            _shakeCup();
                          }
                          setState(() {
                            _updateIngredientPositions();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFFE8F5E9) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: sel ? Colors.green : Colors.grey.shade200,
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
                                  color: Colors.green,
                                  size: 14,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Herbs ─────────────────────────────────
                  const Text(
                    '🌿 Herbs',
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
                    itemCount: kHerbsData.length,
                    itemBuilder: (_, i) {
                      final d = kHerbsData[i];
                      final sel = _herbs.contains(i);
                      return GestureDetector(
                        onTap: () {
                          if (sel) {
                            _herbs.remove(i);
                            _removeIngredientFromOrder('herb', i);
                          } else {
                            _herbs.add(i);
                            _addIngredientToOrder('herb', i, kHerbsData);
                            _shakeCup();
                          }
                          setState(() {
                            _updateIngredientPositions();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFFE8F5E9) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: sel ? Colors.green : Colors.grey.shade200,
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
                                  color: Colors.green,
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
                    '🍓 Toppings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(kToppingData.length, (i) {
                      final t = kToppingData[i];
                      final sel = _toppings.contains(i);
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t.emoji),
                            const SizedBox(width: 4),
                            Text(t.name),
                            const SizedBox(width: 6),
                            Text(
                              '+฿${t.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: sel
                                    ? Colors.green
                                    : Colors.pink.shade700,
                              ),
                            ),
                          ],
                        ),
                        selected: sel,
                        onSelected: (_) => setState(() {
                          if (sel)
                            _toppings.remove(i);
                          else
                            _toppings.add(i);
                        }),
                        selectedColor: const Color(0xFFE8F5E9),
                        checkmarkColor: Colors.green,
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
                        '${_fruits.length + _extras.length + _veggies.length + _herbs.length} items • Size $_size',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Clear button
                      IconButton(
                        onPressed: _resetSelection,
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.grey.shade600,
                        tooltip: 'Clear all',
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
                                final itemName =
                                    _presetMenuName ?? 'My Formula';
                                final itemEmoji = _presetMenuEmoji ?? '🧪';

                            final newItem = SmoothieItem(
                              name: itemName,
                              emoji: itemEmoji,
                              basePrice: _basePriceWithoutToppings - _sizeMultiplier,
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
                                    .map((i) => kToppingData[i])
                                    .toList(),
                                sweetness: sweetness,
                                fruitIndexes: _fruits.toList(),
                                extrasIndexes: _extras.map((i) => i + 30).toList(),
                                veggieIndexes: _veggies.map((i) => i + 100).toList(),
                                herbsIndexes: _herbs.map((i) => i + 260).toList(),
                                isCustom: !isFromMenu,
                                toppingsIndexes: _toppings.toList(), // ✅ เพิ่ม
                              );
                              nav.clearEditingIndex();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Cart updated ✅'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              cart.addItem(
                                newItem,
                                size: _size,
                                toppings: _toppings
                                    .map((i) => kToppingData[i])
                                    .toList(),
                                sweetness: sweetness,
                                isCustom:
                                    !isFromMenu, // false ถ้าเป็นเมนูจาก list
                                fruitIndexes: _fruits.toList(),
                                extrasIndexes: _extras.map((i) => i + 30).toList(),
                                veggieIndexes: _veggies.map((i) => i + 100).toList(),
                                herbsIndexes: _herbs.map((i) => i + 260).toList(),
                                toppingsIndexes: _toppings.toList(),
                              );
                              // snackbar แสดงชื่อเมนูจริง
                              final ingredientNames = _selectedIngredientsOrder.map((e) => e.name).join('+');
                              final displayName = ingredientNames.length > 40
                                  ? '${ingredientNames.substring(0, 37)}...'
                                  : ingredientNames;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added $displayName! 🧪',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }

                                // clear
                                setState(() {
                                  _fruits.clear();
                                  _extras.clear();
                                  _veggies.clear();
                                  _herbs.clear();
                                  _toppings.clear();
                                  _ingredientPositions.clear();
                                  _selectedIngredientsOrder.clear();
                                  _size = 'S';
                                  _sweetnessIndex = 2;
                                  _presetMenuName = null; // ✅ reset
                                  _presetMenuEmoji = null; // ✅
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEditing
                              ? Colors.green
                              : Colors.green,
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
                        // Change button text based on mode
                        child: Text(
                          isEditing ? 'Update Cart' : 'Add to Cart →',
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
