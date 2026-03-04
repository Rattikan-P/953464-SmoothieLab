// models/smoothie_item.dart

import '../data/ingredients_data.dart';

// kVeggiesData index mapping:
// 0→100=Kale, 1→101=Broccoli, 2→102=Spinach, 3→103=Cucumber, 4→104=Celery

class SmoothieItem {
  final String name;
  final String emoji;
  final double basePrice;
  final List<String> ingredients;
  final String category;
  final List<int> fruitIndexes;
  final String? badge;
  final String? description;

  const SmoothieItem({
    required this.name,
    required this.emoji,
    required this.basePrice,
    required this.ingredients,
    required this.category,
    this.fruitIndexes = const [],
    this.badge,
    this.description,
  });

  /// แยก index ตามประเภท — ใช้ส่งให้ goToLabWithPreset
  List<int> get onlyFruitIndexes => fruitIndexes.where((i) => i < 30).toList();
  List<int> get extrasIndexes =>
      fruitIndexes.where((i) => i >= 30 && i < 100).toList();
  List<int> get veggieIndexes =>
      fruitIndexes.where((i) => i >= 100 && i < 260).toList();
  List<int> get herbsIndexes => fruitIndexes.where((i) => i >= 260).toList();
}

const List<ToppingItem> kToppingItems = kToppingData;

const List<SmoothieItem> kMenuItems = [
  // ── Berry ─────────────────────────────────────────
  SmoothieItem(
    name: 'Berry Blast',
    emoji: '🍓',
    basePrice: 25, // 25+15+18
    ingredients: ['Strawberry', 'Blueberry'],
    category: 'berry',
    fruitIndexes: [0, 3],
    badge: '🔥 Best Seller',
    description: 'Strawberry + Blueberry',
  ),
  SmoothieItem(
    name: 'Pink Paradise',
    emoji: '🌸',
    basePrice: 25, // 25+15+16+15
    ingredients: ['Strawberry', 'Raspberry', 'Lychee'],
    category: 'berry',
    fruitIndexes: [0, 6, 14],
  ),
  SmoothieItem(
    name: 'Strawberry Lemon',
    emoji: '🍓',
    basePrice: 25, // 25+15+8+10
    ingredients: ['Strawberry', 'Lemon', 'Honey'],
    category: 'berry',
    fruitIndexes: [0, 13, 262],
  ),
  SmoothieItem(
    name: 'Berry Dream',
    emoji: '💜',
    basePrice: 25, // 25+18+16
    ingredients: ['Blueberry', 'Raspberry'],
    category: 'berry',
    fruitIndexes: [3, 6],
  ),
  SmoothieItem(
    name: 'Blueberry Mint',
    emoji: '🫐',
    basePrice: 25, // 25+18+5+8
    ingredients: ['Blueberry', 'Mint', 'Lemon'],
    category: 'berry',
    fruitIndexes: [3, 260, 13],
  ),
  SmoothieItem(
    name: 'Peach Fuzz',
    emoji: '🍑',
    basePrice: 25, // 25+14+14+10
    ingredients: ['Peach', 'Apricot', 'Honey'],
    category: 'berry',
    fruitIndexes: [5, 8, 262],
  ),
  SmoothieItem(
    name: 'Peach Raspberry',
    emoji: '🍑',
    basePrice: 25, // 25+14+16+8
    ingredients: ['Peach', 'Raspberry', 'Lemon'],
    category: 'berry',
    fruitIndexes: [5, 6, 13],
  ),
  SmoothieItem(
    name: 'Raspberry Mint',
    emoji: '🍓',
    basePrice: 25, // 25+16+5+8
    ingredients: ['Raspberry', 'Mint', 'Lemon'],
    category: 'berry',
    fruitIndexes: [6, 260, 13],
  ),
  SmoothieItem(
    name: 'Apricot Glow',
    emoji: '🟠',
    basePrice: 25, // 25+14+14+8
    ingredients: ['Apricot', 'Peach', 'Lime'],
    category: 'berry',
    fruitIndexes: [8, 5, 12],
  ),
  SmoothieItem(
    name: 'Watermelon Wave',
    emoji: '🍉',
    basePrice: 25, // 25+13+5+8
    ingredients: ['Watermelon', 'Mint', 'Lime'],
    category: 'berry',
    fruitIndexes: [9, 260, 12],
  ),
  SmoothieItem(
    name: 'Watermelon Frost',
    emoji: '🍉',
    basePrice: 25, // 25+13+15+5
    ingredients: ['Watermelon', 'Lychee', 'Mint'],
    category: 'berry',
    fruitIndexes: [9, 14, 260],
  ),
  SmoothieItem(
    name: 'Lychee Rose',
    emoji: '🍈',
    basePrice: 25, // 25+15+16+5
    ingredients: ['Lychee', 'Raspberry', 'Mint'],
    category: 'berry',
    fruitIndexes: [14, 6, 260],
  ),
  SmoothieItem(
    name: 'Lychee Peach',
    emoji: '🍈',
    basePrice: 25, // 25+15+14+10
    ingredients: ['Lychee', 'Peach', 'Honey'],
    category: 'berry',
    fruitIndexes: [14, 5, 262],
  ),
  SmoothieItem(
    name: 'Dragon Glow',
    emoji: '🐉',
    basePrice: 25, // 25+18+15+8
    ingredients: ['Dragon Fruit', 'Lychee', 'Lime'],
    category: 'berry',
    fruitIndexes: [15, 14, 12],
    badge: '✨ Special',
  ),
  SmoothieItem(
    name: 'Dragon Berry',
    emoji: '🐉',
    basePrice: 25, // 25+18+15+8
    ingredients: ['Dragon Fruit', 'Strawberry', 'Lemon'],
    category: 'berry',
    fruitIndexes: [15, 0, 13],
  ),

  // ── Tropical ──────────────────────────────────────
  SmoothieItem(
    name: 'Mango Tango',
    emoji: '🥭',
    basePrice: 25, // 25+12+12+8
    ingredients: ['Mango', 'Pineapple', 'Lime'],
    category: 'tropical',
    fruitIndexes: [1, 7, 12],
    badge: '⭐ Popular',
    description: 'Mango + Pineapple + Lime',
  ),
  SmoothieItem(
    name: 'Sunny Mango',
    emoji: '🌞',
    basePrice: 25, // 25+12+10+8
    ingredients: ['Mango', 'Orange', 'Lemon'],
    category: 'tropical',
    fruitIndexes: [1, 10, 13],
  ),
  SmoothieItem(
    name: 'Mango Coconut',
    emoji: '🥭',
    basePrice: 25, // 25+12+12+8
    ingredients: ['Mango', 'Coconut', 'Lime'],
    category: 'tropical',
    fruitIndexes: [1, 31, 12],
  ),
  SmoothieItem(
    name: 'Banana Boost',
    emoji: '🍌',
    basePrice: 25, // 25+8+10+8
    ingredients: ['Banana', 'Milk', 'Oat'],
    category: 'tropical',
    fruitIndexes: [2, 30, 33],
    badge: '💛 Classic',
    description: 'Banana + Milk + Oat',
  ),
  SmoothieItem(
    name: 'Honey Peach',
    emoji: '🍯',
    basePrice: 25, // 25+8+10+14
    ingredients: ['Banana', 'Honey', 'Peach'],
    category: 'tropical',
    fruitIndexes: [2, 262, 5],
  ),
  SmoothieItem(
    name: 'Banana Mango',
    emoji: '🍌',
    basePrice: 25, // 25+8+12+12
    ingredients: ['Banana', 'Mango', 'Pineapple'],
    category: 'tropical',
    fruitIndexes: [2, 1, 7],
  ),
  SmoothieItem(
    name: 'Tropical Blast',
    emoji: '🌴',
    basePrice: 25, // 25+12+12+10
    ingredients: ['Pineapple', 'Mango', 'Orange'],
    category: 'tropical',
    fruitIndexes: [7, 1, 10],
  ),
  SmoothieItem(
    name: 'Coconut Dream',
    emoji: '🥥',
    basePrice: 25, // 25+12+12+8
    ingredients: ['Pineapple', 'Coconut', 'Lime'],
    category: 'tropical',
    fruitIndexes: [7, 31, 12],
  ),
  SmoothieItem(
    name: 'Pineapple Ginger',
    emoji: '🍍',
    basePrice: 25, // 25+12+5+8
    ingredients: ['Pineapple', 'Ginger', 'Lime'],
    category: 'tropical',
    fruitIndexes: [7, 261, 12],
  ),
  SmoothieItem(
    name: 'Citrus Burst',
    emoji: '🍊',
    basePrice: 25, // 25+10+8+8
    ingredients: ['Orange', 'Lemon', 'Lime'],
    category: 'tropical',
    fruitIndexes: [10, 13, 12],
  ),
  SmoothieItem(
    name: 'Orange Mango',
    emoji: '🍊',
    basePrice: 25, // 25+10+12+5
    ingredients: ['Orange', 'Mango', 'Ginger'],
    category: 'tropical',
    fruitIndexes: [10, 1, 261],
  ),
  SmoothieItem(
    name: 'Coconut Banana',
    emoji: '🥥',
    basePrice: 25, // 25+12+8+10
    ingredients: ['Coconut', 'Banana', 'Honey'],
    category: 'tropical',
    fruitIndexes: [31, 2, 262],
  ),
  SmoothieItem(
    name: 'Choco Dream',
    emoji: '🍫',
    basePrice: 25, // 25+12+10+10
    ingredients: ['Chocolate', 'Cocoa', 'Milk'],
    category: 'tropical',
    fruitIndexes: [34, 35, 30],
  ),

  // ── Green ─────────────────────────────────────────
  SmoothieItem(
    name: 'Green Power',
    emoji: '💚',
    basePrice: 25, // 25+10(Spinach=102)+12+5+8
    ingredients: ['Spinach', 'Apple', 'Ginger', 'Lime'],
    category: 'green',
    fruitIndexes: [102, 11, 261, 12],
    badge: '💚 Healthy',
    description: 'Spinach + Apple + Ginger',
  ),
  SmoothieItem(
    name: 'Spinach Lemon',
    emoji: '🥬',
    basePrice: 25, // 25+10(Spinach=102)+8+12
    ingredients: ['Spinach', 'Lemon', 'Apple'],
    category: 'green',
    fruitIndexes: [102, 13, 11],
  ),
  SmoothieItem(
    name: 'Kale Kick',
    emoji: '🥬',
    basePrice: 25, // 25+10(Kale=100)+12+8+5
    ingredients: ['Kale', 'Apple', 'Lime', 'Ginger'],
    category: 'green',
    fruitIndexes: [100, 11, 12, 261],
  ),
  SmoothieItem(
    name: 'Broccoli Boost',
    emoji: '🥦',
    basePrice: 25, // 25+12(Broccoli=101)+15+8
    ingredients: ['Broccoli', 'Kiwi', 'Lemon'],
    category: 'green',
    fruitIndexes: [101, 4, 13],
  ),
  SmoothieItem(
    name: 'Green Go',
    emoji: '🥝',
    basePrice: 25, // 25+15+8(Cucumber=103)
    ingredients: ['Kiwi', 'Cucumber'],
    category: 'green',
    fruitIndexes: [4, 103],
  ),
  SmoothieItem(
    name: 'Kiwi Lemonade',
    emoji: '🍋',
    basePrice: 25, // 25+15+12+8
    ingredients: ['Kiwi', 'Apple', 'Lemon'],
    category: 'green',
    fruitIndexes: [4, 11, 13],
  ),
  SmoothieItem(
    name: 'Kiwi Mint',
    emoji: '🥝',
    basePrice: 25, // 25+15+5+8
    ingredients: ['Kiwi', 'Mint', 'Lime'],
    category: 'green',
    fruitIndexes: [4, 260, 12],
  ),
  SmoothieItem(
    name: 'Detox Green',
    emoji: '🥒',
    basePrice: 25, // 25+10(Celery=104)+8(Cucumber=103)+15+8
    ingredients: ['Celery', 'Cucumber', 'Kiwi', 'Lemon'],
    category: 'green',
    fruitIndexes: [104, 103, 4, 13],
  ),
  SmoothieItem(
    name: 'Cucumber Mint',
    emoji: '🥒',
    basePrice: 25, // 25+8(Cucumber=103)+5+8
    ingredients: ['Cucumber', 'Mint', 'Lime'],
    category: 'green',
    fruitIndexes: [103, 260, 12],
  ),
  SmoothieItem(
    name: 'Apple Ginger',
    emoji: '🍏',
    basePrice: 25, // 25+12+5+8
    ingredients: ['Apple', 'Ginger', 'Lemon'],
    category: 'green',
    fruitIndexes: [11, 261, 13],
  ),
  SmoothieItem(
    name: 'Apple Mint',
    emoji: '🍏',
    basePrice: 25, // 25+12+5+8
    ingredients: ['Apple', 'Mint', 'Lime'],
    category: 'green',
    fruitIndexes: [11, 260, 12],
  ),
  SmoothieItem(
    name: 'Celery Boost',
    emoji: '🥬',
    basePrice: 25, // 25+10(Celery=104)+12+5+8
    ingredients: ['Celery', 'Apple', 'Ginger', 'Lemon'],
    category: 'green',
    fruitIndexes: [104, 11, 261, 13],
  ),
];

const Map<String, double> kSizeUpgrade = {'S': 0, 'M': 7, 'L': 15};
const Map<String, String> kSizeLabel = {
  'S': '350 ml',
  'M': '500 ml',
  'L': '700 ml',
};
