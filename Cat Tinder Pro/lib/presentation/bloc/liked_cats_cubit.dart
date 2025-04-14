import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/cat.dart';

class LikedCatsState {
  final List<Cat> allCats;
  final List<Cat> filteredCats;
  final String? selectedBreed;

  LikedCatsState({
    required this.allCats,
    required this.filteredCats,
    this.selectedBreed,
  });

  factory LikedCatsState.initial() {
    return LikedCatsState(allCats: [], filteredCats: [], selectedBreed: null);
  }

  LikedCatsState copyWith({
    List<Cat>? allCats,
    List<Cat>? filteredCats,
    String? selectedBreed,
  }) {
    return LikedCatsState(
      allCats: allCats ?? this.allCats,
      filteredCats: filteredCats ?? this.filteredCats,
      selectedBreed: selectedBreed,
    );
  }
}

class LikedCatsCubit extends Cubit<LikedCatsState> {
  LikedCatsCubit() : super(LikedCatsState.initial());

  void addCat(Cat cat) {
    final updatedCat = cat.copyWith(likedAt: DateTime.now());
    final newList = List<Cat>.from(state.allCats)..add(updatedCat);
    emit(
      state.copyWith(
        allCats: newList,
        filteredCats: _applyFilter(newList, state.selectedBreed),
        selectedBreed: state.selectedBreed,
      ),
    );
  }

  void removeCat(Cat cat) {
    final newList = List<Cat>.from(state.allCats)..remove(cat);
    final currentBreed = state.selectedBreed;
    final breedStillExists =
        currentBreed != null && newList.any((c) => c.breed == currentBreed);
    emit(
      state.copyWith(
        allCats: newList,
        filteredCats: _applyFilter(
          newList,
          breedStillExists ? currentBreed : null,
        ),
        selectedBreed: breedStillExists ? currentBreed : null,
      ),
    );
  }

  void filterByBreed(String? breed) {
    final selectedBreed = breed == '' ? null : breed;
    final breedExists =
        selectedBreed != null &&
        state.allCats.any((cat) => cat.breed == selectedBreed);
    emit(
      state.copyWith(
        selectedBreed: breedExists ? selectedBreed : null,
        filteredCats: _applyFilter(
          state.allCats,
          breedExists ? selectedBreed : null,
        ),
      ),
    );
  }

  List<Cat> _applyFilter(List<Cat> cats, String? breed) {
    if (breed == null) return cats;
    return cats.where((cat) => cat.breed == breed).toList();
  }
}
