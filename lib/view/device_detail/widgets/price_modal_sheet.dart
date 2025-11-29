// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:campus_care/utils/app_colors.dart';
// import 'package:campus_care/widgets/custom_button.dart';
// import 'package:dotted_line/dotted_line.dart';
// class PriceModalSheet extends StatefulWidget {
//   const PriceModalSheet({super.key});
//
//   @override
//   State<PriceModalSheet> createState() => _PriceModalSheetState();
// }
//
// class _PriceModalSheetState extends State<PriceModalSheet> {
//
//   bool showMoreInfo = false;
//
//
//   @override
//   Widget build(BuildContext context) {
//
//
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//       ),
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'EFFECTIVE PRICE',
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade400,
//               letterSpacing: 1.2,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'The effective price is the device\'s cost after savings, based on your payroll structure',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16.sp, color: Colors.black, height: 1.5, fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 32),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.shade300,
//                     blurRadius: 10,
//                     offset: Offset(0, 0),
//                     spreadRadius: 0,
//                   )
//                 ],
//                 border: Border.all(color: Colors.grey.shade300,width: 1)),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Tax slab',
//                       style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
//                     ),
//                     Row(
//                       children: [
//                         Text("30%", style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey[800],
//                         ),),
//                         Icon(Icons.arrow_drop_down_outlined)
//                       ],
//                     )
//
//                   ],
//                 ),
//                  SizedBox(height: 15.h
//                 ),
//                 DottedLine(
//                   direction: Axis.horizontal,
//                   alignment: WrapAlignment.center,
//                   lineLength: double.infinity,
//                   lineThickness: 1.5,
//                   dashLength: 6.0,
//                   dashColor: Colors.grey.shade300,
//
//                   dashRadius: 10.0,
//                   dashGapLength: 6.0,
//                   dashGapColor: Colors.transparent,
//                   dashGapRadius: 0.0,
//                 ),
//                 SizedBox(height: 15.h
//                 ),
//                 Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Effective price of the device',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.teal,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Price calculation based on selected\ntax slab',
//                               style: TextStyle(
//                                 fontSize: 14.sp,
//                                 color: Colors.grey.shade500,
//                                 height: 1.4,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Text(
//                           '₹ 9248*',
//                           style: TextStyle(
//                             fontSize: 18.sp,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.teal,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 15),
//                     DottedLine(
//                       direction: Axis.horizontal,
//                       alignment: WrapAlignment.center,
//                       lineLength: double.infinity,
//                       lineThickness: 1.5,
//                       dashLength: 6.0,
//                       dashColor: Colors.grey.shade300,
//
//                       dashRadius: 10.0,
//                       dashGapLength: 6.0,
//                       dashGapColor: Colors.transparent,
//                       dashGapRadius: 0.0,
//                     ),
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Impact in monthly in-hand',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey[800],
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'You monthly in-hand salary will be\nreduced by this amount',
//                               style: TextStyle(
//                                 fontSize: 14.sp,
//                                 color: Colors.grey[500],
//                                 height: 1.4,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Text(
//                           '₹777*',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//
//                  SizedBox(height: 15.h),
//                 Divider(
//                   color: Colors.grey.shade300,
//                 ),
//                 InkWell(
//                   onTap: () {
//                     setState(() {
//                       showMoreInfo = !showMoreInfo;
//                     });
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Know more',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: AppColors.teal,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Icon(
//                           showMoreInfo ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_sharp,
//                           color: AppColors.teal,
//                           size: 35.sp,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 if (showMoreInfo) ...[
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '* The effective price and monthly impact are calculated based on tax savings under Section 80C and Section 17(2) of the Income Tax Act. The actual benefit may vary based on your complete salary structure and existing tax-saving investments.',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                         height: 1.5,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           SizedBox(
//             height: 50.h,
//           ),
//           CustomButton(
//               onTap: () {
//                 Get.back();
//               },
//               text: "Okay! Understood"),
//           SizedBox(height: 20.h),
//         ],
//       ),
//     );
//   }
// }
