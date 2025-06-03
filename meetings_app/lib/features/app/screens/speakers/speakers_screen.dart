import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/speaker_controller.dart';
import '../../models/speaker_model.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../common/widgets/appbar/appbar.dart';

class SpeakersScreen extends StatefulWidget {
  const SpeakersScreen({super.key});

  @override
  State<SpeakersScreen> createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSpeakers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSpeakers() async {
    final speakerController = context.read<SpeakerController>();
    try {
      await speakerController.loadSpeakers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar speakers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);
    
    return Scaffold(
      backgroundColor: dark 
          ? LColors.dark.withValues(alpha: 0.95) 
          : LColors.light.withValues(alpha: 0.95),
      appBar: LAppBar(
        title: Text(
          'Speakers e Invitados',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: dark ? LColors.textWhite : LColors.dark,
          ),
        ),
        showBackArrow: true,
      ),
      body: Consumer<SpeakerController>(
        builder: (context, speakerController, child) {
          if (speakerController.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(LColors.primary),
                  ),
                  SizedBox(height: LSizes.md),
                  Text('Cargando speakers...'),
                ],
              ),
            );
          }

          final speakers = _searchQuery.isEmpty 
              ? speakerController.getSpeakersAlphabetically()
              : speakerController.searchSpeakers(_searchQuery);

          return RefreshIndicator(
            onRefresh: _loadSpeakers,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(LSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con estadísticas
                  Container(
                    padding: const EdgeInsets.all(LSizes.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          LColors.primary,
                          LColors.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(LSizes.cardRadiusLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nuestros Expertos',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: LSizes.sm),
                        Text(
                          'Conoce a los ${speakerController.speakers.length} profesionales que comparten su conocimiento',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: LSizes.lg),
                        Row(
                          children: [
                            _buildStatCard('Total', '${speakerController.speakers.length}', Icons.people),
                            const SizedBox(width: LSizes.md),
                            _buildStatCard('Activos', '${speakerController.speakers.length}', Icons.verified),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: LSizes.lg),

                  // Barra de búsqueda
                  Container(
                    decoration: BoxDecoration(
                      color: dark ? LColors.accent3 : Colors.white,
                      borderRadius: BorderRadius.circular(LSizes.inputFieldRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar speaker...',
                        prefixIcon: const Icon(Icons.search, color: LColors.primary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: LSizes.md,
                          vertical: LSizes.md,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: LSizes.lg),

                  // Lista de speakers
                  if (speakers.isEmpty)
                    _buildEmptyState()
                  else
                    _buildSpeakersList(speakers, dark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(LSizes.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(LSizes.cardRadiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: LSizes.xs),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: LSizes.xl),
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: LSizes.md),
          Text(
            _searchQuery.isNotEmpty 
                ? 'No se encontraron speakers'
                : 'No hay speakers disponibles',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: LSizes.sm),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Intenta con otro término de búsqueda'
                : 'Los speakers se cargarán cuando estén disponibles',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakersList(List<Speaker> speakers, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Speakers (${speakers.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: dark ? LColors.textWhite : LColors.dark,
          ),
        ),
        const SizedBox(height: LSizes.md),
        
        // Grid de speakers
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: LSizes.md,
            mainAxisSpacing: LSizes.md,
          ),
          itemCount: speakers.length,
          itemBuilder: (context, index) {
            return _buildSpeakerCard(speakers[index], dark);
          },
        ),
      ],
    );
  }

  Widget _buildSpeakerCard(Speaker speaker, bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? LColors.accent3 : Colors.white,
        borderRadius: BorderRadius.circular(LSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(LSizes.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar del speaker
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: LColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 30,
                color: LColors.primary,
              ),
            ),
            
            const SizedBox(height: LSizes.md),
            
            // Nombre del speaker
            Text(
              speaker.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: dark ? LColors.textWhite : LColors.dark,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: LSizes.xs),
            
            // ID del speaker (para referencia)
            if (speaker.id != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: LSizes.sm,
                  vertical: LSizes.xs / 2,
                ),
                decoration: BoxDecoration(
                  color: LColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(LSizes.sm),
                ),
                child: Text(
                  'ID: ${speaker.id}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: LColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 