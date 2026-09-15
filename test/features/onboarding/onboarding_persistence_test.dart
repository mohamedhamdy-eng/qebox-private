import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/features/onboarding/repositories/onboarding_repository.dart';
import 'package:qebox_private/features/onboarding/viewmodels/onboarding_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('remembers that onboarding was skipped', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalOnboardingRepository(preferences);
    final viewModel = OnboardingViewModel(repository);

    expect(viewModel.state, isFalse);
    await viewModel.complete();

    final restoredViewModel = OnboardingViewModel(
      LocalOnboardingRepository(preferences),
    );
    expect(restoredViewModel.state, isTrue);
  });
}
