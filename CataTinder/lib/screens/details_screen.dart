import 'package:flutter/material.dart';
import '../models/cat.dart';
import '../widgets/dislike_button.dart';
import '../widgets/like_button.dart';

class DetailsScreen extends StatefulWidget {
  final Cat cat;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const DetailsScreen({
    super.key,
    required this.cat,
    required this.onLike,
    required this.onDislike,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final TransformationController _transformationController =
      TransformationController();

  double _likeScale = 1.0;
  double _dislikeScale = 1.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DislikeButton(
          onPressed: widget.onDislike,
          scale: _dislikeScale,
          onTapDown: () => setState(() => _dislikeScale = 0.9),
          onTapUp: () {
            setState(() => _dislikeScale = 1.0);
            widget.onDislike();
          },
          onTapCancel: () => setState(() => _dislikeScale = 1.0),
        ),
        const SizedBox(width: 50),
        LikeButton(
          onPressed: widget.onLike,
          scale: _likeScale,
          onTapDown: () => setState(() => _likeScale = 0.9),
          onTapUp: () {
            setState(() => _likeScale = 1.0);
            widget.onLike();
          },
          onTapCancel: () => setState(() => _likeScale = 1.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cat.breed)),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              panAxis: PanAxis.horizontal,
              scaleEnabled: true,
              panEnabled: true,
              transformationController: _transformationController,
              child: Image.network(widget.cat.imageUrl, fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.cat.breed,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.cat.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
