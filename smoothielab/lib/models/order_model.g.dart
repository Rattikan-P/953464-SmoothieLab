// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 0;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel()
      ..orderId = fields[0] as String
      ..menuName = fields[1] as String
      ..menuEmoji = fields[2] as String
      ..size = fields[3] as String
      ..toppings = (fields[4] as List).cast<String>()
      ..totalPrice = fields[5] as double
      ..orderDate = fields[6] as DateTime
      ..status = fields[7] as String
      ..subtotal = fields[8] as double
      ..discount = fields[9] as double
      ..vat = fields[10] as double
      ..ingredients = (fields[11] as List).cast<String>()
      ..sweetness = fields[12] as String
      ..itemPriceRaw = fields[13] as double
      ..fruitIndexes = (fields[14] as List).cast<int>()
      ..extrasIndexes = (fields[15] as List).cast<int>()
      ..veggieIndexes = (fields[16] as List).cast<int>()
      ..herbsIndexes = (fields[17] as List).cast<int>()
      ..toppingsIndexes = (fields[18] as List).cast<int>()
      ..basePrice = fields[19] as double;
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.orderId)
      ..writeByte(1)
      ..write(obj.menuName)
      ..writeByte(2)
      ..write(obj.menuEmoji)
      ..writeByte(3)
      ..write(obj.size)
      ..writeByte(4)
      ..write(obj.toppings)
      ..writeByte(5)
      ..write(obj.totalPrice)
      ..writeByte(6)
      ..write(obj.orderDate)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.subtotal)
      ..writeByte(9)
      ..write(obj.discount)
      ..writeByte(10)
      ..write(obj.vat)
      ..writeByte(11)
      ..write(obj.ingredients)
      ..writeByte(12)
      ..write(obj.sweetness)
      ..writeByte(13)
      ..write(obj.itemPriceRaw)
      ..writeByte(14)
      ..write(obj.fruitIndexes)
      ..writeByte(15)
      ..write(obj.extrasIndexes)
      ..writeByte(16)
      ..write(obj.veggieIndexes)
      ..writeByte(17)
      ..write(obj.herbsIndexes)
      ..writeByte(18)
      ..write(obj.toppingsIndexes)
      ..writeByte(19)
      ..write(obj.basePrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
