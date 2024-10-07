import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_color.dart';
import '../../widgets/my_widgets.dart';

class JoinEventView extends StatefulWidget {
  DocumentSnapshot? eventDoc;

  JoinEventView(this.eventDoc);

  @override
  State<JoinEventView> createState() => _JoinEventViewState();
}

class _JoinEventViewState extends State<JoinEventView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String eventImage = '';

  @override
  void initState() {
    super.initState();
    try {
      List media = widget.eventDoc!.get('media') as List;
      Map mediaItem = media.firstWhere((element) => element['isImage'] == true) as Map;
      eventImage = mediaItem['url'];
    } catch (e) {
      eventImage = '';
    }
  }

  Future<void> joinEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('event_participants').add({
          'event_id': widget.eventDoc!.id,
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'joined_at': Timestamp.now(),
        });
        Get.snackbar('Success', 'You have successfully joined the event');
      } catch (e) {
        Get.snackbar('Error', 'Failed to join the event');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 27,
                      height: 27,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/circle.png'),
                        ),
                      ),
                      child: Image.asset('assets/bi_x-lg.png'),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Center(
                      child: myText(
                        text: 'Join Event',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(''),
                  )
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: Get.width,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2,
                      spreadRadius: 1,
                      color: Color(0xff393939).withOpacity(0.15),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(eventImage),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                myText(
                                  text: widget.eventDoc!.get('event_name'),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(width: 25),
                                myText(
                                  text: 'may 15',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 11.67,
                                height: 15,
                                child: Image.asset(
                                  'assets/location.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(width: 5),
                              myText(
                                text: widget.eventDoc!.get('location'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 7),
                          myText(
                            text: widget.eventDoc!.get('date'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blue,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Get.height * 0.04),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    myText(
                      text: 'Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    textField(
                      controller: nameController,
                      text: 'Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    myText(
                      text: 'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    textField(
                      controller: emailController,
                      text: 'Email',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    myText(
                      text: 'Phone Number',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    textField(
                      controller: phoneController,
                      text: 'Phone Number',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                height: 50,
                width: double.infinity,
                child: elevatedButton(
                  onpress: joinEvent,
                  text: 'Join Now',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Additional Widget: textField
Widget textField({required String text, required TextEditingController controller, String? Function(String?)? validator}) {
  return Container(
    height: 48,
    margin: EdgeInsets.only(
      bottom: Get.height * 0.02,
    ),
    child: TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: text,
        contentPadding: EdgeInsets.only(top: 10, left: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
}
