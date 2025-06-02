String getDefaultMealCategoryByTime() {
  final now = DateTime.now().toUtc().subtract(const Duration(hours: 6)); // El Salvador (UTC-6)

  final hour = now.hour;
  if (hour >= 5 && hour < 11) {
    return 'Desayuno';
  } else if (hour >= 11 && hour < 15) {
    return 'Almuerzo';
  } else if (hour >= 18 && hour < 22) {
    return 'Cena';
  } else {
    return 'Otro';
  }
}
DateTime getStartOfTodayAt4AM() {
  // Llevamos ahora a UTC y restamos 6h
  final nowUtc = DateTime.now().toUtc().subtract(const Duration(hours: 6));
  final today4Utc = DateTime(nowUtc.year, nowUtc.month, nowUtc.day, 4);
  final startUtc = nowUtc.isBefore(today4Utc)
      ? today4Utc.subtract(const Duration(days: 1))
      : today4Utc;
  // Volvemos a hora local de El Salvador (sumamos 6h)
  return startUtc.add(const Duration(hours: 6));
}