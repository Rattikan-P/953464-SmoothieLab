import 'package:hive/hive.dart';
import 'smoothie_item.dart';
import '../data/ingredients_data.dart';

part 'cart_item.g.dart';

@HiveType(typeId: 1)
class CartItem extends HiveObject {
  @HiveField(0)
  late String menuName;

  @HiveField(1)
  late String menuEmoji;

  @HiveField(2)
  late double basePrice;

  @HiveField(3)
  String size;

  @HiveField(4)
  List<String> toppingNames;

  @HiveField(5)
  String sweetness;

  @HiveField(6)
  int quantity;

  @HiveField(7)
  bool isCustom;

  @HiveField(8)
  List<int> fruitIndexes;

  @HiveField(9)
  List<int> extrasIndexes;

  @HiveField(10)
  List<int> veggieIndexes;

  @HiveField(11)
  List<int> herbsIndexes;

  @HiveField(12)
  List<int> toppingsIndexes;

  // Default constructor for Hive (all fields optional with defaults)
  CartItem({
    this.size = 'M',
    this.toppingNames = const [],
    this.sweetness = 'หวานปกติ',
    this.quantity = 1,
    this.isCustom = false,
    this.fruitIndexes = const [],
    this.extrasIndexes = const [],
    this.veggieIndexes = const [],
    this.herbsIndexes = const [],
    this.toppingsIndexes = const [],
  });

  // Factory constructor for creating CartItem from SmoothieItem
  factory CartItem.fromSmoothie(
    SmoothieItem smoothie, {
    String size = 'M',
    List<ToppingItem>? toppings,
    String sweetness = 'หวานปกติ',
    bool isCustom = false,
    List<int>? fruitIndexes,
    List<int>? extrasIndexes,
    List<int>? veggieIndexes,
    List<int>? herbsIndexes,
    List<int>? toppingsIndexes,
  }) {
    return CartItem()
      ..menuName = smoothie.name
      ..menuEmoji = smoothie.emoji
      ..basePrice = smoothie.basePrice
      ..size = size
      ..toppingNames = toppings?.map((t) => t.name).toList() ?? []
      ..sweetness = sweetness
      ..quantity = 1
      ..isCustom = isCustom
      ..fruitIndexes = fruitIndexes ?? smoothie.fruitIndexes
      ..extrasIndexes = extrasIndexes ?? smoothie.extrasIndexes
      ..veggieIndexes = veggieIndexes ?? smoothie.veggieIndexes
      ..herbsIndexes = herbsIndexes ?? smoothie.herbsIndexes
      ..toppingsIndexes = toppingsIndexes ?? [];
  }

  // Get SmoothieItem from menuName
  SmoothieItem get smoothie {
    final found = kMenuItems.firstWhere(
      (item) => item.name == menuName,
      orElse: () => kMenuItems.first, // Fallback to first item
    );
    return found;
  }

  // Get ToppingItem list from topping names
  List<ToppingItem> get toppings {
    return toppingNames
        .map((name) => kToppingData.firstWhere(
              (t) => t.name == name,
              orElse: () => kToppingData.first,
            ))
        .toList();
  }

  String get displayName {
    // สร้างชื่อจาก ingredient indexes เสมอ (ไม่ว่าจะ preset หรือ custom)
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

    final fullName = names.isEmpty ? 'Custom Smoothie' : names.join(' + ');

    // ถ้าชื่อเกิน 40 ตัวอักษร ให้ตัดแล้วใส่ ...
    if (fullName.length > 40) {
      return '${fullName.substring(0, 37)}...';
    }
    return fullName;
  }

  double get itemPrice {
    double base = basePrice + kSizeUpgrade[size]!;
    double toppingTotal = toppings.fold(0, (sum, t) => sum + t.price);
    return (base + toppingTotal) * quantity;
  }
}
