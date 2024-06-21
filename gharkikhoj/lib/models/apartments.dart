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
  String href;
  String? available;
  String? duration;
  String? energy;

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
      required this.href,
      this.available,
      this.duration,
      this.energy,
      this.applied});
}
