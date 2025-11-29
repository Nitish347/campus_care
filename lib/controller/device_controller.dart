import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import 'package:campus_care/data/dummy_data.dart';
import 'package:campus_care/models/device_model.dart';


class DeviceDataController extends GetxController {
  RxList<Device> devices = <Device>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    setDevices();
  }

  void setDevices() {
    devices.value = deviceData.map((json) => Device.fromJson(json)).toList();
  }

  List<Device> getDevicesByBrand(String brandName) {
    return devices.where((device) => device.brand == brandName).toList();
  }
  Device getDeviceByName(String deviceName) {
    return devices.firstWhere((device) => device.name == deviceName);
  }

}