import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentPage extends StatefulWidget {
  final DocumentSnapshot eventData;

  PaymentPage(this.eventData);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? cardNumber;
  String? expirationDate;
  String? cvv;
  String? name;

  // Function to handle dummy payment processing
  void processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is not valid
    }

    setState(() {
      isLoading = true;
    });

    // Simulate payment processing delay
    await Future.delayed(Duration(seconds: 3));

    String userId = FirebaseAuth.instance.currentUser!.uid;
    String eventId = widget.eventData.id;

    // Fetch the current state of the event
    DocumentSnapshot eventDoc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
    int currentMaxEntries = eventDoc.get('max_entries');
    List<dynamic> joinedUsers = eventDoc.get('joined') ?? [];
    double eventPrice = double.parse(eventDoc.get('price') ?? '0'); // Fetch price

    // Create new Firestore collection if not exists
    FirebaseFirestore.instance.collection('payments').doc(eventId).set({
      'event_id': eventId,
      'user_id': userId,
      'amount': eventPrice,
      'status': 'success',
      'processed_at': Timestamp.now(),
    }, SetOptions(merge: true));

    // Proceed with payment only if the event still has spots left
    if (currentMaxEntries > 0 && !joinedUsers.contains(userId)) {
      await FirebaseFirestore.instance.collection('events').doc(eventId).update({
        'joined': FieldValue.arrayUnion([userId]),
        'max_entries': currentMaxEntries - 1,
      });

      await FirebaseFirestore.instance.collection('event_participants').add({
        'event_id': eventId,
        'user_id': userId,
        'joined_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful and you have joined the event!')),
      );

      Navigator.pop(context, true); // Pass true to indicate successful joining
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to join the event. No spots left or you are already a member.')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double price = double.tryParse(widget.eventData.get('price') ?? '0') ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Payment'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Confirm Payment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'This is a dummy payment page. Do not send valuable details.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Card Number',
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    validator: 'Card Number is required',
                    onChanged: (value) {
                      cardNumber = value;
                    },
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    label: 'Expiration Date (MM/YY)',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.datetime,
                    validator: 'Expiration Date is required',
                    onChanged: (value) {
                      expirationDate = value;
                    },
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    label: 'CVV',
                    icon: Icons.lock,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: 'CVV is required',
                    onChanged: (value) {
                      cvv = value;
                    },
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    label: 'Name on Card',
                    icon: Icons.person,
                    validator: 'Name on Card is required',
                    onChanged: (value) {
                      name = value;
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Total: ₹${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    child: Text(
                      'Pay Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String validator,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validator;
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}
