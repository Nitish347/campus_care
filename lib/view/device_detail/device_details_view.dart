// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:campus_care/data/dummy_data.dart';
// import 'package:campus_care/models/device_model.dart';
// import 'package:campus_care/utils/app_colors.dart';
// import 'package:campus_care/view/device_detail/controller/device_detail_controller.dart';
// import 'package:campus_care/view/device_detail/widgets/custom_carousel.dart';
// import 'package:campus_care/view/device_detail/widgets/device_posters.dart';
// import 'package:campus_care/view/device_detail/widgets/device_specification.dart';
// import 'package:campus_care/view/device_detail/widgets/price_modal_sheet.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:get/get.dart';
// import 'package:campus_care/widgets/arrow_button.dart';
// import 'package:campus_care/widgets/custom_button.dart';
//
// class DeviceDetailsView extends StatefulWidget {
//   final Device device;
//
//   const DeviceDetailsView({super.key, required this.device});
//
//   @override
//   State<DeviceDetailsView> createState() => _DeviceDetailsViewState();
// }
//
// class _DeviceDetailsViewState extends State<DeviceDetailsView> {
//   final controller = Get.put(DeviceDetailController());
// @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     controller.onInitial(widget.device);
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//         appBar: AppBar(
//           leadingWidth: 50,
//           backgroundColor: Colors.white,
//           // leading: SizedBox(
//           //     height: 15.h,
//           //     width: 15.w,
//           //     child: ArrowButton(onTap: (){})),
//           centerTitle: true,
//           title:  Text(widget.device.name,style: GoogleFonts.poppins(
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//             fontSize: 24.sp,
//           ),),
//         ),
//       bottomSheet: Container(
//         color: Colors.white,
//         height: 0.25.sh,
//         width: 1.sw,
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     height: 0.13.sh,
//                     padding: EdgeInsets.all(12.w),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Device Price",
//                           style: GoogleFonts.poppins(
//                             color: Colors.black,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 14.sp,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         Text(
//                           "₹ ${widget.device.devicePrice}",
//                           style: GoogleFonts.poppins(
//                             color: Colors.black,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 18.sp,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         Text(
//                           "Monthly ₹${widget.device.monthlyDeduction}",
//                           style: GoogleFonts.poppins(
//                             color: Colors.grey.withOpacity(0.5),
//                             fontWeight: FontWeight.w500,
//                             fontSize: 11.sp,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(width: 12.w),
//
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       showModalBottomSheet(
//                         context: context,
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                         builder: (context) => const PriceModalSheet(),
//                       );
//                     },
//                     child: Container(
//                       height: 0.13.sh,
//                       padding: EdgeInsets.all(12.w),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.green),
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   "EFFECTIVE PRICE",
//                                   style: GoogleFonts.poppins(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 12.sp,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               CircleAvatar(
//                                 backgroundColor: Colors.teal,
//                                 radius: 8.r,
//                                 child: Icon(
//                                   Icons.arrow_forward_ios_rounded,
//                                   color: Colors.white,
//                                   size: 10.sp,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             "₹ ${widget.device.effectivePrice}",
//                             style: GoogleFonts.poppins(
//                               color: Colors.teal,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 18.sp,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           Text(
//                             "See Impact in net-salary",
//                             style: GoogleFonts.poppins(
//                               color: Colors.teal,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 11.sp,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             CustomButton(
//               onTap: () {},
//               text: "Add to Cart",
//             ),
//           ],
//         ),
//       ),
//         body: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 color: AppColors.shippingBannerText.withOpacity(0.1),
//                 padding: EdgeInsets.symmetric(vertical: 14),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       PhosphorIcons.truck(),
//                       color: AppColors.shippingBannerText,
//                       size: 25.0,
//                     ),
//                     SizedBox(
//                       width: 10.w,
//                     ),
//                     Text(
//                       "Shipping starts from 19th September onwards",
//                       style: GoogleFonts.poppins(
//                           fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.shippingBannerText),
//                     )
//                   ],
//                 ),
//               ),
//               Container(
//                 color: Colors.white,
//                 // height: 0.4.sh,
//                 child: DeviceCarousel(),
//               ),
//               SizedBox(height: 20.h,),
//               Container(
//                 color: AppColors.darkGreen,
//                 padding: EdgeInsets.symmetric(vertical: 18),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.shield_rounded,
//                       color: Colors.lightGreenAccent,
//                     ),
//                     SizedBox(
//                       width: 10.w,
//                     ),
//                     Text(
//                       "Protect with Tortoise Corporate Care",
//                       style: GoogleFonts.poppins(
//                           fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.lightGreenAccent),
//                     )
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.all(20.w),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       height: 20.h,
//                     ),
//                     Text(
//                       "FINISH",
//                       style:
//                       TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.grey.withOpacity(0.7)),
//                     ),
//                     SizedBox(
//                       height: 3.h,
//                     ),
//                     Text(
//                       "Pick s color",
//                       style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, color: Colors.black),
//                     ),
//                     SizedBox(
//                       height: 25.h,
//                     ),
//                     Wrap(
//                       runSpacing: 10.h,
//                       children: List.generate(widget.device.colorOptions.length, (index) {
//                         return Padding(
//                           padding: EdgeInsets.only(right: 10.w),
//                           child: GestureDetector(
//                             onTap: () {
//                               controller.onSelectColor(widget.device.colorOptions[index]);
//                             },
//                             child: Obx(() {
//                               return CircleAvatar(
//                                 radius: 28.r,
//                                 backgroundColor: controller.selectedColor.value == widget.device.colorOptions[index]
//                                     ? Colors.green
//                                     : Colors.white,
//                                 child: CircleAvatar(
//                                   radius: 25.r,
//                                   backgroundColor: Colors.white,
//                                   child: CircleAvatar(
//                                     radius: 23.r,
//                                     backgroundColor: Color(int.parse(widget.device.colorOptions[index])),
//                                   ),
//                                 ),
//                               );
//                             }),
//                           ),
//                         );
//                       }),
//                     ),
//                     SizedBox(
//                       height: 30.h,
//                     ),
//                     Text(
//                       "STORAGE",
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.grey.withOpacity(0.7),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 3,
//                     ),
//                     Text(
//                       "How much space do you need?",
//                       style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500, color: Colors.black),
//                     ),
//                     SizedBox(
//                       height: 25.h,
//                     ),
//                     Obx(() {
//                       return Wrap(
//                         children: List.generate(widget.device.storageOptions.length, (index) {
//                           bool isSelected =
//                               controller.selectedStorage.value == widget.device.storageOptions[index];
//                           return GestureDetector(
//
//                             onTap: (){
//                               controller.onSelectStorage(widget.device.storageOptions[index]);
//                             },
//                             child: Container(
//                               width: 120.w,
//                               margin: EdgeInsets.all(10).copyWith(left: 0),
//                               padding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300, width: 2.w),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 9.r,
//                                     backgroundColor: isSelected ? Colors.green : Colors.grey.shade300,
//                                     child: CircleAvatar(
//                                       radius: isSelected ?  3.r :  7.r,
//                                       backgroundColor: Colors.white,
//                                     ),
//                                   ),
//                                   Text(
//                                     widget.device.storageOptions[index],
//                                     style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//
//               DeviceSpecificationCard(specifications: widget.device.deviceSpecifications,),
//               DevicePosters(),
//               SizedBox(height: 0.3.sh,)
//             ],
//           ),
//         ));
//   }
// }
