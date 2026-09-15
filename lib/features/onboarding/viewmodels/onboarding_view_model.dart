import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/onboarding_repository.dart';

class OnboardingViewModel extends StateNotifier<bool> {
  OnboardingViewModel(this._repository) : super(_repository.isCompleted);

  final OnboardingRepository _repository;

  Future<void> complete() async {
    await _repository.markCompleted();
    state = true;
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingViewModel, bool>(
  (ref) => throw UnimplementedError(
    'onboardingProvider must be overridden with a repository in main.',
  ),
);
