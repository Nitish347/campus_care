
import 'package:get/get.dart';

class BrandSearchController extends GetxController {
 RxString selectedBrand = ''.obs;

  onSelectBrand(String brand) {
    selectedBrand.value = brand;
  }


}