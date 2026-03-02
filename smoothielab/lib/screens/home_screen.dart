import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/smoothie_item.dart';
import '../providers/navigation_provider.dart';
import '../widgets/floating_cart_button.dart';

class _PresetRecipe {
  final String name;
  final String emoji;
  final String description;
  final double price;
  final List<int> fruitIndexes;
  final String badge;
  final String menuName;
  final String menuEmoji;

  const _PresetRecipe({
    required this.name,
    required this.emoji,
    required this.description,
    required this.price,
    required this.fruitIndexes,
    required this.badge,
    required this.menuName,
    required this.menuEmoji,
  });
}

const _presets = [
  _PresetRecipe(
    name: 'Tropical Blast',
    emoji: '🌴',
    description: 'สไตล์แบบทรอปิคอล',
    price: 100,
    fruitIndexes: [1, 2],
    badge: '4 วัตถุดิบ',
    menuName: 'Tropical Blast',
    menuEmoji: '🌴', // ✅
  ),
  _PresetRecipe(
    name: 'Berry Dream',
    emoji: '💜',
    description: 'หวานอมเปรี้ยว',
    price: 90,
    fruitIndexes: [0, 3],
    badge: '4 วัตถุดิบ',
    menuName: 'Berry Dream',
    menuEmoji: '💜', // ✅
  ),
  _PresetRecipe(
    name: 'Green Power',
    emoji: '💚',
    description: 'พลังจากธรรมชาติ',
    price: 100,
    fruitIndexes: [4, 5],
    badge: '5 วัตถุดิบ',
    menuName: 'Green Power',
    menuEmoji: '💚', // ✅
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'all';

  List<SmoothieItem> get _filtered {
    if (_filter == 'all') return kMenuItems;
    return kMenuItems.where((m) => m.category == _filter).toList();
  }

  // helper ใช้ Provider แทน callback
  // ✅ รับ SmoothieItem แทน List<int>
  void _goToLab(SmoothieItem item) {
    context.read<NavigationProvider>().goToLabWithPreset(
      item.fruitIndexes,
      menuName: item.name,
      menuEmoji: item.emoji,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: const Color(0xFFF8F8F8),
              elevation: 0,
              title: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: 'Smoothie'),
                    TextSpan(
                      text: 'Lab',
                      style: TextStyle(color: Color(0xFF4CAF50)),
                    ),
                  ],
                ),
              ),
              actions: const [CartIconButton()],
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Text(
                  'สวัสดี, พอย 👋',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),

            // ── Formula of the Day ────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '// FORMULA OF THE DAY',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Mango',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Tango',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'mango + pineapple + lime',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => context
                                  .read<NavigationProvider>()
                                  .goToLabWithPreset(
                                    [1],
                                    menuName: 'Mango Tango',
                                    menuEmoji: '🥭',
                                  ),
                              icon: const Text('🧪'),
                              label: const Text('ดูสูตร'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text('🥭', style: TextStyle(fontSize: 60)),
                    ],
                  ),
                ),
              ),
            ),

            // ── Filter Chips ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final f in [
                      ('all', 'ALL', ''),
                      ('berry', 'BERRY', '🍓'),
                      ('tropical', 'TROPICAL', '🥭'),
                      ('green', 'GREEN', '🥝'),
                    ])
                      ChoiceChip(
                        label: Text('${f.$3} ${f.$2}'),
                        selected: _filter == f.$1,
                        onSelected: (_) => setState(() => _filter = f.$1),
                        selectedColor: const Color(0xFF4CAF50),
                        labelStyle: TextStyle(
                          color: _filter == f.$1 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── สูตรยอดนิยม ───────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'สูตรยอดนิยม',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'SEE ALL →',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _presets.length,
                  itemBuilder: (_, i) {
                    final p = _presets[i];
                    return GestureDetector(
                      onTap: () =>
                          context.read<NavigationProvider>().goToLabWithPreset(
                            p.fruitIndexes,
                            menuName: p.menuName,
                            menuEmoji: p.menuEmoji,
                          ),
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.emoji, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 6),
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              p.description,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '฿${p.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFFFF6B35),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              p.badge,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── เมนูทั้งหมด ───────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'เมนูทั้งหมด',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _MenuCard(
                    item: _filtered[i],
                    onTap: () => _goToLab(_filtered[i]),
                  ),
                  childCount: _filtered.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenW > 600 ? 3 : 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final SmoothieItem item;
  final VoidCallback onTap;
  const _MenuCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              item.ingredients.join(' + '),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 2,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '฿${item.basePrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
