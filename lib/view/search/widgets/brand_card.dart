import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BrandCard extends StatelessWidget {
 final bool isSelected;
final  String icon;
 final String brandName;
 final Function(String) onTap;
  const BrandCard({super.key, required this.isSelected, required this.icon, required this.brandName, required this.onTap});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        onTap.call(brandName);

      },
      child: Container(

        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade100 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            SizedBox(
                height: 30.h,
                width: 70.w,
                child: Image(image: AssetImage(icon))),
            // const SizedBox(height: 8),
            Text(
              brandName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: Colors.black
              ),
            ),
          ],
        ),
      ),
    );
  }
}
