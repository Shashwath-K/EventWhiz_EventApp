import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/controller/data_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ems/views/PaymentPage/payment_page.dart';
import '../../utils/app_color.dart';

class EventPageView extends StatefulWidget {
  final DocumentSnapshot eventData;
  final DocumentSnapshot user;

  EventPageView(this.eventData, this.user);

  @override
  _EventPageViewState createState() => _EventPageViewState();
}

class _EventPageViewState extends State<EventPageView> {
  DataController dataController = Get.find<DataController>();
  bool hasJoined = false;

  @override
  void initState() {
    super.initState();
    checkIfUserJoined();
  }

  void checkIfUserJoined() {
    try {
      List<String> joinedUsers = List<String>.from(widget.eventData.get('joined') ?? []);
      setState(() {
        hasJoined = joinedUsers.contains(FirebaseAuth.instance.currentUser!.uid);
      });
    } catch (e) {
      setState(() {
        hasJoined = false;
      });
    }
  }

  void navigateToPaymentPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(widget.eventData),
      ),
    );

    if (result == true) {
      setState(() {
        hasJoined = true;
      });
    }
  }

  void joinEvent() async {
    if (!hasJoined) {
      navigateToPaymentPage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Already joined this event!')),
      );
    }
  }

  void leaveEvent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Leave Event'),
          content: Text('Are you sure you want to leave this event?'),
          actions: [
            TextButton(
              onPressed: () async {
                String userId = FirebaseAuth.instance.currentUser!.uid;
                String eventId = widget.eventData.id;

                await FirebaseFirestore.instance.collection('events').doc(eventId).update({
                  'joined': FieldValue.arrayRemove([userId]),
                  'max_entries': FieldValue.increment(1),
                });

                setState(() {
                  hasJoined = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You have left the event.')),
                );

                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void shareEventDetails() {
    String eventName = widget.eventData.get('event_name');
    String location = widget.eventData.get('location');
    String startTime = widget.eventData.get('start_time');
    String date = widget.eventData.get('date');
    String description = widget.eventData.get('description');
    String imageUrl = widget.eventData.get('media')[0]['url'];

    String message = '''
🎉 *Don't Miss Out on This Event!* 🎉

*Event Name:* $eventName
*Location:* $location
*Date:* $date
*Time:* $startTime

*Description:*
$description

📸 [View Event Image]
($imageUrl)

We'd be thrilled to have you join us and make this event a success!

Your presence is acknowledged. 🌟

*Source: EventWhiz!*
''';

    Share.share(message);
  }

  void imageDialog(BuildContext context) {
    showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Media Source"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () {
                      getImageDialog(ImageSource.gallery);
                    },
                    icon: Icon(Icons.image)),
                IconButton(
                    onPressed: () {
                      getImageDialog(ImageSource.camera);
                    },
                    icon: Icon(Icons.camera_alt)),
              ],
            ),
          );
        },
        context: context);
  }

  Future<void> getImageDialog(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      String imageUrl = await uploadMediaToStorage(File(pickedFile.path), 'images');
      addMediaToFirestore(imageUrl);
    }
  }

  Future<String> uploadMediaToStorage(File file, String folder) async {
    String imageUrl = await dataController.uploadImageToFirebase(file);
    return imageUrl;
  }

  void addMediaToFirestore(String mediaUrl) async {
    String eventId = widget.eventData.id;

    await FirebaseFirestore.instance.collection('events').doc(eventId).update({
      'after_pics': FieldValue.arrayUnion([mediaUrl])
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image uploaded successfully!')),
    );
  }

  void viewImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Image.network(imageUrl),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String eventImage = widget.eventData.get('media').isNotEmpty
        ? widget.eventData.get('media')[0]['url']
        : 'https://via.placeholder.com/150';

    List<String> tags = List<String>.from(widget.eventData.get('tags') ?? []);
    int maxEntries = widget.eventData.get('max_entries');
    String price = widget.eventData.get('price');
    String whoCanInvite = widget.eventData.get('who_can_invite');

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        backgroundColor: AppColors.white2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.user.get('image')),
                      radius: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.user.get('first')} ${widget.user.get('last')}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "${widget.user.get('location')}",
                            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xffEEEEEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event, size: 18, color: Colors.blue),
                          SizedBox(width: 5),
                          Text(
                            '${widget.eventData.get('event')}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.date_range, size: 18, color: Colors.blue),
                        SizedBox(width: 5),
                        Text(
                          '${widget.eventData.get('date')}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 18, color: Colors.blue),
                        SizedBox(width: 5),
                        Text(
                          '${widget.eventData.get('start_time')}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(eventImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.eventData.get('event_name'),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue),
                  SizedBox(width: 5),
                  Text(
                    "${widget.eventData.get('location')}",
                    style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              SizedBox(height: 10),
              SizedBox(height: 10),
              Row(
                children: tags.map((tag) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text('#$tag'),
                    backgroundColor: Colors.grey[200],
                  ),
                )).toList(),
              ),
              SizedBox(height: 10),
              Text(
                "${widget.eventData.get('description')}",
                style: TextStyle(fontSize: 16, color: AppColors.black, fontWeight: FontWeight.w400),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 10),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .doc(widget.eventData.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox(); // Handle loading or empty states

                  String eventStatus = snapshot.data!['who_can_invite'] ?? 'Unknown';
                  Color statusColor = eventStatus == 'Open' ? Colors.green : Colors.red;

                  return Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6, // 60% of device width
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            'Event Status: $eventStatus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 15),
              Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.eventData.get('max_entries')} Spots Left',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Price: ₹ ${widget.eventData.get('price')}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: widget.eventData['who_can_invite'] != 'Closed',
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: hasJoined ? leaveEvent : joinEvent,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: hasJoined ? Colors.red : Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: Size(120, 40), // Adjust the width and height as needed
                            elevation: 0, // Remove shadow
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasJoined ? Icons.close : Icons.check,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                hasJoined ? 'Leave Event' : 'Join Event',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: shareEventDetails,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: Size(120, 40), // Adjust the width and height as needed
                            elevation: 0, // Remove shadow
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.share, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Share Event',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Event Participants',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .doc(widget.eventData.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  List<dynamic> joinedUsers = snapshot.data!['joined'];
                  return Column(
                    children: joinedUsers.map<Widget>((userId) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return SizedBox();
                          var user = snapshot.data!;
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[200],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(user['image']),
                                  radius: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '${user['first']} ${user['last']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 20),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('events')
                    .doc(widget.eventData.id)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  String priceString = snapshot.data!['price'] ?? '0';
                  double eventPrice = double.tryParse(priceString) ?? 0.0;
                  int participantsCount = (snapshot.data!['joined'] as List).length;

                  if (eventPrice == 0) {
                    return Text(
                      'Total amount collected: Free event',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    );
                  } else {
                    double totalAmount = eventPrice * participantsCount;
                    return Text(
                      'Total amount collected: ₹${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    );
                  }
                },
              ),

              SizedBox(height: 20),
              // Add condition for displaying upload images button and event images
              if (hasJoined) ...[
                SizedBox(height: 20),
                Text(
                  'Upload images',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  "Hello Participants! Share your event photos with us! Let's preserve these memorable moments together!",
                  style: TextStyle(fontSize: 16, color: AppColors.black, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    imageDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.whitegrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text('Upload Images'),
                ),
                SizedBox(height: 20),
                SizedBox(height: 20),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .doc(widget.eventData.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox();
                    List<dynamic> afterPics = snapshot.data!['after_pics'] ?? [];
                    return GridView.builder(
                      shrinkWrap: true, // Use this to make the GridView size itself to the content
                      physics: NeverScrollableScrollPhysics(), // Disable scrolling for the GridView
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of images per row
                        crossAxisSpacing: 10, // Horizontal spacing between images
                        mainAxisSpacing: 10, // Vertical spacing between images
                        childAspectRatio: 1, // Aspect ratio of each image (1 means square)
                      ),
                      itemCount: afterPics.length,
                      itemBuilder: (context, index) {
                        String imageUrl = afterPics[index];
                        return GestureDetector(
                          onTap: () {
                            viewImage(imageUrl);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
