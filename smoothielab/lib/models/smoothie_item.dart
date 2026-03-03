// models/smoothie_item.dart

import '../data/ingredients_data.dart';

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
}

// Export kToppingData from ingredients_data.dart
const List<ToppingItem> kToppingItems = kToppingData;

const List<SmoothieItem> kMenuItems = [
  SmoothieItem(
    name: 'Berry Blast',
    emoji: '🍓',
    basePrice: 25,
    ingredients: ['Strawberry', 'Blueberry'],
    category: 'berry',
    fruitIndexes: [0, 3],
    badge: '🔥 Best Seller',
    description: 'Strawberry + Blueberry',
  ),
  SmoothieItem(
    name: 'Mango Tango',
    emoji: '🥭',
    basePrice: 25,
    ingredients: ['Mango', 'Pineapple', 'Lime'],
    category: 'tropical',
    fruitIndexes: [1, 7, 12],
    badge: '⭐ Popular',
    description: 'Mango + Pineapple + Lime',
  ),
  SmoothieItem(
    name: 'Green Power',
    emoji: '💚',
    basePrice: 25,
    ingredients: ['Spinach', 'Apple', 'Ginger', 'Lime'],
    category: 'green',
    fruitIndexes: [100, 11, 261, 12], // Spinach(100+veggie), Apple(11), Ginger(261+herb), Lime(12)
    badge: '💚 Healthy',
    description: 'Spinach + Apple + Ginger + Lime',
  ),
  SmoothieItem(
    name: 'Banana Boost',
    emoji: '🍌',
    basePrice: 25,
    ingredients: ['Banana', 'Milk', 'Oat'],
    category: 'tropical',
    fruitIndexes: [2, 30, 33], // Banana(2), Milk(0 extra+30), Oat(3 extra+30)
    badge: '💛 Classic',
    description: 'Banana + Milk + Oat',
  ),
  SmoothieItem(
    name: 'Peach Fuzz',
    emoji: '🍑',
    basePrice: 25,
    ingredients: ['Peach', 'Apricot', 'Honey'],
    category: 'berry',
    fruitIndexes: [5, 8, 262], // Peach(5), Apricot(8), Honey(262+herb)
  ),
  SmoothieItem(
    name: 'Watermelon Wave',
    emoji: '🍉',
    basePrice: 25,
    ingredients: ['Watermelon', 'Mint', 'Lime'],
    category: 'berry',
    fruitIndexes: [9, 260, 12], // Watermelon(9), Mint(260+herb), Lime(12)
  ),
  SmoothieItem(
    name: 'Detox Green',
    emoji: '🥒',
    basePrice: 25,
    ingredients: ['Celery', 'Cucumber', 'Kiwi', 'Lemon'],
    category: 'green',
    fruitIndexes: [103, 102, 4, 13], // Celery(103+veggie), Cucumber(102+veggie), Kiwi(4), Lemon(13)
  ),
  SmoothieItem(
    name: 'Green Go',
    emoji: '🥝',
    basePrice: 25,
    ingredients: ['Kiwi', 'Cucumber'],
    category: 'green',
    fruitIndexes: [4, 102], // Kiwi(4), Cucumber(102+veggie)
  ),
  SmoothieItem(
    name: 'Choco Dream',
    emoji: '🍫',
    basePrice: 25,
    ingredients: ['Chocolate', 'Cocoa', 'Milk'],
    category: 'green',
    fruitIndexes: [34, 35, 30], // Chocolate(4 extra+30), Cocoa(5 extra+30), Milk(0 extra+30)
  ),
  SmoothieItem(
    name: 'Tropical Blast',
    emoji: '🌴',
    basePrice: 25,
    ingredients: ['Pineapple', 'Mango', 'Orange'],
    category: 'tropical',
    fruitIndexes: [7, 1, 10],
  ),
  SmoothieItem(
    name: 'Berry Dream',
    emoji: '💜',
    basePrice: 25,
    ingredients: ['Blueberry', 'Raspberry'],
    category: 'berry',
    fruitIndexes: [3, 6],
  ),
];

const Map<String, double> kSizeUpgrade = {'S': 0, 'M': 7, 'L': 15};
const Map<String, String> kSizeLabel = {
  'S': '350 ml',
  'M': '500 ml',
  'L': '700 ml',
};
