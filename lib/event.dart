//import 'package:firebase_helpers/firebase_helpers.dart';

class Event {//this class is the struct that saves the data from the firebase into local
  final DateTime dateforHour;
  final DateTime date;
  final String id;
  final String title;
  final String location;
  final List personel;
  final String description;

  Event({
    required this.dateforHour,
    required this.date,
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.personel,
  });

  @override
  String toString() {
    return '${this.date},${this.id},${this.title}, ${this.location},${this.description},${this.personel}';
  }
}
