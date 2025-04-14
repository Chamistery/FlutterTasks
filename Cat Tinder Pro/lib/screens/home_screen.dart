import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../di/di.dart';
import '../services/cat_api_service.dart';
import '../widgets/dislike_button.dart';
import '../widgets/like_button.dart';
import '../presentation/bloc/liked_cats_cubit.dart';
import 'details_screen.dart';
import 'liked_cats_screen.dart';
import '../models/cat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final CatApiService _apiService = getIt<CatApiService>();
  final List<Cat> _catQueue = [];
  Cat? _currentCat;
  double _progress = 0.0;

  Offset _cardOffset = Offset.zero;
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  bool _isSwiped = false;

  double _likeScale = 1.0;
  double _dislikeScale = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animationController.addListener(() {
      setState(() {
        _cardOffset = _animation.value;
      });
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_isSwiped) {
          if (_cardOffset.dx > 0) {
            context.read<LikedCatsCubit>().addCat(_currentCat!);
          }
          Future.delayed(Duration.zero, _loadNextCat);
        }
        _resetCard();
      }
    });
    _loadInitialCats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _resetCard() {
    _animationController.reset();
    _cardOffset = Offset.zero;
    _isSwiped = false;
    if (mounted) setState(() {});
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ошибка'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ОК'),
              ),
            ],
          ),
    );
  }

  Future<void> _loadInitialCats() async {
    try {
      setState(() {
        _progress = 0.3;
      });
      final firstCat = await _apiService.fetchRandomCat();
      _catQueue.add(firstCat);
      setState(() {
        _progress = 1.0;
      });
    } catch (e) {
      debugPrint('Error loading first cat: $e');
      if (mounted) {
        _showErrorDialog('Не удалось загрузить котика: $e');
      }
    }
    for (var i = 0; i < 2; i++) {
      try {
        final newCat = await _apiService.fetchRandomCat();
        _catQueue.add(newCat);
      } catch (e) {
        debugPrint('Error preloading cat: $e');
      }
    }
    _setNextCat();
  }

  Future<void> _preloadCats() async {
    try {
      for (var i = 0; i < 3; i++) {
        final newCat = await _apiService.fetchRandomCat();
        if (mounted) {
          setState(() {
            _catQueue.add(newCat);
          });
        }
      }
    } catch (e) {
      debugPrint('Error preloading cats: $e');
      if (mounted) {
        _showErrorDialog('Не удалось предзагрузить котиков: $e');
      }
    }
  }

  void _setNextCat() {
    if (_catQueue.isNotEmpty) {
      _resetCard();
      setState(() {
        _currentCat = _catQueue.removeAt(0);
        _progress = 0.0;
      });
      if (_catQueue.length <= 1) {
        _preloadCats();
      }
      if (_currentCat != null) {
        precacheImage(NetworkImage(_currentCat!.imageUrl), context);
      }
    }
  }

  void _loadNextCat() {
    _setNextCat();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _cardOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    const threshold = 100.0;
    if (_cardOffset.dx > threshold) {
      _isSwiped = true;
      _animateCard(const Offset(500, 0));
    } else if (_cardOffset.dx < -threshold) {
      _isSwiped = true;
      _animateCard(const Offset(-500, 0));
    } else {
      _animateCard(Offset.zero);
    }
  }

  void _animateCard(Offset endOffset) {
    if (!mounted) return;
    _animation = Tween<Offset>(begin: _cardOffset, end: endOffset).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward(from: 0);
  }

  double getRotationAngle() {
    return _cardOffset.dx / 300;
  }

  void _onSwipeAction(bool isLike) {
    _isSwiped = true;
    _animateCard(isLike ? const Offset(500, 0) : const Offset(-500, 0));
  }

  Widget _buildCard() {
    return KeyedSubtree(
      key: ValueKey(_currentCat!.id),
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder:
                  (context) => DetailsScreen(
                    cat: _currentCat!,
                    onLike: () {
                      context.read<LikedCatsCubit>().addCat(_currentCat!);
                      Navigator.pop(context);
                      _loadNextCat();
                    },
                    onDislike: () {
                      Navigator.pop(context);
                      _loadNextCat();
                    },
                  ),
            ),
          );
        },
        child: Transform.translate(
          offset: _cardOffset,
          child: Transform.rotate(
            angle: getRotationAngle(),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: _currentCat!.imageUrl,
                height: 400,
                width: 300,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[200],
                      height: 400,
                      width: 300,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.red[100],
                      height: 400,
                      width: 300,
                      child: const Icon(Icons.error),
                    ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DislikeButton(
          onPressed: () => _onSwipeAction(false),
          scale: _dislikeScale,
          onTapDown: () => setState(() => _dislikeScale = 0.9),
          onTapUp: () {
            setState(() => _dislikeScale = 1.0);
            _onSwipeAction(false);
          },
          onTapCancel: () => setState(() => _dislikeScale = 1.0),
        ),
        const SizedBox(width: 50),
        LikeButton(
          onPressed: () => _onSwipeAction(true),
          scale: _likeScale,
          onTapDown: () => setState(() => _likeScale = 0.9),
          onTapUp: () {
            setState(() => _likeScale = 1.0);
            _onSwipeAction(true);
          },
          onTapCancel: () => setState(() => _likeScale = 1.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Tinder Pro'),
        actions: [
          BlocBuilder<LikedCatsCubit, LikedCatsState>(
            builder: (context, state) {
              return IconButton(
                icon: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '${state.allCats.length}',
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const LikedCatsScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body:
          _currentCat == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(
                      value: _progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Загружаем котика...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child:
                            _currentCat != null
                                ? _buildCard()
                                : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _currentCat!.breed,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _buildActionButtons(),
                  ),
                ],
              ),
    );
  }
}
