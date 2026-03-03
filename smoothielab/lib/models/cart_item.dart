import 'smoothie_item.dart';
import '../data/ingredients_data.dart';

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
  final List<int> herbsIndexes;
  final List<int> toppingsIndexes;

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
    List<int>? herbsIndexes,
    List<int>? toppingsIndexes,
  }) : toppings = toppings ?? [],
       fruitIndexes = fruitIndexes ?? [],
       extrasIndexes = extrasIndexes ?? [],
       veggieIndexes = veggieIndexes ?? [],
       herbsIndexes = herbsIndexes ?? [],
       toppingsIndexes = toppingsIndexes ?? [];

  String get displayName {
    if (!isCustom) return smoothie.name;

    // สร้างชื่อจาก ingredients ที่เลือกจริงๆ
    final names = <String>[];

    // ผลไม้
    for (final i in fruitIndexes) {
      if (i >= 0 && i < kFruitsData.length) {
        names.add(kFruitsData[i].$2);
      }
    }

    // Extras
    for (final i in extrasIndexes) {
      final adjustedIndex = i - 30;
      if (adjustedIndex >= 0 && adjustedIndex < kExtrasData.length) {
        names.add(kExtrasData[adjustedIndex].$2);
      }
    }

    // ผัก
    for (final i in veggieIndexes) {
      final adjustedIndex = i - 100;
      if (adjustedIndex >= 0 && adjustedIndex < kVeggiesData.length) {
        names.add(kVeggiesData[adjustedIndex].$2);
      }
    }

    // สมุนไพร
    for (final i in herbsIndexes) {
      final adjustedIndex = i - 260;
      if (adjustedIndex >= 0 && adjustedIndex < kHerbsData.length) {
        names.add(kHerbsData[adjustedIndex].$2);
      }
    }

    return names.isEmpty ? 'Custom Smoothie' : names.join(' + ');
  }

  double get itemPrice {
    double base = smoothie.basePrice + kSizeUpgrade[size]!;
    double toppingTotal = toppings.fold(0, (sum, t) => sum + t.price);
    return (base + toppingTotal) * quantity;
  }
}
