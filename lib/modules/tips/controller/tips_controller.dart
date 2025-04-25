import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/energy_tips.dart';
import '../service/tips_service.dart';

class TipsController extends GetxController {
  final TipsService _tipsService = TipsService();
  final RxBool isLoading = false.obs;
  final RxList<EnergyTip> tips = <EnergyTip>[].obs;
  final Rx<TipCategory?> selectedCategory = Rx<TipCategory?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchTips();
  }

  Future<void> fetchTips() async {
    try {
      isLoading.value = true;
      final data = await _tipsService.getTips();
      tips.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tips');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBookmark(EnergyTip tip) async {
    try {
      await _tipsService.toggleBookmark(tip.id);
      final index = tips.indexWhere((t) => t.id == tip.id);
      if (index != -1) {
        tips[index] = EnergyTip(
          id: tip.id,
          title: tip.title,
          description: tip.description,
          category: tip.category,
          savingEstimate: tip.savingEstimate,
          isBookmarked: !tip.isBookmarked,
          steps: tip.steps,
          createdAt: tip.createdAt,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update bookmark');
    }
  }

  void setCategory(TipCategory? category) {
    selectedCategory.value = category;
  }

  List<EnergyTip> get filteredTips {
    if (selectedCategory.value == null) return tips;
    return tips.where((tip) => tip.category == selectedCategory.value).toList();
  }

  Color getCategoryColor(TipCategory category) {
    switch (category) {
      case TipCategory.appliances:
        return Colors.blue;
      case TipCategory.lighting:
        return Colors.yellow.shade700;
      case TipCategory.heating:
        return Colors.red;
      case TipCategory.cooling:
        return Colors.lightBlue;
      case TipCategory.general:
        return Colors.green;
    }
  }

  IconData getCategoryIcon(TipCategory category) {
    switch (category) {
      case TipCategory.appliances:
        return Icons.electrical_services;
      case TipCategory.lighting:
        return Icons.lightbulb;
      case TipCategory.heating:
        return Icons.whatshot;
      case TipCategory.cooling:
        return Icons.ac_unit;
      case TipCategory.general:
        return Icons.tips_and_updates;
    }
  }
}
