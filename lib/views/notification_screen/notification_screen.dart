import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import '../../utils/app_color.dart';
import '../../widgets/my_widgets.dart';

class UserNotificationScreen extends StatefulWidget {
  @override
  _UserNotificationScreenState createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Container(
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
                padding: EdgeInsets.all(15),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('myNotifications')
                      .snapshots(),
                  builder: (ctx, snap) {
                    if (!snap.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final List<DocumentSnapshot> data = snap.data!.docs;

                    return ListView.builder(
                      itemBuilder: (ctx, i) {
                        String name, title, image;
                        DateTime date;

                        try {
                          name = data[i].get('name');
                        } catch (e) {
                          name = '';
                        }

                        try {
                          title = data[i].get('message');
                        } catch (e) {
                          title = '';
                        }

                        try {
                          image = data[i].get('image');
                        } catch (e) {
                          image = '';
                        }

                        try {
                          date = data[i].get('time').toDate();
                        } catch (e) {
                          date = DateTime.now();
                        }

                        return buildTile(name, title, date, image);
                      },
                      itemCount: data.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTile(String name, String title, DateTime subTitle, String image) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
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
          ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(image),
            ),
            title: Text(
              name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.black,
              ),
            ),
            subtitle: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              timeAgo.format(subTitle),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.genderTextColor,
              ),
            ),
          ),
          Divider(
            color: Colors.grey.withOpacity(0.3),
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
          ),
        ],
      ),
    );
  }
}
