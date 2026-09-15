import 'package:shared_preferences/shared_preferences.dart';

abstract interface class OnboardingRepository {
  bool get isCompleted;

  Future<void> markCompleted();
}

class LocalOnboardingRepository implements OnboardingRepository {
  LocalOnboardingRepository(this._preferences);

  static const _completedKey = 'onboarding_completed';
  final SharedPreferences _preferences;

  @override
  bool get isCompleted => _preferences.getBool(_completedKey) ?? false;

  @override
  Future<void> markCompleted() {
    return _preferences.setBool(_completedKey, true);
  }
}
