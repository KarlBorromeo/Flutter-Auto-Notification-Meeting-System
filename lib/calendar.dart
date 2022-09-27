import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event.dart';
import 'input.dart';

late Map<DateTime, List<Event>> selectedEvents = {};
late Map<DateTime, List<Event>> preEvents = {};
var list1 = [1];
var list2 = [1];
DateTime _focusedDay = DateTime.now();
DateTime _selectedDay = DateTime.now();
DateTime exDay = DateTime(2022, 09, 06, 08);
CalendarFormat _calendarFormat = CalendarFormat.month;
final CollectionReference _calendar =
    FirebaseFirestore.instance.collection('meet');
DateTime passedDate = DateTime.now();
String passedtitle = '';
String passedLocation = '';
String passedDescription = '';
String docId = ''; 
// String passedPersonel = '';
// List passedPersonel = [];

var newHour = 0;  // these are the useful variables to initialize the datetime from firebase to make it standard time for the device, 
                  // it is either 8 or 0 depends on the device UTC
                  //  because we cannot add the event in the calendar if we add the DateTime that is not a standard
                  //  
var newMinute = 0;
var newSecond = 0;
var newMillisecond = 0;


var i = 0;  //this is the counter to avoid looping of streambuilder when the set state occurs.
var j = 0;
DateTime selectedPassDate = DateTime.now();
DateTime passed2Date = DateTime.now();
TextEditingController titleDialogController = TextEditingController();
TextEditingController locationDialogController = TextEditingController();
TextEditingController descriptionDialogController = TextEditingController();
//TextEditingController titleDialogController = TextEditingController();

// ignore: camel_case_types
class calendar extends StatefulWidget {
  const calendar({super.key});

  @override
  State<calendar> createState() => _calendarState();
}

// ignore: camel_case_types
class _calendarState extends State<calendar> {
  @override
  void initState() {
    selectedEvents = {};
    super.initState();
  }

  List<Event> _getEventsfromDay(DateTime value) {
    return selectedEvents[value] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Calendar'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _calendar.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(.5),
              child: SizedBox(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: .01,
                        child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: ((context, index) {
                              final DocumentSnapshot documentSnapshot =
                                  snapshot.data!.docs[index];
                              passedDate = documentSnapshot['date'].toDate();//converting the Timestamp into DateTIme
                              passed2Date = DateTime(
                                      passedDate.year,
                                      passedDate.month,
                                      passedDate.day,
                                      newHour,
                                      newMinute,
                                      newSecond,
                                      newMillisecond)
                                  .toUtc();//initializing the DateTime into standard UTC like (2000,12,12 00.00.00.00Z)
                              passedtitle = documentSnapshot['title'];
                              passedLocation = documentSnapshot['location'];
                              passedDescription =
                                  documentSnapshot['description'];
                              docId = documentSnapshot.id;

                              if (i != 1) { //this if condition avoids the streambuilder to run this condition if set state occurs
                                if (selectedEvents[passed2Date] == null) {
                                  // addEvent(passed2Date);
                                  selectedEvents[passed2Date] = [
                                    Event(
                                        dateforHour: passedDate,
                                        date: passed2Date,
                                        id: documentSnapshot.id,
                                        title: passedtitle,
                                        location: passedLocation,
                                        description: passedDescription,
                                        personel: documentSnapshot['personel']),
                                  ];
                                } else {
                                  // moreEvent(passed2Date);
                                  selectedEvents[passed2Date]?.add(Event(
                                      dateforHour: passedDate,
                                      date: passed2Date,
                                      id: documentSnapshot.id,
                                      title: passedtitle,
                                      location: passedLocation,
                                      description: passedDescription,
                                      personel: documentSnapshot['personel']));
                                  // return Text('');
                                }

                                // list.add(index);
                              }
                              return Text('');
                            })),
                      ),
                    ),
                    //####################################
                    TableCalendar(
                      rowHeight: 90,
                      focusedDay: _focusedDay,
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2025),
                      eventLoader: _getEventsfromDay,
                      calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          todayTextStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 25),
                          selectedDecoration: BoxDecoration(
                              color: Color.fromARGB(34, 18, 115, 128),
                              shape: BoxShape.circle),
                          selectedTextStyle: TextStyle(color: Colors.black)),
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected:
                          (DateTime selectedDay, DateTime focusedDay) {
                        setState(() {
                          i = 1;  //every click on the date of the calendar the set state occurs, so I initialized the i =1 in order the streambuilder if condition will be false when the set state happens.
                          // _focusedDay = focusedDay;
                          _selectedDay = selectedDay;
                          selectedPassDate = _selectedDay;
                        });
                        print("selected day is " + _selectedDay.toString());
                      },
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),

                    ..._getEventsfromDay(_selectedDay).map((Event event) =>
                        Card(
                          shape: const RoundedRectangleBorder(),
                          child: ListTile(
                            tileColor: Color.fromARGB(255, 218, 208, 179),
                            leading: const Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                            ),
                            title: Text(event.title),
                            subtitle: Text(event.location),
                            dense: true,
                            onTap: () {
                              showModalBottomSheet(
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20))),
                                  context: context,
                                  builder: (BuildContext ctx) {
                                    String formattedHourandMinute =
                                        DateFormat('hh:mm a')//provides the format like this 4:30 AM
                                            .format(event.dateforHour);
                                    return Padding(
                                        padding: EdgeInsets.only(
                                            top: 20,
                                            left: 20,
                                            right: 20,
                                            bottom: MediaQuery.of(ctx)
                                                    .viewInsets
                                                    .bottom +
                                                10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius
                                                        .vertical(
                                                    top: Radius.circular(10)),
                                                color: const Color.fromARGB(
                                                    255, 218, 208, 179),
                                                border: Border.all(width: 0),
                                              ),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .22,
                                                      child: const Text(
                                                        "Title/Event:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontSize: 15),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .58,
                                                      child: Text(
                                                        event.title,
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Divider(
                                              thickness: .4,
                                              color: Colors.black,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius
                                                        .vertical(
                                                    top: Radius.circular(10)),
                                                color: const Color.fromARGB(
                                                    255, 218, 208, 179),
                                                border: Border.all(width: 0),
                                              ),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .22,
                                                      child: const Text(
                                                        "Location:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontSize: 15),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .58,
                                                      child: Text(
                                                        event.location,
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Divider(
                                              thickness: .4,
                                              color: Colors.black,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius
                                                        .vertical(
                                                    top: Radius.circular(10)),
                                                color: const Color.fromARGB(
                                                    255, 218, 208, 179),
                                                border: Border.all(width: 0),
                                              ),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .22,
                                                      child: const Text(
                                                        "Description:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontSize: 15),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .58,
                                                      child: Text(
                                                        event.description,
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Divider(
                                              thickness: .4,
                                              color: Colors.black,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius
                                                        .vertical(
                                                    top: Radius.circular(10)),
                                                color: const Color.fromARGB(
                                                    255, 218, 208, 179),
                                                border: Border.all(width: 0),
                                              ),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .22,
                                                      child: const Text(
                                                        "Time Schedule:",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontSize: 13),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .58,
                                                      child: Text(
                                                        formattedHourandMinute,
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Divider(),
                                            Center(
                                                child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  // maximumSize: Size(200,50)
                                                  minimumSize:
                                                      const Size.fromHeight(
                                                          35)),
                                              child: const Text('Delete'),
                                              onPressed: () {
                                                final index =
                                                    selectedEvents[event.date]!
                                                        .indexWhere((element) =>
                                                            element.id ==
                                                            event.id);//searching the index of the list inside the list.
                                                selectedEvents[event.date]
                                                    ?.removeAt(index); //removes the matched index in the list.
                                                _calendar
                                                    .doc(event.id)
                                                    .delete();//deleting the data from the database
                                                Navigator.pop(context);
                                                setState(() {});
                                              },
                                            ))
                                          ],
                                        ));
                                  });
                            },
                          ),
                        ))
                  ],
                ),
              ),
            );
          }
          return const CircularProgressIndicator();
        },
      ),

////////////////////////////////////////////////////////////////////////////////////
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            // i = 0;
            print(_selectedDay);

            Navigator.of(context).push(MaterialPageRoute(
                builder: (c) =>
                    input(
                      j: j, 
                      i: i, 
                      selectedDay: selectedPassDate, 
                      aw: 123)));
          }),
    );
  }
}
