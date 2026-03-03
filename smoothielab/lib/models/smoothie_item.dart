// models/smoothie_item.dart

class SmoothieItem {
  final String name;
  final String emoji;
  final double basePrice;
  final List<String> ingredients;
  final String category;
  final List<int> fruitIndexes;

  const SmoothieItem({
    required this.name,
    required this.emoji,
    required this.basePrice,
    required this.ingredients,
    required this.category,
    this.fruitIndexes = const [],
  });
}

class ToppingItem {
  final String name;
  final String emoji;
  final double price;
  const ToppingItem({
    required this.name,
    required this.emoji,
    required this.price,
  });
}

const List<SmoothieItem> kMenuItems = [
  SmoothieItem(
    name: 'Berry Blast',
    emoji: '🍓',
    basePrice: 55,
    ingredients: ['Strawberry', 'Blueberry'],
    category: 'berry',
    fruitIndexes: [0, 3],
  ),
  SmoothieItem(
    name: 'Mango Tango',
    emoji: '🥭',
    basePrice: 55,
    ingredients: ['Mango', 'Pineapple', 'Lime'],
    category: 'tropical',
    fruitIndexes: [1],
  ),
  SmoothieItem(
    name: 'Peach Fuzz',
    emoji: '🍑',
    basePrice: 58,
    ingredients: ['Peach', 'Apricot', 'Honey'],
    category: 'berry',
    fruitIndexes: [5],
  ),
  SmoothieItem(
    name: 'Banana Boost',
    emoji: '🍌',
    basePrice: 50,
    ingredients: ['Banana', 'Milk', 'Oat'],
    category: 'tropical',
    fruitIndexes: [2],
  ),
  SmoothieItem(
    name: 'Watermelon Wave',
    emoji: '🍉',
    basePrice: 52,
    ingredients: ['Watermelon', 'Mint', 'Lime'],
    category: 'berry',
    fruitIndexes: [6],
  ),
  SmoothieItem(
    name: 'Detox Green',
    emoji: '🥒',
    basePrice: 68,
    ingredients: ['Celery', 'Cucumber', 'Kiwi', 'Lemon'],
    category: 'green',
    fruitIndexes: [4],
  ),
  SmoothieItem(
    name: 'Green Go',
    emoji: '🥝',
    basePrice: 60,
    ingredients: ['Kiwi', 'Cucumber'],
    category: 'green',
    fruitIndexes: [4],
  ),
  SmoothieItem(
    name: 'Choco Dream',
    emoji: '🍫',
    basePrice: 65,
    ingredients: ['Chocolate', 'Cocoa', 'Milk'],
    category: 'green',
    fruitIndexes: [],
  ),
  SmoothieItem(
    name: 'Tropical Blast',
    emoji: '🌴',
    basePrice: 62,
    ingredients: ['Pineapple', 'Mango', 'Orange'],
    category: 'tropical',
    fruitIndexes: [1],
  ),
  SmoothieItem(
    name: 'Berry Dream',
    emoji: '💜',
    basePrice: 60,
    ingredients: ['Blueberry', 'Raspberry'],
    category: 'berry',
    fruitIndexes: [0, 3],
  ),
  SmoothieItem(
    name: 'Green Power',
    emoji: '💚',
    basePrice: 65,
    ingredients: ['Spinach', 'Apple', 'Ginger', 'Lime'],
    category: 'green',
    fruitIndexes: [4],
  ),
];

const List<ToppingItem> kToppingItems = [
  ToppingItem(name: 'Yogurt', emoji: '🥛', price: 15),
  ToppingItem(name: 'Jelly', emoji: '🍮', price: 10),
  ToppingItem(name: 'Tapioca Pearl', emoji: '⚫', price: 15),
  ToppingItem(name: 'Whipped Cream', emoji: '🍦', price: 15),
  ToppingItem(name: 'Chia Seeds', emoji: '🌱', price: 12),
  ToppingItem(name: 'Granola', emoji: '🌾', price: 12),
  ToppingItem(name: 'Honey', emoji: '🍯', price: 10),
  ToppingItem(name: 'Almond', emoji: '🥜', price: 15),
];

const Map<String, double> kSizeMultiplier = {'S': 1.0, 'M': 1.3, 'L': 1.6};
const Map<String, String> kSizeLabel = {
  'S': '350 ml',
  'M': '500 ml',
  'L': '700 ml',
};
