import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/controller/data_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/my_widgets.dart';
import 'package:ems/views/event_page/event_page_view.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  TextEditingController searchController = TextEditingController();
  DataController dataController = Get.find<DataController>();
  String selectedEventType = 'All'; // Default to 'All'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconWithTitle(
                func: () {},
                text: 'Community',
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextFormField(
                        controller: searchController,
                        onChanged: (String input) {
                          filterEvents();
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/search.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          hintText: 'Search Events',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Adjusted padding
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: DropdownButton<String>(
                      value: selectedEventType,
                      items: [
                        'All', 'College Event', 'Private', 'Public', 'Party', 'Sports', 'Wedding', 'Anniversary', 'General', 'DJ', 'Other'
                      ].map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedEventType = newValue!;
                          filterEvents();
                        });
                      },
                      underline: SizedBox(), // Remove underline
                      dropdownColor: Colors.white,
                      isExpanded: false,
                      icon: Icon(Icons.filter_list, color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Obx(
                    () => ListView.builder(
                  shrinkWrap: true,
                  itemCount: dataController.filteredEvents.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    String userName = '';
                    String userImage = '';
                    String eventUserId = '';
                    String location = '';
                    String eventImage = '';
                    String tagString = '';

                    eventUserId = dataController.filteredEvents.value[i].get('uid');
                    DocumentSnapshot? doc = dataController.allUsers.firstWhereOrNull((element) => element.id == eventUserId);

                    if (doc != null) {
                      String firstName = doc.get('first') ?? '';
                      String lastName = doc.get('last') ?? '';
                      userName = '$firstName $lastName';
                      userImage = doc.get('image') ?? '';
                    }

                    location = dataController.filteredEvents.value[i].get('location') ?? '';

                    try {
                      List media = dataController.filteredEvents.value[i].get('media');
                      eventImage = media.firstWhere((element) => element['isImage'] == true)['url'] ?? '';
                    } catch (e) {
                      eventImage = '';
                    }

                    List tags = [];

                    try {
                      tags = dataController.filteredEvents.value[i].get('tags');
                    } catch (e) {
                      tags = [];
                    }

                    if (tags.isEmpty) {
                      tagString = dataController.filteredEvents.value[i].get('description') ?? '';
                    } else {
                      tagString = tags.map((tag) => '#$tag').join(', ');
                    }

                    String eventName = dataController.filteredEvents.value[i].get('event_name') ?? '';

                    return InkWell(
                      onTap: () {
                        DocumentSnapshot eventData = dataController.filteredEvents.value[i];
                        DocumentSnapshot userData = dataController.allUsers.firstWhere((element) => element.id == eventData.get('uid'));

                        Get.to(() => EventPageView(
                          eventData,
                          userData, // Pass the user document
                        ));
                      },

                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            userProfile(
                              path: userImage,
                              title: userName,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff333333),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Image.asset('assets/location.png', height: 15),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff303030),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                eventImage,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              eventName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              tagString,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void filterEvents() {
    String searchInput = searchController.text.toLowerCase();
    List<DocumentSnapshot> filtered = dataController.allEvents.value.where((element) {
      List tags = [];
      bool isTagContain = false;

      try {
        tags = element.get('tags');
        for (int i = 0; i < tags.length; i++) {
          tags[i] = tags[i].toString().toLowerCase();
          if (tags[i].toString().contains(searchInput)) {
            isTagContain = true;
          }
        }
      } catch (e) {
        tags = [];
      }

      bool matchesSearch = (element.get('location').toString().toLowerCase().contains(searchInput) ||
          isTagContain ||
          element.get('event_name').toString().toLowerCase().contains(searchInput));

      bool matchesEventType = selectedEventType == 'All' || element.get('event') == selectedEventType;

      return matchesSearch && matchesEventType;
    }).toList();

    dataController.filteredEvents.assignAll(filtered);
  }
}
