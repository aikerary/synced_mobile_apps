import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meetings_app/features/app/controllers/event_controller.dart';
import 'package:meetings_app/features/app/models/event_comment_model.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/formatters/formatters.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';
import 'package:meetings_app/common/widgets/events/rate/star_rating.dart';

class CommentsListSection extends StatelessWidget {
  final int eventId;

  const CommentsListSection({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Asegurarnos de escuchar los cambios en el controlador con listen: true
    final eventController = Provider.of<EventController>(context, listen: true);

    // Obtener y ordenar los comentarios (del más reciente al más antiguo)
    final comments = eventController.getCommentsForEvent(eventId);
    final sortedComments = List<EventComment>.from(comments)
      ..sort((a, b) => b.datePosted.compareTo(a.datePosted));

    // Calcular la calificación promedio
    double averageRating = 0;
    if (comments.isNotEmpty) {
      averageRating = comments.fold(0, (sum, comment) => sum + comment.rating) /
          comments.length;
    }

    final dark = LHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: dark ? LColors.accent3 : LColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(LSizes.md),
      margin: const EdgeInsets.symmetric(vertical: LSizes.spaceBtwSections),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y calificación promedio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comentarios (${sortedComments.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? LColors.textWhite : LColors.dark,
                    ),
              ),
              if (comments.isNotEmpty)
                Row(
                  children: [
                    StarRating(
                      rating: averageRating,
                      size: 16,
                      onRatingChanged: null,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${averageRating.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: dark ? LColors.light : LColors.dark,
                          ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: LSizes.spaceBtwItems),

          // Mostrar mensaje si no hay comentarios
          if (sortedComments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(LSizes.lg),
                child: Text(
                  'No hay comentarios para este evento todavía.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: dark ? LColors.light : LColors.darkGrey,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          // Mostrar la lista de comentarios ordenados
          else
            ListView.builder(
              // Cambiado de ListView.separated a ListView.builder para mejor control
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedComments.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    CommentTile(comment: sortedComments[index]),
                    if (index < sortedComments.length - 1) const Divider(),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final EventComment comment;

  const CommentTile({
    Key? key,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Usuario anónimo o nombre de usuario
              Text(
                comment.isAnonymous
                    ? 'Usuario anónimo'
                    : 'Usuario ${comment.userId?.substring(0, 5)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? LColors.textWhite : LColors.dark,
                    ),
              ),
              // Fecha del comentario
              Text(
                LFormatter.formatDate(comment.datePosted),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? LColors.light : LColors.darkGrey,
                    ),
              ),
            ],
          ),
          const SizedBox(height: LSizes.xs),
          // Calificación por estrellas
          StarRating(
            rating: comment.rating.toDouble(),
            size: 16,
            onRatingChanged: null, // Solo lectura
          ),
          const SizedBox(height: LSizes.xs),
          // Contenido del comentario
          Text(
            comment.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: dark ? LColors.light : LColors.dark,
                ),
          ),
        ],
      ),
    );
  }
}
