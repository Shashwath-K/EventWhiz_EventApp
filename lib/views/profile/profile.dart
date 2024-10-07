import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/controller/data_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';

// Import the required files
import 'package:ems/views/manage_events/manage_event.dart';
import 'package:ems/views/manage_events/joined_events.dart';
import 'package:ems/views/manage_events/bookmarked_events.dart';
import 'package:ems/views/auth/change_password.dart';

import '../../utils/app_color.dart';
import 'package:ems/views/onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  DataController? dataController;

  int? followers = 0, following = 0;
  String? image = '';
  bool isNotEditable = true;
  bool isEditingImage = false;

  @override
  void initState() {
    super.initState();
    dataController = Get.find<DataController>();

    // Fetching user details from Firestore
    firstNameController.text = dataController!.myDocument!.get('first');
    lastNameController.text = dataController!.myDocument!.get('last');

    try {
      descriptionController.text = dataController!.myDocument!.get('desc');
    } catch (e) {
      descriptionController.text = '';
    }

    try {
      image = dataController!.myDocument!.get('image');
    } catch (e) {
      image = '';
    }

    try {
      locationController.text = dataController!.myDocument!.get('location');
    } catch (e) {
      locationController.text = '';
    }

    try {
      followers = dataController!.myDocument!.get('followers').length;
    } catch (e) {
      followers = 0;
    }

    try {
      following = dataController!.myDocument!.get('following').length;
    } catch (e) {
      following = 0;
    }
  }

  Future<void> updateProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imageUrl = await uploadImageToFirebaseStorage(File(pickedFile.path));
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'image': imageUrl,
      }).then((_) {
        setState(() {
          image = imageUrl;
        });
        Get.snackbar('Profile Image Updated',
            'Your profile image has been updated successfully.',
            colorText: Colors.white,
            backgroundColor: Colors.blue);
      }).catchError((error) {
        Get.snackbar('Update Failed',
            'Failed to update profile image: $error',
            colorText: Colors.white,
            backgroundColor: Colors.red);
      });
    }
  }

  Future<String> uploadImageToFirebaseStorage(File image) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);

    var reference = FirebaseStorage.instance.ref().child('profileImages/$fileName');
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then((value) {
      imageUrl = value;
    }).catchError((e) {
      print("Error happened: $e");
    });

    return imageUrl;
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogoutDialog(
          onCancel: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          onLogout: () async {
            await FirebaseAuth.instance.signOut();
            setState(() {
              Get.offAll(() => OnBoardingScreen());
            });
          },
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Help and Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('For any further assistance or any problems with the app and other contents please contact:'),
              SizedBox(height: 10),
              Text('shashwathkukkunoor@outlook.com', textAlign: TextAlign.left),
              SizedBox(height: 5),
              Text('purvinmudyana2019@gmail.com', textAlign: TextAlign.left),
              SizedBox(height: 5),
              Text('nikhilnikhil@gmail.com', textAlign: TextAlign.left),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('About App'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/Group.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 15),
              Text('This app provides the best event management experience. You can create, join, and bookmark events easily. Stay organized and updated with our app.',
                  textAlign: TextAlign.justify),
              SizedBox(height: 10),
              const Text(
                'Version 1.6.5',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Card
              Card(
                margin: EdgeInsets.all(10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 100,
                        ),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: isNotEditable
                              ? null
                              : () {
                            setState(() {
                              isEditingImage = true;
                            });
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            padding: EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(70),
                            ),
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: Colors.white,
                              backgroundImage: image != null && image!.isNotEmpty
                                  ? NetworkImage(image!)
                                  : AssetImage('assets/profile.png') as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                      if (isEditingImage)
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: updateProfileImage,
                            child: Text('Update Image'),
                          ),
                        ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${firstNameController.text} ${lastNameController.text}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (!isNotEditable) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!isNotEditable) ...[
                              TextField(
                                controller: firstNameController,
                                enabled: !isNotEditable,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(color: Colors.blue, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                                  ),
                                  labelText: 'First Name',
                                  labelStyle: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: lastNameController,
                                enabled: !isNotEditable,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(color: Colors.blue, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                                  ),
                                  labelText: 'Last Name',
                                  labelStyle: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: locationController,
                                enabled: !isNotEditable,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(color: Colors.blue, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                                  ),
                                  labelText: 'Location',
                                  labelStyle: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: descriptionController,
                                enabled: !isNotEditable,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(color: Colors.blue, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                                  ),
                                  labelText: 'Description',
                                  labelStyle: TextStyle(color: Colors.grey.shade600),
                                ),
                                maxLines: 3, // Allow multiple lines for description
                              ),
                              SizedBox(height: 20),
                            ],
                            // Other widgets like buttons
                          ],
                        )
                      ],
                      if (isNotEditable)
                        Text(
                          locationController.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      if (isNotEditable)
                        Text(
                          descriptionController.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      SizedBox(height: 20),
                      if (isNotEditable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isNotEditable = false;
                                });
                              },
                              child: Text('Edit'),
                            ),
                          ],
                        ),
                      if (!isNotEditable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isNotEditable = true;
                                  // Save changes to Firestore here
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth.instance.currentUser!.uid)
                                      .update({
                                    'first': firstNameController.text,
                                    'last': lastNameController.text,
                                    'desc': descriptionController.text,
                                    'location': locationController.text,
                                  }).then((_) {
                                    Get.snackbar('Profile Updated',
                                        'Your profile has been updated successfully.',
                                        colorText: Colors.white,
                                        backgroundColor: Colors.blue);
                                  }).catchError((error) {
                                    Get.snackbar('Update Failed',
                                        'Failed to update profile: $error',
                                        colorText: Colors.white,
                                        backgroundColor: Colors.red);
                                  });
                                });
                              },
                              child: Text('Save'),
                            ),
                            SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isNotEditable = true;
                                  // Discard changes
                                  firstNameController.text = dataController!.myDocument!.get('first');
                                  lastNameController.text = dataController!.myDocument!.get('last');
                                  descriptionController.text = dataController!.myDocument!.get('desc');
                                  locationController.text = dataController!.myDocument!.get('location');
                                });
                              },
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Manage Events
              Card(
                margin: EdgeInsets.all(10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        leading: Icon(Icons.event),
                        title: Text('My events'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.to(() => ManageEventScreen());
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.bookmark),
                        title: Text('Bookmarked events'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.to(() => BookmarkedEventsScreen());
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.event_available),
                        title: Text('Joined events'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.to(() => JoinedEventScreen());
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.lock),
                        title: Text('Change password'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.to(() => ChangePasswordScreen());
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.help),
                        title: Text('Help'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: _showHelpDialog,
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.info),
                        title: Text('About app'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: _showAboutDialog,
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onLogout;

  LogoutDialog({
    required this.onCancel,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Logout'),
      content: Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: onLogout,
          child: Text('Logout'),
        ),
      ],
    );
  }
}
