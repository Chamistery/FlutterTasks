import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/bloc/liked_cats_cubit.dart';
import 'details_screen.dart';

class LikedCatsScreen extends StatelessWidget {
  const LikedCatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лайкнутые котики')),
      body: Column(
        children: [
          // Количество котиков
          BlocBuilder<LikedCatsCubit, LikedCatsState>(
            builder: (context, state) {
              if (state.allCats.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  state.selectedBreed == null
                      ? 'Все котики: ${state.filteredCats.length}'
                      : 'Котиков породы ${state.selectedBreed}: '
                          '${state.filteredCats.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          // Фильтр по породе
          BlocBuilder<LikedCatsCubit, LikedCatsState>(
            builder: (context, state) {
              if (state.allCats.isEmpty) {
                return const SizedBox.shrink();
              }
              final breeds =
                  state.allCats.map((cat) => cat.breed).toSet().toList()
                    ..sort();
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text('Фильтр по породе: '),
                    DropdownButton<String>(
                      value: state.selectedBreed ?? '',
                      items: [
                        const DropdownMenuItem(value: '', child: Text('Все')),
                        ...breeds.map(
                          (breed) => DropdownMenuItem(
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
                ),
              );
            },
          ),
          const Divider(),
          // Список избранных котиков
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
                        subtitle: Text(
                          cat.likedAt != null
                              ? 'Лайк: ${cat.likedAt!.toLocal()}'
                              : '',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<LikedCatsCubit>().removeCat(cat);
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => DetailsScreen(cat: cat),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
