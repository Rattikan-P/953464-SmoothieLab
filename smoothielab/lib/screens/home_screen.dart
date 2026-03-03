import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/smoothie_item.dart';
import '../providers/navigation_provider.dart';
import '../widgets/floating_cart_button.dart';
import '../widgets/smoothie_cup_widget.dart';

// ── Logo ──────────────────────────────────────────────
class SmoothieLabLogo extends StatelessWidget {
  final double height;
  const SmoothieLabLogo({super.key, this.height = 36});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: Image.asset(
            'assets/image/smoothielabwithoutbg.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: height * 0.5,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: const [
              TextSpan(text: 'Smoothie '),
              TextSpan(
                text: 'Lab',
                style: TextStyle(color: Color(0xFF2E7D32)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Preset data ───────────────────────────────────────
class _Preset {
  final String name, description, badge;
  final double price;
  final List<int> fruitIndexes;
  final Color cupColor;
  final List<String> fruits;
  const _Preset({
    required this.name,
    required this.description,
    required this.price,
    required this.fruitIndexes,
    required this.badge,
    required this.cupColor,
    required this.fruits,
  });
}

const List<_Preset> _presets = [
  _Preset(
    name: 'Berry Blast',
    description: 'Strawberry + Blueberry',
    price: 55,
    fruitIndexes: [0, 3],
    badge: '🔥 Best Seller',
    cupColor: Color(0xFFE91E8C),
    fruits: ['🍓', '🫐'],
  ),
  _Preset(
    name: 'Mango Tango',
    description: 'Mango + Pineapple',
    price: 55,
    fruitIndexes: [1],
    badge: '⭐ Popular',
    cupColor: Color(0xFFFFB347),
    fruits: ['🥭', '🍍', '🍋'],
  ),
  _Preset(
    name: 'Green Power',
    description: 'Spinach + Apple + Ginger',
    price: 65,
    fruitIndexes: [4, 5],
    badge: '💚 Healthy',
    cupColor: Color(0xFF66BB6A),
    fruits: ['🥬', '🍏'],
  ),
  _Preset(
    name: 'Banana Boost',
    description: 'Banana + Milk',
    price: 50,
    fruitIndexes: [2],
    badge: '💛 Classic',
    cupColor: Color(0xFFFFD54F),
    fruits: ['🍌', '🥛'],
  ),
];

// ── Home Screen ───────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _filter = 'all';
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;

  List<SmoothieItem> get _filtered => _filter == 'all'
      ? kMenuItems
      : kMenuItems.where((m) => m.category == _filter).toList();

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  void _goToLab(SmoothieItem item) {
    HapticFeedback.lightImpact();
    context.read<NavigationProvider>().goToLabWithPreset(
      item.fruitIndexes,
      menuName: item.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: SafeArea(
        child: FadeTransition(
          opacity: _headerFade,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── AppBar ─────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                forceElevated: true,
                shadowColor: Colors.black.withOpacity(0.08),
                surfaceTintColor: Colors.transparent,
                centerTitle: false,
                titleSpacing: 20,
                title: const SmoothieLabLogo(height: 36),
                actions: const [
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: CartIconButton(),
                  ),
                ],
              ),

              // ── Formula Banner ─────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _FormulaBanner(),
                ),
              ),

              // ── Section: Popular Recipes ───────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: _SectionHeader(title: 'Popular Recipes', emoji: ''),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _presets.length,
                    itemBuilder: (_, i) =>
                        _PopularCard(preset: _presets[i], index: i),
                  ),
                ),
              ),

              // ── Section: Filter ────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      const Spacer(),
                      // filter chips compact
                      ...[
                        ('all', 'All'),
                        ('berry', '🍓'),
                        ('tropical', '🥭'),
                        ('green', '🥬'),
                      ].map(
                        (f) => _FilterPill(
                          label: f.$2,
                          selected: _filter == f.$1,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _filter = f.$1);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Grid: All Menu ─────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _MenuCard(
                      item: _filtered[i],
                      index: i,
                      onTap: () => _goToLab(_filtered[i]),
                    ),
                    childCount: _filtered.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenW > 600 ? 3 : 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: 210,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title, emoji;
  const _SectionHeader({required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ── Filter Pill ───────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2E7D32) : Colors.white,
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}

// ── Popular Card ──────────────────────────────────────
class _PopularCard extends StatefulWidget {
  final _Preset preset;
  final int index;
  const _PopularCard({required this.preset, required this.index});
  @override
  State<_PopularCard> createState() => _PopularCardState();
}

class _PopularCardState extends State<_PopularCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.preset;
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        context.read<NavigationProvider>().goToLabWithPreset(
          p.fruitIndexes,
          menuName: p.name,
        );
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 148,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: p.cupColor.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // cup area with colored bg
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: p.cupColor.withOpacity(0.08),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Center(
                  child: SmoothieCupWidget(
                    cupColor: p.cupColor,
                    fruits: p.fruits,
                    size: 76,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.description,
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '฿${p.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFFFF6B35),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: p.cupColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.badge,
                            style: TextStyle(
                              fontSize: 8,
                              color: p.cupColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Formula Banner ────────────────────────────────────
class _FormulaBanner extends StatefulWidget {
  const _FormulaBanner();
  @override
  State<_FormulaBanner> createState() => _FormulaBannerState();
}

class _FormulaBannerState extends State<_FormulaBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pop;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pop = Tween<double>(
      begin: 1.0,
      end: 1.07,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.read<NavigationProvider>().goToLabWithPreset([
          1,
        ], menuName: 'Mango Tango');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 111, 163, 114),
                Color(0xFF66BB6A),
                Color(0xFF66BB6A),
                Color.fromARGB(255, 111, 163, 114),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // decorative circles
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: 60,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF69F0AE),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'FORMULA OF THE DAY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Mango',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                              letterSpacing: -1,
                            ),
                          ),
                          const Text(
                            'Tango',
                            style: TextStyle(
                              color: Color(0xFF69F0AE),
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: ['🥭 Mango', '🍍 Pineapple', '🍋 Lime']
                                .map(
                                  (ing) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      ing,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          // CTA
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.science_rounded,
                                  size: 14,
                                  color: Color(0xFF2E7D32),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'View Recipes',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 12,
                                  color: Color(0xFF2E7D32),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _pop,
                      builder: (_, child) =>
                          Transform.scale(scale: _pop.value, child: child),
                      child: const SmoothieCupWidget(
                        cupColor: Color(0xFFFFB347),
                        fruits: ['🥭', '🍍', '🍋'],
                        size: 112,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Menu Card ─────────────────────────────────────────
class _MenuCard extends StatefulWidget {
  final SmoothieItem item;
  final VoidCallback onTap;
  final int index;
  const _MenuCard({
    required this.item,
    required this.onTap,
    required this.index,
  });
  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  static const Map<String, String> _emojiMap = {
    'strawberry': '🍓',
    'blueberry': '🫐',
    'raspberry': '🍓',
    'mango': '🥭',
    'pineapple': '🍍',
    'lime': '🍋',
    'lemon': '🍋',
    'banana': '🍌',
    'milk': '🥛',
    'oat': '🌾',
    'orange': '🍊',
    'kiwi': '🥝',
    'cucumber': '🥒',
    'spinach': '🥬',
    'apple': '🍏',
    'ginger': '🫚',
    'peach': '🍑',
    'apricot': '🍑',
    'honey': '🍯',
    'lychee': '🍈',
    'coconut': '🥥',
    'watermelon': '🍉',
    'mint': '🌿',
    'celery': '🥬',
    'carrot': '🥕',
  };

  static const Map<String, Color> _colorMap = {
    'strawberry': Color(0xFFE91E8C),
    'blueberry': Color(0xFF5C6BC0),
    'raspberry': Color(0xFFE91E8C),
    'mango': Color(0xFFFFB347),
    'pineapple': Color(0xFFFFCA28),
    'banana': Color(0xFFFFD54F),
    'orange': Color(0xFFFF7043),
    'kiwi': Color(0xFF66BB6A),
    'spinach': Color(0xFF43A047),
    'apple': Color(0xFF66BB6A),
    'peach': Color(0xFFFFAB91),
    'apricot': Color(0xFFFFAB91),
    'dragon fruit': Color(0xFFCE93D8),
    'watermelon': Color(0xFFEF5350),
    'passion fruit': Color(0xFFAB47BC),
    'celery': Color(0xFF81C784),
    'cucumber': Color(0xFF81C784),
    'lychee': Color(0xFFFF80AB),
  };

  static List<String> _fruitsFor(List<String> ings) {
    final e = <String>[];
    for (final i in ings) {
      final emoji = _emojiMap[i.toLowerCase()];
      if (emoji != null && !e.contains(emoji)) e.add(emoji);
      if (e.length >= 3) break;
    }
    return e.isEmpty ? ['🍓'] : e;
  }

  static Color _colorFor(List<String> ings) {
    for (final i in ings) {
      final c = _colorMap[i.toLowerCase()];
      if (c != null) return c;
    }
    return const Color(0xFF4CAF50);
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(widget.item.ingredients);
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── top: cup on tinted bg ──
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Center(
                    child: SmoothieCupWidget(
                      cupColor: color,
                      fruits: _fruitsFor(widget.item.ingredients),
                      size: 72,
                    ),
                  ),
                ),
              ),
              // ── bottom: info ──
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.item.ingredients.take(5).join(' · '),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF999999),
                        ),
                        maxLines: 1,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '฿${widget.item.basePrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFFF6B35),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withOpacity(0.7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 16,
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
        ),
      ),
    );
  }
}
