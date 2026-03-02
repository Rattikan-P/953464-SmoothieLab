class SmoothieItem {
  final String name;
  final String emoji;
  final double basePrice;
  final List<String> ingredients;
  final String category;
  final List<int> fruitIndexes; // ✅ เพิ่ม

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
  const ToppingItem({required this.name, required this.emoji, required this.price});
}

// fruitIndexes อ้างอิงตาม _fruitsData ใน LabScreen:
// 0=สตรอว์เบอร์รี่, 1=มะม่วง, 2=กล้วย, 3=บลูเบอร์รี่, 4=กีวี, 5=พีช
const List<SmoothieItem> kMenuItems = [
  SmoothieItem(name: 'Berry Blast',    emoji: '🍓', basePrice: 55, ingredients: ['สตรอว์เบอร์รี่', 'บลูเบอร์รี่'],        category: 'berry',    fruitIndexes: [0, 3]),
  SmoothieItem(name: 'Green Go',       emoji: '🥝', basePrice: 60, ingredients: ['กีวี', 'แตงกวา'],                        category: 'green',    fruitIndexes: [4]),
  SmoothieItem(name: 'Mango Tango',    emoji: '🥭', basePrice: 55, ingredients: ['มะม่วง', 'สับปะรด', 'มะนาว'],           category: 'tropical', fruitIndexes: [1]),
  SmoothieItem(name: 'Peach Fuzz',     emoji: '🍑', basePrice: 58, ingredients: ['พีช', 'แอปริคอท'],                      category: 'berry',    fruitIndexes: [5]),
  SmoothieItem(name: 'Banana Boost',   emoji: '🍌', basePrice: 50, ingredients: ['กล้วย', 'นม'],                           category: 'tropical', fruitIndexes: [2]),
  SmoothieItem(name: 'Choco Dream',    emoji: '🍫', basePrice: 65, ingredients: ['ช็อกโกแลต', 'โกโก้', 'นม'],            category: 'green',    fruitIndexes: []),
  SmoothieItem(name: 'Tropical Blast', emoji: '🌴', basePrice: 62, ingredients: ['สับปะรด', 'มะม่วง', 'ส้ม'],            category: 'tropical', fruitIndexes: [1, 2]),
  SmoothieItem(name: 'Berry Dream',    emoji: '💜', basePrice: 60, ingredients: ['บลูเบอร์รี่', 'ราสพ์เบอร์รี่'],        category: 'berry',    fruitIndexes: [0, 3]),
  SmoothieItem(name: 'Green Power',    emoji: '💚', basePrice: 65, ingredients: ['ผักโขม', 'แอปเปิ้ล', 'ขิง', 'มะนาว'], category: 'green',    fruitIndexes: [4, 5]),
];

const List<ToppingItem> kToppingItems = [
  ToppingItem(name: 'โยเกิร์ต',     emoji: '🥛', price: 15),
  ToppingItem(name: 'เจลลี่',        emoji: '🍮', price: 10),
  ToppingItem(name: 'ไข่มุก',        emoji: '⚫', price: 15),
  ToppingItem(name: 'วิปครีม',       emoji: '🍦', price: 15),
  ToppingItem(name: 'เมล็ดเชีย',     emoji: '🌱', price: 12),
  ToppingItem(name: 'กราโนล่า',      emoji: '🌾', price: 12),
  ToppingItem(name: 'น้ำผึ้ง',       emoji: '🍯', price: 10),
  ToppingItem(name: 'ถั่วอัลมอนด์', emoji: '🥜', price: 15),
];

const Map<String, double> kSizeMultiplier = {'S': 1.0, 'M': 1.3, 'L': 1.6};
const Map<String, String>  kSizeLabel      = {'S': '350 ml', 'M': '500 ml', 'L': '700 ml'};