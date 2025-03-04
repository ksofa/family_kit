class TestData {
  static Future<void> createTestData() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    // Создаем тестовую аптечку
    final kit = await FirstAidKitService.createKit(
      'Тестовая аптечка',
      'Для тестирования',
    );

    // Добавляем тестовые лекарства
    await MedicineService.addMedicine(Medicine(
      name: 'Парацетамол',
      activeSubstance: 'Парацетамол',
      quantity: 10,
      unit: 'таблетки',
      expirationDate: DateTime.now().add(Duration(days: 365)),
      firstAidKitId: kit.id,
    ));
    // Добавить еще тестовых данных...
  }
} 