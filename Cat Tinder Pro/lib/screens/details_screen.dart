import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cat.dart';
import '../widgets/like_button.dart';
import '../widgets/dislike_button.dart';

class DetailsScreen extends StatefulWidget {
  final Cat cat;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;

  const DetailsScreen({
    super.key,
    required this.cat,
    this.onLike,
    this.onDislike,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  double _likeScale = 1.0;
  double _dislikeScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cat.breed)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(100.0),
                  minScale: 0.1,
                  maxScale: 8.0,
                  child: CachedNetworkImage(
                    imageUrl: widget.cat.imageUrl,
                    width: constraints.maxWidth,
                    fit: BoxFit.contain,
                    placeholder:
                        (context, url) => Container(
                          width: constraints.maxWidth,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          width: constraints.maxWidth,
                          color: Colors.red[100],
                          child: const Icon(Icons.error),
                        ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cat.breed,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.cat.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (widget.cat.likedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Лайк: ${widget.cat.likedAt!.toLocal()}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.onLike != null && widget.onDislike != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DislikeButton(
                      onPressed: widget.onDislike ?? () {},
                      scale: _dislikeScale,
                      onTapDown: () => setState(() => _dislikeScale = 0.9),
                      onTapUp: () {
                        setState(() => _dislikeScale = 1.0);
                        widget.onDislike?.call();
                      },
                      onTapCancel: () => setState(() => _dislikeScale = 1.0),
                    ),
                    const SizedBox(width: 50),
                    LikeButton(
                      onPressed: widget.onLike ?? () {},
                      scale: _likeScale,
                      onTapDown: () => setState(() => _likeScale = 0.9),
                      onTapUp: () {
                        setState(() => _likeScale = 1.0);
                        widget.onLike?.call();
                      },
                      onTapCancel: () => setState(() => _likeScale = 1.0),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
