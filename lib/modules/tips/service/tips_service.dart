import '../model/energy_tips.dart';

class TipsService {
  Future<List<EnergyTip>> getTips() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    return [
      EnergyTip(
        id: 1,
        title: 'Optimize Your AC Temperature',
        description:
        'Setting your AC temperature just 1°C higher can lead to significant energy savings.',
        category: TipCategory.cooling,
        savingEstimate: '10-15%',
        isBookmarked: true,
        steps: [
          'Increase temperature by 1°C',
          'Use ceiling fans when possible',
          'Clean AC filters regularly',
          'Close windows and doors',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      EnergyTip(
        id: 2,
        title: 'Smart Lighting Habits',
        description:
        'Make the most of natural light and switch to LED bulbs for better efficiency.',
        category: TipCategory.lighting,
        savingEstimate: '5-8%',
        isBookmarked: false,
        steps: [
          'Replace old bulbs with LEDs',
          'Use natural light when possible',
          'Install motion sensors',
          'Turn off lights when leaving',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      EnergyTip(
        id: 3,
        title: 'Efficient Appliance Usage',
        description:
        'Using appliances during off-peak hours can reduce your energy costs.',
        category: TipCategory.appliances,
        savingEstimate: '12-18%',
        isBookmarked: false,
        steps: [
          'Run appliances during off-peak hours',
          'Use full loads for washers',
          'Regular maintenance checks',
          'Upgrade to energy-efficient models',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  Future<void> toggleBookmark(int tipId) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }
}

