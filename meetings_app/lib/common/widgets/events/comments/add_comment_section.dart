import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meetings_app/features/app/controllers/event_controller.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';
import 'package:meetings_app/common/widgets/events/rate/star_rating.dart';

class AddCommentSection extends StatefulWidget {
  final int eventId;
  final VoidCallback? onCommentSubmitted;
  final bool isModal; // Indica si se está mostrando como un modal

  const AddCommentSection({
    Key? key,
    required this.eventId,
    this.onCommentSubmitted,
    this.isModal = false,
  }) : super(key: key);

  @override
  State<AddCommentSection> createState() => _AddCommentSectionState();
}

class _AddCommentSectionState extends State<AddCommentSection> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  bool _isAnonymous = false;
  bool _commentSubmitted = false;
  bool _isSubmitting = false; // Estado de envío para evitar múltiples clicks

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    // Prevenir múltiples envíos
    if (_isSubmitting) return;

    if (_commentController.text.trim().isEmpty || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un comentario y una calificación.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Si no es un modal, mostramos un diálogo de carga
    if (!widget.isModal) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: const Text("Enviando comentario..."),
                ),
              ],
            ),
          );
        },
      );
    }

    try {
      final eventController =
          Provider.of<EventController>(context, listen: false);

      // Añadir el comentario (ahora es asíncrono)
      await eventController.addComment(
        eventId: widget.eventId,
        content: _commentController.text.trim(),
        rating: _rating.toInt(),
        isAnonymous: _isAnonymous,
        userId: 'user123',
      );

      // Limpiar el formulario
      _commentController.clear();

      // Actualizar el estado
      setState(() {
        _commentSubmitted = true;
        _isSubmitting = false;
      });

      // Si no es un modal, cerramos el diálogo de carga
      if (!widget.isModal && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Notificar al padre que se ha enviado un comentario
      if (widget.onCommentSubmitted != null) {
        widget.onCommentSubmitted!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Comentario enviado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Si no es un modal, cerramos el diálogo de carga en caso de error
      if (!widget.isModal && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar el comentario: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);
    final eventController = Provider.of<EventController>(context);

    // Verificar si ya se ha comentado globalmente o localmente
    final hasCommented =
        eventController.hasCommentedEvent(widget.eventId) || _commentSubmitted;

    // Si se muestra como modal, aplicamos un estilo especial
    if (widget.isModal) {
      return Container(
        padding: const EdgeInsets.all(LSizes.lg),
        decoration: BoxDecoration(
          color: dark ? LColors.dark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Para que el modal no ocupe toda la pantalla
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de arrastrar para cerrar el modal
            Center(
              child: Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: LSizes.md),

            // Título
            Text(
              'Deja tu opinión sobre el evento',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: dark ? LColors.textWhite : LColors.dark,
                  ),
            ),
            const SizedBox(height: LSizes.lg),

            // Campo de calificación por estrellas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calificación:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: dark ? LColors.light : LColors.dark,
                      ),
                ),
                StarRating(
                  rating: _rating,
                  onRatingChanged: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: LSizes.md),

            // Campo de texto para el comentario
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Escribe tu comentario aquí...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(LSizes.inputFieldRadius),
                ),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: LSizes.md),

            // Opción de anonimato
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Publicar como anónimo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark ? LColors.light : LColors.dark,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: LSizes.lg),

            // Botones de acción
            Row(
              children: [
                // Botón de cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Cancelar',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: LSizes.md),
                // Botón de enviar
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Enviar',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: LColors.textWhite,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Versión normal (no modal) - mantenemos el código existente
    if (hasCommented) {
      return Container(
        decoration: BoxDecoration(
          color: dark ? LColors.accent3 : LColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(LSizes.md),
        margin: const EdgeInsets.symmetric(vertical: LSizes.spaceBtwSections),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 48,
              color: LColors.primary,
            ),
            const SizedBox(height: LSizes.md),
            Text(
              '¡Gracias por tu retroalimentación!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: dark ? LColors.textWhite : LColors.dark,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LSizes.sm),
            Text(
              'Tu opinión es muy valiosa para nosotros.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dark ? LColors.light : LColors.darkGrey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
          Text(
            'Deja tu opinión',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dark ? LColors.textWhite : LColors.dark,
                ),
          ),
          const SizedBox(height: LSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calificación:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: dark ? LColors.light : LColors.dark,
                    ),
              ),
              StarRating(
                rating: _rating,
                onRatingChanged: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: LSizes.md),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Escribe tu comentario aquí...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LSizes.inputFieldRadius),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: LSizes.md),
          Row(
            children: [
              Checkbox(
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
              ),
              Text(
                'Publicar como anónimo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: dark ? LColors.light : LColors.dark,
                    ),
              ),
            ],
          ),
          const SizedBox(height: LSizes.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: LColors.primary,
                padding: const EdgeInsets.symmetric(
                    vertical: LSizes.buttonHeight / 2.5),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Enviar comentario',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: LColors.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
