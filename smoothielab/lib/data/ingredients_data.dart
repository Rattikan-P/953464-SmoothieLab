/// Data สำหรับวัตถุดิบในหน้า Lab (Custom Smoothie)
/// ใช้สำหรับการสร้างสมูทตี้แบบ custom

import 'package:flutter/material.dart';

/// สีหลักของแต่ละวัตถุดิบ (R, G, B) - สีตามตัวจริง
/// Index 0-20 สำหรับผลไม้, Index 30+ สำหรับ extras, Index 100+ สำหรับผัก
const Map<int, Color> kIngredientColors = {
  // ผลไม้ (index ตาม kFruitsData)
  0: Color(0xFFFF6B9D), // Strawberry - ชมพูอมตะ
  1: Color(0xFFFFB347), // Mango - ส้มสดใส
  2: Color(0xFFFFE5A0), // Banana - เหลืองครีม
  3: Color(0xFFB388FF), // Blueberry - ม่วงพาสเทล
  4: Color(0xFF98D8C8), // Kiwi - เขียวมินต์
  5: Color(0xFFFFB7D5), // Peach - ชมพูบาน
  6: Color(0xFFFF6B9D), // Raspberry - ชมพูแดง
  7: Color(0xFFFFCC80), // Pineapple - ส้มเหลือง
  8: Color(0xFFFFAB40), // Apricot - ส้มส้ม
  9: Color(0xFFFF8A65), // Watermelon - แดงสด
  10: Color(0xFFFFB74D), // Orange - ส้มสวย
  11: Color(0xFF81C784), // Apple - เขียวอ่อน
  12: Color(0xFFFFCC80), // Lime - เหลืองอมเขียว
  13: Color(0xFFFFF59D), // Lemon - เหลืองสด
  14: Color(0xFFF48FB1), // Lychee - ชมพูกลาง
  15: Color(0xFFCE93D8), // Dragon Fruit - ม่วงชมพู
  // Extras (index 30+ - offset from kExtrasData)
  30: Color(0xFFFFFFFF), // Milk - ขาว
  31: Color(0xFFD7CCC8), // Coconut - ครีมขาว
  32: Color(0xFFFFCC80), // Juice - ส้มส้มอ่อน
  33: Color(0xFFE8D4B0), // Oat - น้ำตาลอ่อน
  34: Color(0xFF8D6E63), // Chocolate - น้ำตาลเข้ม
  35: Color(0xFF6D4C41), // Cocoa - น้ำตาลเข้มกว่า
  // ผัก (index 100+ เพื่อไม่ให้ซ้ำกับผลไม้)
  100: Color(0xFF4CAF50), // Kale/Spinach - เขียวเข้ม
  101: Color(0xFF81C784), // Broccoli - เขียวสดใส
  102: Color(0xFF81C784), // Cucumber - เขียวอ่อน
  103: Color(0xFF66BB6A), // Celery - เขียว
  // Dairy (index 200+)
  200: Color(0xFFFFFFFF), // Milk - ขาว
  201: Color(0xFFD7CCC8), // Coconut - ครีมขาว
  202: Color(0xFFFFF9C4), // Yogurt - ครีมเหลือง
  // Liquids (index 230+)
  230: Color(0xFFFFCC80), // Juice - ส้มส้มอ่อน
  231: Color(0xFFE8D4B0), // Oat - น้ำตาลอ่อน
  // Herbs (index 260+)
  260: Color(0xFFC5E1A5), // Mint - เขียวสด
  261: Color(0xFFFFAB91), // Ginger - ส้มอมเทา
  262: Color(0xFFAED581), // Honey - เหลืองอมเขียว
};

/// ผลไม้ที่เลือกได้ (index ตรงกับ kIngredientColors)
const List<(String emoji, String name, double price)> kFruitsData = [
  ('🍓', 'Strawberry', 15.0),     // 0
  ('🥭', 'Mango', 12.0),           // 1
  ('🍌', 'Banana', 8.0),           // 2
  ('💜', 'Blueberry', 18.0),       // 3
  ('🥝', 'Kiwi', 15.0),            // 4
  ('🍑', 'Peach', 14.0),           // 5
  ('🍓', 'Raspberry', 16.0),       // 6
  ('🍍', 'Pineapple', 12.0),       // 7
  ('🟠', 'Apricot', 14.0),         // 8
  ('🍉', 'Watermelon', 13.0),      // 9
  ('🍊', 'Orange', 10.0),          // 10
  ('🍏', 'Apple', 12.0),           // 11
  ('🍋‍🟩', 'Lime', 8.0),             // 12
  ('🍋', 'Lemon', 8.0),            // 13
  ('🩷', 'Lychee', 15.0),          // 14
  ('🐉', 'Dragon Fruit', 18.0),    // 15
];

/// ผักที่เลือกได้
const List<(String emoji, String name, double price)> kVeggiesData = [
  ('🥬', 'Kale', 10.0),
  ('🥦', 'Broccoli', 12.0),
  ('🥬', 'Spinach', 10.0),     // ใช้ index 100
  ('🥒', 'Cucumber', 8.0),
  ('🥬', 'Celery', 10.0),
];

/// พวกนม/ของเหลวเพิ่มเติม (เก่า - เก็บไว้เพื่อความเข้ากันได้)
const List<(String emoji, String name, double price)> kExtrasData = [
  ('🥛', 'Milk', 10.0),
  ('🥥', 'Coconut', 12.0),
  ('🧃', 'Juice', 8.0),
  ('🌾', 'Oat', 8.0),
  ('🍫', 'Chocolate', 12.0),    // 30 + 4 = 34
  ('🫘', 'Cocoa', 10.0),        // 30 + 5 = 35
];

/// สมุนไพร/เครื่องเทศ
const List<(String emoji, String name, double price)> kHerbsData = [
  ('🌿', 'Mint', 5.0),
  ('🫚', 'Ginger', 5.0),
  ('🍯', 'Honey', 10.0),
];

/// ระดับความหวาน
const List<(String emoji, String name)> kSweetnessLevels = [
  ('🚫', 'No sugar'),
  ('🌿', 'Less sugar'),
  ('😊', 'Normal'),
  ('🍓', 'Sweet'),
  ('🤩', 'Extra sweet'),
];

/// Topping Items สำหรับหน้า Lab
class ToppingItem {
  final String name;
  final String emoji;
  final double price;
  const ToppingItem({
    required this.name,
    required this.emoji,
    required this.price,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToppingItem &&
        other.name == name &&
        other.emoji == emoji &&
        other.price == price;
  }

  @override
  int get hashCode => name.hashCode ^ emoji.hashCode ^ price.hashCode;
}

/// ท้อปปิ้งที่เลือกได้
const List<ToppingItem> kToppingData = [
  ToppingItem(name: 'Jelly', emoji: '🍮', price: 10),
  ToppingItem(name: 'Tapioca Pearl', emoji: '⚫', price: 15),
  ToppingItem(name: 'Whipped Cream', emoji: '🍦', price: 15),
  ToppingItem(name: 'Chia Seeds', emoji: '🌱', price: 12),
  ToppingItem(name: 'Granola', emoji: '🌾', price: 12),
  ToppingItem(name: 'Almond', emoji: '🥜', price: 15),
  ToppingItem(name: 'Cocoa Powder', emoji: '🫘', price: 10),
];
