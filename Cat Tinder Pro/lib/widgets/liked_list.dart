import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/bloc/liked_cats_cubit.dart';

class LikedList extends StatefulWidget {
  const LikedList({super.key});

  @override
  State<LikedList> createState() => _LikedListState();
}

class _LikedListState extends State<LikedList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Количество котиков
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<LikedCatsCubit, LikedCatsState>(
            builder: (context, state) {
              if (state.allCats.isEmpty) {
                return const SizedBox.shrink();
              }
              return Text(
                state.selectedBreed == null
                    ? 'Все котики: ${state.filteredCats.length}'
                    : 'Котиков породы ${state.selectedBreed}: '
                        '${state.filteredCats.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        // Фильтр по породе
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<LikedCatsCubit, LikedCatsState>(
            builder: (context, state) {
              if (state.allCats.isEmpty) {
                return const SizedBox.shrink();
              }
              final breeds =
                  state.allCats.map((cat) => cat.breed).toSet().toList()
                    ..sort();
              return Row(
                children: [
                  const Text('Фильтр по породе: '),
                  DropdownButton<String>(
                    value: state.selectedBreed ?? '',
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Все')),
                      ...breeds.map(
                        (breed) => DropdownMenuItem<String>(
                          value: breed,
                          child: Text(breed),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      context.read<LikedCatsCubit>().filterByBreed(value);
                    },
                  ),
                ],
              );
            },
          ),
        ),
        const Divider(),
        Expanded(
          child: BlocBuilder<LikedCatsCubit, LikedCatsState>(
            builder: (context, state) {
              if (state.filteredCats.isEmpty) {
                return const Center(child: Text('Нет лайкнутых котиков'));
              }
              return ListView.builder(
                itemCount: state.filteredCats.length,
                itemBuilder: (context, index) {
                  final cat = state.filteredCats[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Image.network(
                        cat.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(
                            width: 60,
                            height: 60,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                      title: Text(cat.breed),
                      subtitle:
                          cat.likedAt != null
                              ? Text('Лайк: ${cat.likedAt!.toLocal()}')
                              : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context.read<LikedCatsCubit>().removeCat(cat);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
