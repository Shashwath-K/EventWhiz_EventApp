import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/animation.dart';
import 'package:ems/controller/data_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/events_feed_widget.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  DataController dataController = Get.find<DataController>();
  late AnimationController _animationController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Create the animation for the line width
    _lineAnimation = Tween<double>(begin: 0.0, end: 100.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.03),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(),

                Text(
                  "What's Going on today?",
                  style: GoogleFonts.raleway(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                // Animated Line Widget
                AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (context, child) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      width: _lineAnimation.value,
                      height: 2,
                      color: Colors.blue, // Line color
                    );
                  },
                ),
                EventsFeed(),
                Obx(
                      () => dataController.isUsersLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : EventsIJoined(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
