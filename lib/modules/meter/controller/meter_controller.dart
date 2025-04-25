import 'package:get/get.dart';
import '../../../core/core/utilities/logs.dart';
import '../../auth/services/auth_service.dart';
import '../model/meter.dart';


class MeterController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final Rx<Meter?> meter = Rx<Meter?>(null);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMeterInfo();
  }

  Future<void> fetchMeterInfo() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      Meter? fetchedMeter = await _firebaseService.getMeterInfo();
      meter.value = fetchedMeter;
    } catch (e) {
      errorMessage.value = 'Failed to fetch meter info: $e';
      DevLogs.logError('Fetch meter info error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMeterInfo(
      String meterNumber,
      double currentReading,
      String provider,
      ) async {
    try {
      isLoading.value = true;

      Meter updatedMeter = Meter(
        meterNumber: meterNumber,
        currentReading: currentReading,
        lastReadingDate: DateTime.now(),
        provider: provider,
        monthlyAverage: meter.value?.monthlyAverage ?? 0.0,
        yearlyTotal: meter.value?.yearlyTotal ?? 0.0,
      );

      await _firebaseService.updateMeterInfo(updatedMeter);
      meter.value = updatedMeter;
    } catch (e) {
      DevLogs.logError('Update meter info error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
