enum TipCategory {
  appliances,
  lighting,
  heating,
  cooling,
  general,
}

class EnergyTip {
  final int id;
  final String title;
  final String description;
  final TipCategory category;
  final String savingEstimate;
  final bool isBookmarked;
  final List<String> steps;
  final DateTime createdAt;

  EnergyTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.savingEstimate,
    required this.isBookmarked,
    required this.steps,
    required this.createdAt,
  });
}

