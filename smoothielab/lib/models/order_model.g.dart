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
      ..sweetness = fields[12] as String;
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(13)
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
      ..write(obj.sweetness);
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
