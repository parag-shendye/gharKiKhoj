import 'dart:core';
import 'dart:ffi';

class Apartments {
  String title;
  String address;
  int floorArea;
  int rooms;
  int price;
  String furnished;
  String city;
  int builtYear;
  bool? applied;

  Apartments(
      {required this.title,
      required this.address,
      required this.floorArea,
      required this.rooms,
      required this.price,
      required this.furnished,
      required this.city,
      required this.builtYear,
      this.applied});
}
