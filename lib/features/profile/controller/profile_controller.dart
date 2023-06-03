import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthomeuione/core/providers/refresh_provider.dart';
import 'package:smarthomeuione/features/profile/repository/profile_repository.dart';

final profileControllerProvider = StateNotifierProvider<ProfileController, bool>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return ProfileController(
    profileRepository: profileRepository,
    ref: ref,
  );
});

final getGraphDataProvider = StreamProvider((ref) {
  return ref.read(profileControllerProvider.notifier).getGraphDataStream();
});

class ProfileController extends StateNotifier<bool> {
  final ProfileRepository _profileRepository;
  final Ref _ref;
  ProfileController({
    required ProfileRepository profileRepository,
    required Ref ref,
  })  : _profileRepository = profileRepository,
        _ref = ref,
        super(false);

  Stream<Map<String, dynamic>> getGraphDataStream() {
    return _profileRepository.getGraphDataStream();
  }
}
