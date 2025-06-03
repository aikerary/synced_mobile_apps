import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meetings_app/features/app/screens/home/widgets/search_result.dart';
import 'package:meetings_app/features/app/screens/home/widgets/track_carousel.dart';
import 'package:provider/provider.dart';
import 'package:meetings_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:meetings_app/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:meetings_app/common/widgets/events/lists/past_events_list.dart';
import 'package:meetings_app/common/widgets/texts/section_heading.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/repository/event_repository.dart';

import 'package:meetings_app/features/app/screens/all_events/all_events.dart';

import 'package:meetings_app/features/app/screens/home/widgets/home_appbar.dart';
import 'package:meetings_app/features/app/screens/home/widgets/home_carousel.dart';
import 'package:meetings_app/features/app/screens/search/search_screen.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/constants/text_strings.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

/// HomeScreen con búsqueda, carrusel de tracks y listado de eventos.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Event> _allEvents = []; // Lista completa de eventos

  @override
  void initState() {
    super.initState();
    // Cargar eventos desde el repositorio.
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final eventRepo = Provider.of<EventRepository>(context, listen: false);
    _allEvents = await eventRepo.loadEvents();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark
          ? LColors.dark.withValues(alpha: 0.95)
          : LColors.light.withValues(alpha: 0.95),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            // Cabecera principal.
            LPrimaryHeaderContainer(
              height: 230,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LHomeAppBar(),
                  SizedBox(height: LSizes.sm),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: LSizes.lg * 1.5),
                    child: SizedBox(
                      width: 200,
                      child: Text(
                        LTexts.homeAppbarTitle,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: LColors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Barra de búsqueda como botón para navegar a la pantalla de búsqueda
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: LSizes.lg * 1.5),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  child: AbsorbPointer(
                    child: LSearchContainer(
                      text: 'Buscar evento',
                      icon: Iconsax.search_favorite,
                      isPostIcon: false,
                      postIconFunction: () {},
                    ),
                  ),
                ),
              ),
            ),
            // Resto del contenido.
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: LSizes.lg * 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carrusel de tracks.
                    const SizedBox(height: 16),
                    LSectionHeading(
                      title: "Categorías",
                      textColor: dark ? LColors.textWhite : LColors.dark,
                      showActionButton: false,
                    ),
                    const SizedBox(height: 8),
                    TrackCarouselWidget(dark: dark),
                    SizedBox(height: LSizes.sm),
                    // Próximos eventos.
                    LSectionHeading(
                      title: "Próximos Eventos",
                      textColor: dark ? LColors.textWhite : LColors.dark,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllEventsScreen(),
                          ),
                        );
                      },
                    ),
                    const LEventCarousel(),
                    SizedBox(height: LSizes.sm),
                    // Eventos pasados.
                    LSectionHeading(
                      title: "Eventos pasados",
                      textColor: dark ? LColors.textWhite : LColors.dark,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllEventsScreen(
                                defaultFilter: EventDateFilter.past),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: LSizes.sm),
                    const LPastEventList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
