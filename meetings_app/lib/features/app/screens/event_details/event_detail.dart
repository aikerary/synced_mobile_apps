import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meetings_app/common/widgets/appbar/appbar.dart';
import 'package:meetings_app/common/widgets/custom_shapes/containers/event_detail_header_container.dart';
//import 'package:meetings_app/common/widgets/events/alerts/alert_toggle_button.dart';
import 'package:meetings_app/common/widgets/events/comments/add_comment_section.dart';
import 'package:meetings_app/common/widgets/events/comments/comments_list.dart';
import 'package:meetings_app/common/widgets/events/info/event_chip.dart';
import 'package:meetings_app/features/app/controllers/event_controller.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/models/track_model.dart';
import 'package:meetings_app/features/app/repository/track_repository.dart';
import 'package:meetings_app/features/app/screens/event_details/widgets/footer.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.event});

  final Event event;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  // Flag para controlar si el usuario ha enviado un comentario
  bool hasSubmittedComment = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final eventController =
        Provider.of<EventController>(context, listen: false);
    if (eventController.events.isEmpty) {
      await eventController.loadEvents();
    }
  }

  // Método para actualizar el estado cuando se envía un comentario
  void onCommentSubmitted() {
    setState(() {
      hasSubmittedComment = true;
    });
  }

  // Método para mostrar el modal de agregar comentario
  void _showAddCommentModal() {
    final eventController =
        Provider.of<EventController>(context, listen: false);
    final hasCommented =
        eventController.hasCommentedEvent(widget.event.id ?? 0) ||
            hasSubmittedComment;

    if (hasCommented) {
      // Si ya ha comentado, mostrar un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya has dejado tu opinión para este evento.'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: SingleChildScrollView(
          child: AddCommentSection(
            eventId: widget.event.id ?? 0,
            onCommentSubmitted: () {
              Navigator.pop(context);
              onCommentSubmitted();
            },
            isModal: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventController = Provider.of<EventController>(context, listen: true);
    final dark = LHelperFunctions.isDarkMode(context);

    // Calcular si el evento es pasado o futuro
    final now = DateTime.now();
    final isPastEvent = widget.event.fecha.isBefore(now);

    // Verificar si el usuario ya ha comentado este evento
    final userHasCommented =
        eventController.hasCommentedEvent(widget.event.id ?? 0) ||
            hasSubmittedComment;

    // Verificar si el usuario está suscrito a este evento
    final isSubscribed = eventController.isSubscribed(widget.event.id ?? 0);

    // Contar los comentarios para este evento
    final commentCount =
        eventController.getCommentsForEvent(widget.event.id ?? 0).length;

    return Scaffold(
      backgroundColor: dark
          ? LColors.dark.withValues(alpha: 0.95)
          : LColors.light.withValues(alpha: 0.95),
      // Solo mantener el botón flotante para añadir comentarios
      floatingActionButton: isPastEvent && !userHasCommented
          ? FloatingActionButton.extended(
              onPressed: _showAddCommentModal,
              backgroundColor: LColors.primary,
              icon: const Icon(Icons.rate_review, color: Colors.white),
              label: const Text('Dar mi opinión',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
      bottomNavigationBar:
          EventDetailFooter(event: widget.event, pastEvent: isPastEvent),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadEvents();
          setState(() {});
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Header container with event image
                    LEventDetailHeaderContainer(
                      defaultFigures: false,
                      image: widget.event.imageUrl,
                      height: 250,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: LSizes.lg),
                        child: Column(
                          children: [
                            LAppBar(
                              showBackArrow: true,
                              actions: [
                                //AlertToggleButton(title: 'Alert'),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // Main content positioned below the header
                    Positioned(
                      top: 220,
                      left: 16,
                      right: 16,
                      child: Column(
                        children: [
                          // Event information card
                          Container(
                            decoration: BoxDecoration(
                              color: dark ? LColors.accent3 : LColors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Event title and details with comment count
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.event.titulo,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: dark
                                                  ? LColors.textWhite
                                                  : LColors.dark,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    // Badge de comentarios
                                    if (commentCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: LColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.comment,
                                              color: LColors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$commentCount',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: LColors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: LSizes.sm),
                                // Mostrar badge de suscripción si está suscrito
                                if (isSubscribed)
                                  Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: LColors.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border:
                                          Border.all(color: LColors.primary),
                                    ),
                                    child: Text(
                                      'Estás suscrito a este evento',
                                      style: TextStyle(
                                        color: LColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                // Fecha, ubicación y hora
                                Text(
                                  LHelperFunctions.formatDate(
                                      widget.event.fecha),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: dark
                                            ? LColors.light
                                            : LColors.darkGrey,
                                      ),
                                ),
                                Text(
                                  widget.event.trackNames.isNotEmpty
                                      ? widget.event.trackNames.join(', ')
                                      : 'Track no especificado',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: dark
                                            ? LColors.light
                                            : LColors.darkGrey,
                                      ),
                                ),
                                Text(
                                  LHelperFunctions.formatTime(
                                      widget.event.fecha),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: dark
                                            ? LColors.light
                                            : LColors.darkGrey,
                                      ),
                                ),
                                const SizedBox(height: LSizes.sm),

                                // Event tracks
                                Row(
                                  children: [
                                    FutureBuilder<List<Track>>(
                                      future:
                                          TrackRepository().loadDummyTracks(),
                                      builder: (context, snapshot) {
                                        // ...existing code...
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          );
                                        }
                                        if (snapshot.hasError) {
                                          return const SizedBox();
                                        }
                                        if (snapshot.hasData) {
                                          final List<String> eventTrackNames =
                                              widget.event.trackNames;
                                          return Row(
                                            children: eventTrackNames
                                                .map(
                                                  (trackName) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8),
                                                    child: TrackChip(
                                                        context, trackName),
                                                  ),
                                                )
                                                .toList(),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: LSizes.md),

                          // Event description card
                          Container(
                            decoration: BoxDecoration(
                              color: dark ? LColors.accent3 : LColors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ...existing code...
                                Text(
                                  'About',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: dark
                                            ? LColors.textWhite
                                            : LColors.dark,
                                      ),
                                ),
                                const SizedBox(height: LSizes.sm / 2),
                                Text(
                                  widget.event.descripcion,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: dark
                                            ? LColors.light
                                            : LColors.darkGrey,
                                      ),
                                ),
                                const SizedBox(height: LSizes.md),
                                
                                // Speaker principal
                                if (widget.event.ponente != null || widget.event.ponenteNombre != null)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Speaker Principal',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: dark
                                                  ? LColors.textWhite
                                                  : LColors.dark,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: LColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: LColors.primary.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.person_pin,
                                              color: LColors.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              widget.event.ponente?.name ?? 
                                              widget.event.ponenteNombre ?? 
                                              'No especificado',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    color: LColors.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: LSizes.md),
                                    ],
                                  ),
                                
                                // Invitados especiales (excluir speaker principal)
                                Builder(
                                  builder: (context) {
                                    final mainSpeakerName = widget.event.ponente?.name ?? widget.event.ponenteNombre;
                                    final guestSpeakers = widget.event.speakers
                                        .where((speaker) => speaker.name != mainSpeakerName)
                                        .toList();
                                    
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Invitados especiales',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: dark
                                                    ? LColors.textWhite
                                                    : LColors.dark,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (guestSpeakers.isNotEmpty)
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: guestSpeakers
                                                .map((speaker) =>
                                                    TrackChip(context, speaker.name))
                                                .toList(),
                                          )
                                        else
                                          Text(
                                            'No hay invitados especiales',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: dark
                                                      ? LColors.textWhite
                                                      : LColors.darkGrey,
                                                ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Lista de comentarios - siempre visible si hay comentarios
                          CommentsListSection(eventId: widget.event.id ?? 0),

                          // Mensaje de agradecimiento (si ha comentado)
                          if (isPastEvent && userHasCommented)
                            Container(
                              decoration: BoxDecoration(
                                color: dark ? LColors.accent3 : LColors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(LSizes.md),
                              margin: const EdgeInsets.symmetric(
                                  vertical: LSizes.spaceBtwSections),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: dark
                                              ? LColors.textWhite
                                              : LColors.dark,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: LSizes.sm),
                                  Text(
                                    'Tu opinión es muy valiosa para nosotros.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: dark
                                              ? LColors.light
                                              : LColors.darkGrey,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                          // Eliminado: Botón adicional para mostrar el formulario de comentarios
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
