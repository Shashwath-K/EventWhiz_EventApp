import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/controller/data_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import '../model/ticket_model.dart';
import '../utils/app_color.dart';
import '../views/event_page/event_page_view.dart';
import '../views/profile/add_profile.dart';
import 'package:intl/intl.dart';

List<AustinYogaWork> austin = [
  AustinYogaWork(rangeText: '7-8', title: 'CONCERN'),
  AustinYogaWork(rangeText: '8-9', title: 'VINYASA'),
  AustinYogaWork(rangeText: '9-10', title: 'MEDITATION'),
];
List<String> imageList = [
  'assets/#1.png',
  'assets/#2.png',
  'assets/#3.png',
  'assets/#1.png',
];

Widget EventsFeed() {
  DataController dataController = Get.find<DataController>();
  return Obx(() => dataController.isEventsLoading.value
      ? Center(child: CircularProgressIndicator())
      : ListView(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    children: [
      // Today's Events Section
      SectionTitle(title: 'Today\'s Events'),
      ...dataController.allEvents
          .where((event) {
        final eventDate = _parseDate(event.get('date'));
        final now = DateTime.now();
        return eventDate != null &&
            eventDate.year == now.year &&
            eventDate.month == now.month &&
            eventDate.day == now.day;
      })
          .map((event) => EventItem(event))
          .toList(),
      if (dataController.allEvents
          .where((event) {
        final eventDate = _parseDate(event.get('date'));
        final now = DateTime.now();
        return eventDate != null &&
            eventDate.year == now.year &&
            eventDate.month == now.month &&
            eventDate.day == now.day;
      })
          .isEmpty)
        DefaultNoEventsCard(),

      // Upcoming Events Section
      SectionTitle(title: 'Upcoming Events'),
      ...dataController.allEvents
          .where((event) {
        final eventDate = _parseDate(event.get('date'));
        final now = DateTime.now();
        return eventDate != null &&
            eventDate.isAfter(now) &&
            (eventDate.year != now.year ||
                eventDate.month != now.month ||
                eventDate.day != now.day);
      })
          .map((event) => EventItem(event))
          .toList(),
      if (dataController.allEvents
          .where((event) {
        final eventDate = _parseDate(event.get('date'));
        final now = DateTime.now();
        return eventDate != null &&
            eventDate.isAfter(now) &&
            (eventDate.year != now.year ||
                eventDate.month != now.month ||
                eventDate.day != now.day);
      })
          .isEmpty)
        DefaultUpcomingEventCard(),

      // Old Events Section
      SectionTitle(title: 'Old Events'),
      ...dataController.allEvents
          .where((event) {
        final eventDate = _parseDate(event.get('date'));
        final now = DateTime.now();
        return eventDate != null &&
            eventDate.isBefore(now) &&
            (eventDate.year < now.year ||
                eventDate.month < now.month ||
                eventDate.day < now.day);
      })
          .map((event) => EventItem(event))
          .toList(),
      if (dataController.allEvents
          .where((event) {
        final eventDate = _parseDate(event.get('date'));
        final now = DateTime.now();
        return eventDate != null &&
            eventDate.isBefore(now) &&
            (eventDate.year < now.year ||
                eventDate.month < now.month ||
                eventDate.day < now.day);
      })
          .isEmpty)
        DefaultOldEventCard(),
    ],
  ));
}

DateTime? _parseDate(String dateStr) {
  try {
    return DateFormat('dd-MM-yyyy').parse(dateStr);
  } catch (e) {
    return null;
  }
}

Widget SectionTitle({required String title}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

Widget DefaultUpcomingEventCard() {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(Icons.event_available, color: AppColors.blue, size: 40),
        SizedBox(width: 20),
        Expanded(
          child: Text(
            "There are many more events to come.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

Widget DefaultNoEventsCard() {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(Icons.event_available, color: AppColors.blue, size: 40),
        SizedBox(width: 20),
        Expanded(
          child: Text(
            "There are No events today.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}
Widget DefaultOldEventCard() {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(Icons.event_available, color: AppColors.blue, size: 40),
        SizedBox(width: 20),
        Expanded(
          child: Text(
            "Looks like there are no old events.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}
Widget buildCard({String? image, text, Function? func, DocumentSnapshot? eventData}) {
  DataController dataController = Get.find<DataController>();

  List joinedUsers = [];
  try {
    joinedUsers = eventData!.get('joined');
  } catch (e) {
    joinedUsers = [];
  }

  List dateInformation = [];
  try {
    dateInformation = eventData!.get('date').toString().split('-');
  } catch (e) {
    dateInformation = [];
  }

  List userLikes = [];
  try {
    userLikes = eventData!.get('likes');
  } catch (e) {
    userLikes = [];
  }

  List eventSavedByUsers = [];
  try {
    eventSavedByUsers = eventData!.get('saves');
  } catch (e) {
    eventSavedByUsers = [];
  }

  DocumentSnapshot? user = dataController.allUsers.firstWhereOrNull((
      e) => eventData?.get('uid') == e.id);
  String userImage = '';
  String userName = '';

  try {
    userImage = user?.get('image');
    userName = '${user?.get('first')} ${user?.get('last')}';
  } catch (e) {
    userImage = '';
    userName = 'Unknown User';
  }

  String eventType = eventData?.get('event') ?? 'Unknown';

  return Container(
    margin: EdgeInsets.symmetric(vertical: 10),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(userImage),
            ),
            SizedBox(width: 10),
            Text(
              userName,
              style: GoogleFonts.raleway(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                if (eventSavedByUsers.contains(
                    FirebaseAuth.instance.currentUser!.uid)) {
                  FirebaseFirestore.instance.collection('events').doc(
                      eventData!.id).set({
                    'saves': FieldValue.arrayRemove(
                        [FirebaseAuth.instance.currentUser!.uid])
                  }, SetOptions(merge: true));
                } else {
                  FirebaseFirestore.instance.collection('events').doc(
                      eventData!.id).set({
                    'saves': FieldValue.arrayUnion(
                        [FirebaseAuth.instance.currentUser!.uid])
                  }, SetOptions(merge: true));
                }
              },
              child: Icon(
                eventSavedByUsers.contains(
                    FirebaseAuth.instance.currentUser!.uid)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        InkWell(
          onTap: () {
            func!();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  image: NetworkImage(image!), fit: BoxFit.cover),
            ),
            width: double.infinity,
            height: Get.width * 0.5,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w700, // Bolder text
                  fontSize: 20, // Increased font size
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue, size: 16), // Blue icon
                SizedBox(width: 4),
                Text(
                  '${dateInformation[0]}-${dateInformation[1]}',
                  style: TextStyle(
                    fontSize: 16, // Increased font size
                    fontWeight: FontWeight.w700, // Bolder text
                    color: Colors.blue, // Blue color
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (userLikes.contains(
                          FirebaseAuth.instance.currentUser!.uid)) {
                        FirebaseFirestore.instance.collection('events').doc(
                            eventData!.id).set({
                          'likes': FieldValue.arrayRemove([FirebaseAuth.instance
                              .currentUser!.uid
                          ]),
                        }, SetOptions(merge: true));
                      } else {
                        FirebaseFirestore.instance.collection('events').doc(
                            eventData!.id).set({
                          'likes': FieldValue.arrayUnion([FirebaseAuth.instance
                              .currentUser!.uid
                          ]),
                        }, SetOptions(merge: true));
                      }
                    },
                    child: Icon(
                      userLikes.contains(FirebaseAuth.instance.currentUser!.uid)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: userLikes.contains(
                          FirebaseAuth.instance.currentUser!.uid)
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '${userLikes.length}',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.event, color: Colors.blueGrey, size: 16), // Event icon
                SizedBox(width: 4),
                Text(
                  eventType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    ),
  );
}


Widget EventItem(DocumentSnapshot event) {
  DataController dataController = Get.find<DataController>();

  DocumentSnapshot user = dataController.allUsers.firstWhere((e) => event.get('uid') == e.id);

  String image = '';
  try {
    image = user.get('image');
  } catch (e) {
    image = '';
  }

  String eventImage = '';
  try {
    List media = event.get('media') as List;
    Map mediaItem = media.firstWhere((element) => element['isImage'] == true) as Map;
    eventImage = mediaItem['url'];
  } catch (e) {
    eventImage = '';
  }

  return Column(
    children: [
      buildCard(
        image: eventImage,
        text: event.get('event_name'),
        eventData: event,
        func: () {
          Get.to(() => EventPageView(event, user));
        },
      ),
      SizedBox(
        height: 15,
      ),
    ],
  );
}

Widget EventsIJoined() {
  DataController dataController = Get.find<DataController>();

  DocumentSnapshot myUser = dataController.allUsers.firstWhere((e) => e.id == FirebaseAuth.instance.currentUser!.uid);

  String userImage = '';
  String userName = '';

  try {
    userImage = myUser.get('image');
  } catch (e) {
    userImage = '';
  }

  try {
    userName = '${myUser.get('first')} ${myUser.get('last')}';
  } catch (e) {
    userName = '';
  }

  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            padding: EdgeInsets.all(10),
            child: Image.asset(
              'assets/doneCircle.png',
              fit: BoxFit.cover,
              color: AppColors.blue,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      SizedBox(
        height: Get.height * 0.015,
      ),
    ],
  );
}
