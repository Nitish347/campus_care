import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArrowButton extends StatelessWidget {
  final Function() onTap;
  const ArrowButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 28.h,
        width: 28.w,
        padding: EdgeInsets.only(left: 5),
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 12.sp,
        ),
      ),
    );
  }
}
