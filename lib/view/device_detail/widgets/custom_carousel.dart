import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeviceCarousel extends StatefulWidget {
  const DeviceCarousel({super.key});

  @override
  State<DeviceCarousel> createState() => _DeviceCarouselState();
}

class _DeviceCarouselState extends State<DeviceCarousel> {
  final PageController _pageController = PageController(
    viewportFraction: 1.0, // ✅ Shows ONLY one full image
  );
  int currentIndex = 0;

  final List<String> images = [
    "https://m.media-amazon.com/images/I/71D3JsltoLL.jpg",
    "https://m.media-amazon.com/images/I/71D3JsltoLL.jpg",
    "https://m.media-amazon.com/images/I/71D3JsltoLL.jpg",
    "https://m.media-amazon.com/images/I/71D3JsltoLL.jpg",
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ✅ Full-width carousel with no side peeks
        SizedBox(
          height:300.h,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: 7.w,
                height: 7.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == index
                      ? Colors.white
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}