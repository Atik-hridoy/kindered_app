import 'package:get/get.dart';
import 'package:kindered_app/modules/location/location_controller.dart';



class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationController>(() => LocationController());
  }
}
