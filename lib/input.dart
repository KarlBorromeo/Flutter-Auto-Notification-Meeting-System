// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:meet/calendar.dart';
import 'package:meet/event.dart';
import 'package:meet/providers/TagStateController.dart';
import 'package:http/http.dart' as http;

final CollectionReference _meet = FirebaseFirestore.instance.collection('meet');

final CollectionReference _gmails =
    FirebaseFirestore.instance.collection('gmails');

var suggestTag = [
  'lrakborromeo@gmail.com'
]; //initalize the suggestion of typeahead

List submitTag = [];

String suggestionValidator = '';

TextEditingController titleController = TextEditingController();

TextEditingController locationController = TextEditingController();

TextEditingController descriptController = TextEditingController();

TextEditingController fromDateController = TextEditingController();

TextEditingController fromTimeController = TextEditingController();

DateTime finalPickedDate = DateTime.now();

final format =
    DateFormat("yyyy-MM-dd hh:mm a"); //this format is (200,12,21 2:25 PM)
final format2 =
    DateFormat("yyyy-MM-dd HH:mm"); //this format is like (200,12,21 14:25)
String format2Date = '';
DateTime format2DateTime = DateTime.now();

TextEditingController combinedDateTime = TextEditingController();

final controller = Get.put(TagStateController());

final textController = TextEditingController();

var newHour = 0;
var newMinute = 0;
var newSecond = 0;
var newMillisecond = 0;

class input extends StatefulWidget {
  @override
  State<input> createState() => _inputState();

  late Map<DateTime, List<Event>> selectedEvents = {};
  var j;
  var i;
  DateTime selectedDay;
  var aw;

  input(
      {required this.j,
      required this.i,
      required this.selectedDay,
      required this.aw});
}

class _inputState extends State<input> {
  final date = selectedPassDate;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: ElevatedButton(
            child: const Icon(Icons.arrow_back),
            onPressed: () {
              controller.ListTags.clear();
              titleController.clear();
              locationController.clear();
              descriptController.clear();
              combinedDateTime.clear();
              textController.clear();
              Navigator.pop(context);
            },
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () async {
                format2Date = format2.format(format2DateTime);
                print(format2Date);
                // // print(combinedDateTime.text);
                // // print(format2Date);
                // print(controller.ListTags);
                // print(submitTag);
                // print(selectedPassDate);
                //can't add events if some fields is empty
                if (titleController.text.isEmpty &&
                        combinedDateTime.text.isEmpty ||
                    titleController.text.isEmpty ||
                    controller.ListTags.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please fill in the missing fields")));
                  print(controller.ListTags);
                  return;
                } else {
                  final String title = titleController.text;
                  final String location = locationController.text;
                  final String description = descriptController.text;
                  final String preDate = format2Date;

                  final DateTime date = DateTime.parse(preDate);
                  final DateTime finalDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          newHour,
                          newMinute,
                          newSecond,
                          newMillisecond)
                      .toUtc();
                  //sendEmail(title, location, description,format2Date,controller.ListTags);
                  _meet.add({
                    //add the inputs into the database
                    'title': title,
                    'location': location,
                    //'personel': submitTag,
                    'personel': controller.ListTags,
                    'description': description,
                    'date': date
                  });
                  // j = 1;
                  selectedEvents = {}; //deleting the whole list of events
                  i = 0; //enabling the streambuilder conditions to run again to avoid mulitple adding
                  final response = await sendEmail(title, location, description,format2Date,controller.ListTags);
                  ScaffoldMessenger.of(context).showSnackBar(
                          response == 200
                              ? const SnackBar(
                                  content: Text('Event is saved and personnels were notified succesfully!'),
                                  backgroundColor: Colors.green)
                              : const SnackBar(
                                  content: Text('Saving event failed!'),
                                  backgroundColor: Colors.red),
                        );
                  controller.ListTags.clear();
                  titleController.clear();
                  locationController.clear();
                  descriptController.clear();
                  combinedDateTime.clear();
                  textController.clear();
                  //submitTag.clear();
                  Navigator.pop(context);
                }
              },
              //$$$$$$$$

              label: const Text("Save"),
              icon: const Icon(Icons.check),
              style: ElevatedButton.styleFrom(
                  shadowColor: Colors.black, primary: (Colors.blue)),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                TextField(
                    decoration: const InputDecoration(
                      //enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1,color: Colors.blue)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.red)),
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Colors.black),
                      filled: true,
                      //labelText: "Title:",

                      hintText: "title",
                      prefixIcon: Icon(
                        Icons.title,
                        color: Colors.black,
                      ),
                    ),
                    controller: titleController),
                const Divider(),
                TextField(
                    decoration: const InputDecoration(
                      //enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1,color: Colors.blue)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.red)),
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Colors.black),
                      filled: true,
                      //labelText: "Title:",

                      hintText: "location",
                      prefixIcon: Icon(
                        Icons.location_city_outlined,
                        color: Colors.black,
                      ),
                    ),
                    controller: locationController),
                const Divider(),
                TextField(
                    decoration: const InputDecoration(
                      //enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1,color: Colors.blue)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.red)),
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Colors.black),
                      filled: true,
                      //labelText: "Title:",
                      hintText: "description",
                      prefixIcon: Icon(
                        Icons.short_text_rounded,
                        color: Colors.black,
                      ),
                    ),
                    maxLines: 4,
                    minLines: 1,
                    controller: descriptController),
                const Divider(),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: DateTimeField(
                    decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Colors.red)),
                        hintText: 'Please input time schedule',
                        prefixIcon: Icon(
                          Icons.calendar_month,
                          color: Colors.black,
                        ),
                        filled: true),
                    controller: combinedDateTime,
                    format: format,
                    onShowPicker: ((context, currentValue) async {
                      // final date = await showDatePicker(
                      //     context: context,
                      //     initialDate: DateTime.now(),
                      //     firstDate: DateTime(finalPickedDate.year - 1),
                      //     lastDate: DateTime(finalPickedDate.year + 5));

                      final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: 10, minute: 00));
                      format2DateTime = DateTimeField.combine(date, time);
                      return DateTimeField.combine(date, time);
                    }),
                  ),
                ),
                SizedBox(
                  height: 1,
                  child: StreamBuilder(
                    stream: _gmails.snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.hasData) {
                        return ListView.builder(
                            itemCount: streamSnapshot.data!.docs.length,
                            itemBuilder: ((context, index) {
                              final DocumentSnapshot documentSnapshot =
                                  streamSnapshot.data!.docs[index];

                              suggestTag.add(documentSnapshot[
                                  'email']); //adds the email that are registered in the firebase into the suggestion of typeahead
                              return const Text('');
                            }));
                      }
                      return const Text('');
                    },
                  ),
                ),
                const Divider(),
                //this is typeahead textfield
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: textController,
                          autofocus: false,
                          decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              prefixIcon: Icon(
                                Icons.people,
                                color: Colors.black,
                              ),
                              // border: OutlineInputBorder(),
                              filled: true,
                              hintText: "add emails here")),
                      suggestionsCallback: (String pattern) {
                        return suggestTag.where((e) =>
                            e.toLowerCase().contains(pattern.toLowerCase()));
                      },
                      onSuggestionSelected: (String suggestion) {
                        suggestionValidator = suggestion;
                        textController.clear();
                        if (controller.ListTags.contains(suggestionValidator)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Email already added')));
                        } else {
                          controller.ListTags.add(suggestion);
                          submitTag.add(suggestion);
                        }
                      },
                      itemBuilder: (BuildContext context, String itemData) {
                        return ListTile(
                          leading: const Icon(Icons.person_add),
                          title: Text(itemData),
                        );
                      }),
                ),
                const SizedBox(
                  height: 2,
                ),
                Obx(() => controller.ListTags.isEmpty
                    ? const Center(
                        child: Text(
                        "no tag selected",
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 20),
                      ))
                    : Wrap(
                        children: controller.ListTags.map((element) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: Chip(
                                  avatar: CircleAvatar(
                                    backgroundColor: Colors.white70,
                                    child: Text(element[0].toUpperCase()),
                                  ),
                                  label: Text(element),
                                  deleteIcon: const Icon(Icons.clear),
                                  onDeleted: () {
                                    controller.ListTags.remove(element);
                                  }),
                            )).toList(),
                      ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future sendEmail(
  String title, 
  String location,
  String description,
  String date,
  List email) async {
  final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
  // var map = new Map<String, dynamic>();
  // map['activityName'] = title;
  // map['activityDetails'] = email;
  // map['activityPhotoBase64'] = message;
  http.Response response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'service_id': 'service_96dydik',
        'template_id': 'template_cst85z4',
        'user_id': '-iuXs_2kkuf0kETu3',
        'template_params': {
          'user_title': title,
          'user_location': location,
          'user_description': description,
          'user_date': date,
          'user_email': email
        }
      }));
  return response.statusCode;
}
