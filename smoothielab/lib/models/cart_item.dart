import 'smoothie_item.dart';

class CartItem {
  final SmoothieItem smoothie;
  String size;
  List<ToppingItem> toppings;
  String sweetness;
  int quantity;

  CartItem({
    required this.smoothie,
    this.size = 'M',
    List<ToppingItem>? toppings,
    this.sweetness = 'หวานปกติ',
    this.quantity = 1,
  }) : toppings = toppings ?? [];

  double get itemPrice {
    double base = smoothie.basePrice * kSizeMultiplier[size]!;
    double toppingTotal = toppings.fold(0, (sum, t) => sum + t.price);
    return (base + toppingTotal) * quantity;
  }
}