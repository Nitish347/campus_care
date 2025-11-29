import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/controller/device_controller.dart';
import 'package:campus_care/routes/app_routes.dart';
import 'package:campus_care/view/search/controller/search_controller.dart';
import 'package:campus_care/view/search/widgets/brand_card.dart';
import 'package:campus_care/view/search/widgets/device_card.dart';
import 'dart:convert';
import 'package:campus_care/data/dummy_data.dart';
import 'package:campus_care/models/brand_model.dart';
import 'package:campus_care/models/device_model.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  String selectedBrand = 'Apple';
  final TextEditingController searchController = TextEditingController();

  List<BrandModel> brands = [];
  List<Device> devices = [];

  @override
  void initState() {
    super.initState();
    loadData();
    searchController.text = 'Apple';
    controller.selectedBrand.value = 'Apple';
  }

  void loadData() {
    final List<dynamic> brandsData = jsonDecode(brandsJson);

    setState(() {
      brands = brandsData.map((json) => BrandModel.fromJson(json)).toList();
    });
  }

  final controller = Get.find<BrandSearchController>();
  final deviceDataController = Get.find<DeviceDataController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        bottom: PreferredSize(
            preferredSize: Size(200, 50),
            child: Container(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                    ),
                    Container(
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
                    SizedBox(
                      width: 30.w,
                    ),
                    Expanded(
                        child: TextField(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(20),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 28.sp,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.black, width: 1.5)),
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.black, width: 1.5))),
                    )),
                    SizedBox(
                      width: 20.w,
                    ),
                  ],
                ),
              ),
            )),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.h),
                Text(
                  'Search from popular brands',
                  style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.black),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: brands.map((brand) {
                    return Expanded(child: Obx(() {
                      return BrandCard(
                          isSelected: controller.selectedBrand.value == brand.name,
                          icon: brand.icon,
                          brandName: brand.name,
                          onTap: (val) {
                            controller.onSelectBrand(val);
                            // print(controller.selectedBrand?.value.name);
                          });
                    }));
                  }).toList(),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available devices',
                    style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: 1.sw,
                        child: Obx(() {
                          return Wrap(
                            runSpacing: 10.h,
                            spacing: 10.w,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.center,
                            children: List.generate(
                                deviceDataController.getDevicesByBrand(controller.selectedBrand.value).length, (index) {
                              final device =
                                  deviceDataController.getDevicesByBrand(controller.selectedBrand.value)[index];
                              return DeviceCard(
                                name: device.name,
                                icon: device.primaryImage,
                                onTap: () {
                                  Get.toNamed(AppRoutes.deviceDetailsView, arguments: {"device": device});
                                },
                              );
                            }),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
