import 'package:get/get.dart';
import 'package:campus_care/controller/device_controller.dart';
import 'package:campus_care/view/device_detail/controller/device_detail_controller.dart';
import 'package:campus_care/view/search/controller/search_controller.dart';

class ControllerDi {

registerControllers() {
    Get.lazyPut(() => BrandSearchController());
    Get.lazyPut(() => DeviceDataController());
    Get.lazyPut(() => DeviceDetailController());

  }

}