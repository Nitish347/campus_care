import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DevicePosters extends StatefulWidget {
  const DevicePosters({super.key});

  @override
  State<DevicePosters> createState() => _DevicePostersState();
}

class _DevicePostersState extends State<DevicePosters> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              )
            ]),
        child: Column(
          children: [
            Container(

              height: 0.8.sh,
              width: 1.sw,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Poster here",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Divider(
              color: Colors.grey.shade300,
            ),
            SizedBox(
              height: 10.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "View More",
                  style: TextStyle(color: Colors.teal, fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 8.r,
                  child: Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: Colors.white,
                    size: 15.sp,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
    );
  }
}
