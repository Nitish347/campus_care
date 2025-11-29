import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:campus_care/models/device_model.dart';

class DeviceSpecificationCard extends StatelessWidget {
  final List<DeviceSpecification> specifications;
  const DeviceSpecificationCard({super.key, required this.specifications});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SPECIFICATION",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
          ),
          SizedBox(
            height: 20.h,
          ),
          Container(
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
                Column(
                    children: List.generate(specifications.length, (index) {
                  return specificationRow(name: specifications[index].name, specName: specifications[index].value);
                })),
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
                      "More details",
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
        ],
      ),
    );
  }
}

Widget specificationRow({required String name, required String specName}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          getSpecIcon(name),
          size: 22.sp,
          color: Colors.black87,
        ),
        SizedBox(
          width: 10.w,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500, fontSize: 16.sp),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              specName,
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500, fontSize: 14.sp),
            ),
          ],
        )
      ],
    ),
  );
}

IconData getSpecIcon(String specName) {
  final name = specName.toLowerCase();

  if (name.contains('display')) {
    return Icons.smartphone;
  }

  if (name.contains('chip')) {
    return Icons.memory;
  }

  if (name.contains('camera')) {
    return Icons.camera_alt_outlined;
  }

  if (name.contains('battery')) {
    return CupertinoIcons.battery_0;
  }

  if (name.contains('storage')) {
    return Icons.storage;
  }
  if (name.contains('ram')) {
    return Icons.memory;
  }

  return Icons.info_outline;
}
