import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageEventScreen extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Manage Events',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('uid', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditEventScreen(event),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(event['media'][0]['url']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['event_name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                event['date'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EditEventScreen extends StatefulWidget {
  final DocumentSnapshot event;

  EditEventScreen(this.event);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _priceController;
  late TextEditingController _frequencyController;
  late TextEditingController _tagsController;
  String? _selectedInviteStatus;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(text: widget.event['event_name']);
    _descriptionController = TextEditingController(text: widget.event['description']);
    _locationController = TextEditingController(text: widget.event['location']);
    _dateController = TextEditingController(text: widget.event['date']);
    _startTimeController = TextEditingController(text: widget.event['start_time']);
    _endTimeController = TextEditingController(text: widget.event['end_time']);
    _priceController = TextEditingController(text: widget.event['price']);
    _frequencyController = TextEditingController(text: widget.event['frequency_of_event']);
    _tagsController = TextEditingController(text: widget.event['tags'].join(', ')); // Assuming tags are a list of strings
    _selectedInviteStatus = widget.event['who_can_invite'];
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _priceController.dispose();
    _frequencyController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _updateEvent() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('events').doc(widget.event.id).update({
        'event_name': _eventNameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'date': _dateController.text,
        'start_time': _startTimeController.text,
        'end_time': _endTimeController.text,
        'price': _priceController.text,
        'frequency_of_event': _frequencyController.text,
        'tags': _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
        'who_can_invite': _selectedInviteStatus,
      }).then((_) {
        Navigator.pop(context);
      });
    }
  }

  void _deleteEvent() {
    FirebaseFirestore.instance.collection('events').doc(widget.event.id).delete().then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteEvent,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the event name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the date';
                  }
                  return null;
                },
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                    setState(() {
                      _dateController.text = formattedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _startTimeController,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the start time';
                  }
                  return null;
                },
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _startTimeController.text = pickedTime.format(context);
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _endTimeController,
                decoration: InputDecoration(
                  labelText: 'End Time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the end time';
                  }
                  return null;
                },
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _endTimeController.text = pickedTime.format(context);
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _frequencyController,
                decoration: InputDecoration(
                  labelText: 'Frequency of Event',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the frequency';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter tags';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedInviteStatus,
                decoration: InputDecoration(
                  labelText: 'Event Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['Open', 'Closed']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedInviteStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select an invitation status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateEvent,
                child: Text('Update Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
