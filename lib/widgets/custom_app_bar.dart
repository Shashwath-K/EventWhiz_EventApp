import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_color.dart';
import '../views/notification_screen/notification_screen.dart';
import 'my_widgets.dart';

Widget CustomAppBar(){

  return Container(
    margin: EdgeInsets.symmetric(vertical: 15),
    child: Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            child: myText(
              text: '  EventWhiz!',
              style: TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Get.to(() => UserNotificationScreen());
                },
                child: Container(
                  width: 24,
                  height: 22,
                  child: Image.asset('assets/Frame.png'),
                ),
              ),
              SizedBox(
                width: Get.width * 0.04,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
