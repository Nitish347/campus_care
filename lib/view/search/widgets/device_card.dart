import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class DeviceCard extends StatelessWidget {
  final String icon;
  final String name;
  final Function onTap;
  const DeviceCard({super.key, required this.name, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onTap.call();
      },

      child: Container(
        height: 130.h,
        width: 0.43.sw,
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
            ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [


            Container(
              width: 80,
              height: 80,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child:     Image(image: NetworkImage("https://m.media-amazon.com/images/I/71D3JsltoLL.jpg")),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
