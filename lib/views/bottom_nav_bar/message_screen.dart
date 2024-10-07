import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/controller/data_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chat/chat_room_screen.dart';

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  DataController dataController = Get.find<DataController>();
  String myUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Messages",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: TextStyle(color: Colors.grey[700]),
                        onChanged: (String input) {
                          if (input.isEmpty) {
                            dataController.filteredUsers.assignAll(dataController.allUsers);
                          } else {
                            List<DocumentSnapshot> users = dataController.allUsers.value.where((element) {
                              String name;
                              try {
                                name = element.get('first') + ' ' + element.get('last');
                              } catch (e) {
                                name = '';
                              }
                              return name.toLowerCase().contains(input.toLowerCase());
                            }).toList();

                            dataController.filteredUsers.value.assignAll(users);
                            setState(() {});
                          }
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.grey[200],
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)),
                          hintText: "Search",
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 17),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Obx(() => ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: dataController.filteredUsers.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    String name = '', image = '';
                    try {
                      name = dataController.filteredUsers[index].get('first') + ' ' + dataController.filteredUsers[index].get('last');
                    } catch (e) {
                      name = '';
                    }

                    try {
                      image = dataController.filteredUsers[index].get('image');
                    } catch (e) {
                      image = '';
                    }

                    String fcmToken = '';
                    try {
                      fcmToken = dataController.filteredUsers[index].get('fcmToken');
                    } catch (e) {
                      fcmToken = '';
                    }

                    return dataController.filteredUsers[index].id == FirebaseAuth.instance.currentUser!.uid
                        ? Container()
                        : InkWell(
                      onTap: () {
                        String chatRoomId = '';
                        if (myUid.hashCode > dataController.filteredUsers[index].id.hashCode) {
                          chatRoomId = '$myUid-${dataController.filteredUsers[index].id}';
                        } else {
                          chatRoomId = '${dataController.filteredUsers[index].id}-$myUid';
                        }

                        Get.to(() => Chat(
                          groupId: chatRoomId,
                          name: name,
                          image: image,
                          fcmToken: fcmToken,
                          uid: dataController.filteredUsers[index].id,
                        ));
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.08,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(image),
                              radius: 25,
                            ),
                            SizedBox(width: screenWidth * 0.05),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Tap to open chat',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.05),
                            Icon(Icons.message, color: Colors.grey[500]), // New icon for message
                          ],
                        ),
                      ),
                    );
                  },
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
