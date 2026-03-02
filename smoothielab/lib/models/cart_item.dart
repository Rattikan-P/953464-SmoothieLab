import 'smoothie_item.dart';

class CartItem {
  final SmoothieItem smoothie;
  String size;
  List<ToppingItem> toppings;
  String sweetness;
  int quantity;
  final bool isCustom;
  final List<int> fruitIndexes;
  final List<int> extrasIndexes;
  final List<int> veggieIndexes;

  CartItem({
    required this.smoothie,
    this.size = 'M',
    List<ToppingItem>? toppings,
    this.sweetness = 'หวานปกติ',
    this.quantity = 1,
    this.isCustom = false,
    List<int>? fruitIndexes,
    List<int>? extrasIndexes,
    List<int>? veggieIndexes,
  })  : toppings = toppings ?? [],
        fruitIndexes = fruitIndexes ?? [],
        extrasIndexes = extrasIndexes ?? [],
        veggieIndexes = veggieIndexes ?? [];

  String get displayName {
    if (!isCustom) return smoothie.name;
    return smoothie.ingredients.join(' + ');
  }

  double get itemPrice {
    double base = smoothie.basePrice * kSizeMultiplier[size]!;
    double toppingTotal = toppings.fold(0, (sum, t) => sum + t.price);
    return (base + toppingTotal) * quantity;
  }
}