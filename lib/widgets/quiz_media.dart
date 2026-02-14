// lib/widgets/quiz_media.dart
import 'package:flutter/material.dart';
import '../core/models.dart';
import '../utils/emoji.dart' as emoji_utils;

class QuizMedia extends StatelessWidget {
  final QuizQuestion question;
  final QuizMode mode;

  const QuizMedia({
    super.key,
    required this.question,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    // Bayrak modu: emoji veya PNG fallback
    if (mode == QuizMode.flagCountry) {
      return _FlagMedia(question: question);
    }

    // Yemek modu: görsel + caption
    if (mode == QuizMode.foodCountry) {
      return _FoodMedia(question: question);
    }

    // Foto→Başkent: şehir fotoğrafı
    if (mode == QuizMode.capitalPhoto || mode == QuizMode.capitalFromImage) {
      return _CapitalPhotoMedia(question: question);
    }

    // Emoji varsa göster
    if (question.emoji != null) {
      return _EmojiMedia(emoji: question.emoji!);
    }

    // Görsel varsa göster
    if (question.imagePath != null) {
      return _ImageMedia(imagePath: question.imagePath!);
    }

    // Fallback: boş
    return const SizedBox.shrink();
  }
}

// Bayrak görseli (emoji + PNG fallback)
class _FlagMedia extends StatelessWidget {
  final QuizQuestion question;

  const _FlagMedia({required this.question});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildFlagContent(context),
        ),
      ),
    );
  }

  Widget _buildFlagContent(BuildContext context) {
    // 1) PNG asset varsa
    if (question.imagePath != null && question.imagePath!.isNotEmpty) {
      return Image.asset(
        question.imagePath!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => _buildEmojiFlag(context),
      );
    }

    // 2) Emoji fallback
    return _buildEmojiFlag(context);
  }

  Widget _buildEmojiFlag(BuildContext context) {
    final flagEmoji = question.emoji ?? emoji_utils.flagEmoji(question.iso2);
    return Center(
      child: Text(
        flagEmoji,
        style: const TextStyle(fontSize: 96, height: 1.0),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Yemek görseli + caption
class _FoodMedia extends StatelessWidget {
  final QuizQuestion question;

  const _FoodMedia({required this.question});

  @override
  Widget build(BuildContext context) {
    final dishName = question.metadata['dishName'] as String?;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  question.imagePath ??
                      'assets/placeholders/food_placeholder.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                ),
              ),
              if (dishName != null && dishName.isNotEmpty)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: CaptionBadge(text: dishName),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.restaurant, color: Colors.grey, size: 64),
      ),
    );
  }
}

// Başkent fotoğrafı
class _CapitalPhotoMedia extends StatelessWidget {
  final QuizQuestion question;

  const _CapitalPhotoMedia({required this.question});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          question.imagePath ?? 'assets/placeholders/generic.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => _buildPlaceholder(context),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(Icons.location_city, color: Colors.grey, size: 64),
      ),
    );
  }
}

// Emoji görseli
class _EmojiMedia extends StatelessWidget {
  final String emoji;

  const _EmojiMedia({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 100),
          ),
        ),
      ),
    );
  }
}

// Genel görsel
class _ImageMedia extends StatelessWidget {
  final String imagePath;

  const _ImageMedia({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey, size: 64),
            ),
          ),
        ),
      ),
    );
  }
}

// Caption badge (yemek adı)
class CaptionBadge extends StatelessWidget {
  final String text;

  const CaptionBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
