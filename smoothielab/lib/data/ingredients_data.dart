/// Data สำหรับวัตถุดิบในหน้า Lab (Custom Smoothie)
/// ใช้สำหรับการสร้างสมูทตี้แบบ custom

import 'package:flutter/material.dart';

/// สีหลักของแต่ละวัตถุดิบ (R, G, B) - สีตามตัวจริง
/// Index 0-5 สำหรับผลไม้, Index 100-101 สำหรับผัก
const Map<int, Color> kIngredientColors = {
  // ผลไม้ (index ตาม kFruitsData)
  0: Color(0xFFFF6B9D), // สตรอว์เบอร์รี่ - ชมพูอมตะ
  1: Color(0xFFFFB347), // มะม่วง - ส้มสดใส
  2: Color(0xFFFFE5A0), // กล้วย - เหลืองครีม
  3: Color(0xFFB388FF), // บลูเบอร์รี่ - ม่วงพาสเทล
  4: Color(0xFF98D8C8), // กีวี - เขียวมินต์
  5: Color(0xFFFFB7D5), // พีช - ชมพูบาน
  // ผัก (index 100+ เพื่อไม่ให้ซ้ำกับผลไม้)
  100: Color(0xFF4CAF50), // ผักโขม - เขียวเข้ม
  101: Color(0xFF81C784), // บร็อคโคลี่ - เขียวสดใส
};

/// ผลไม้ที่เลือกได้
const List<(String emoji, String name, double price)> kFruitsData = [
  ('🍓', 'Strawberry', 15.0),
  ('🥭', 'Mango', 12.0),
  ('🍌', 'Banana', 8.0),
  ('💜', 'Blueberry', 18.0),
  ('🥝', 'Kiwi', 15.0),
  ('🍑', 'Peach', 14.0),
];

/// ผักที่เลือกได้
const List<(String emoji, String name, double price)> kVeggiesData = [
  ('🥬', 'Kale', 10.0),
  ('🥦', 'Broccoli', 12.0),
  // เพิ่มได้เลยค่ะ
];

/// พวกนม/ของเหลวเพิ่มเติม
const List<(String emoji, String name, double price)> kExtrasData = [
  ('🥛', 'Milk', 10.0),
  ('🥥', 'Coconut', 12.0),
  ('🧃', 'Juice', 8.0),
];

/// ระดับความหวาน
const List<(String emoji, String name)> kSweetnessLevels = [
  ('🚫', 'No sugar'),
  ('🌿', 'Less sugar'),
  ('😊', 'Normal'),
  ('🍓', 'Sweet'),
  ('🤩', 'Extra sweet'),
];
