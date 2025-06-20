import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelter_partner/models/animal.dart';
import 'package:shelter_partner/models/log.dart';
import 'package:shelter_partner/repositories/put_back_confirmation_repository.dart';
import 'package:shelter_partner/view_models/shelter_details_view_model.dart';
import 'package:shelter_partner/providers/firebase_providers.dart';

class PutBackConfirmationViewModel extends StateNotifier<Animal> {
  final PutBackConfirmationRepository _repository;
  final Ref ref;

  PutBackConfirmationViewModel(this._repository, this.ref, Animal animal)
    : super(animal);

  Future<void> putBackAnimal(Animal animal, Log log) async {
    final logger = ref.read(loggerServiceProvider);
    logger.debug("Putting back animal with log: ${log.toMap()}");
    // Get shelter ID from shelterDetailsViewModelProvider
    final shelterDetailsAsync = ref.read(shelterDetailsViewModelProvider);
    // final enrichmentViewModel = ref.read(enrichmentViewModelProvider.notifier);

    // enrichmentViewModel.updateAnimalOptimistically(animal.copyWith(inKennel: true));
    try {
      await _repository.putBackAnimal(
        animal,
        shelterDetailsAsync.value!.id,
        log,
      );
      // Optionally, update the state if needed
    } catch (e, stackTrace) {
      // Handle error
      final logger = ref.read(loggerServiceProvider);
      logger.error('Failed to put back animal', e, stackTrace);
    }
  }

  Future<void> deleteLastLog(Animal animal) async {
    // Get shelter ID from shelterDetailsViewModelProvider
    final shelterDetailsAsync = ref.read(shelterDetailsViewModelProvider);

    try {
      await _repository.deleteLastLog(animal, shelterDetailsAsync.value!.id);
      // Optionally, update the state if needed
    } catch (e, stackTrace) {
      // Handle error
      final logger = ref.read(loggerServiceProvider);
      logger.error('Failed to delete last log', e, stackTrace);
    }
  }
}

// Provider for AddNoteViewModel
final putBackConfirmationViewModelProvider =
    StateNotifierProvider.family<PutBackConfirmationViewModel, Animal, Animal>((
      ref,
      animal,
    ) {
      final repository = ref.watch(putBackConfirmationRepositoryProvider);
      return PutBackConfirmationViewModel(repository, ref, animal);
    });
