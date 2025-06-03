import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/repository/event_repository.dart';
import 'package:meetings_app/features/app/screens/home/widgets/search_result.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/constants/sizes.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();

    // Focus the search field automatically when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });

    // Add listener to search controller
    _searchController.addListener(_performSearch);
  }

  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredEvents = _allEvents
            .where((event) => event.titulo.toLowerCase().contains(query))
            .toList();
      } else {
        _filteredEvents = [];
      }
    });
  }

  Future<void> _loadEvents() async {
    final eventRepo = Provider.of<EventRepository>(context, listen: false);
    _allEvents = await eventRepo.loadEvents();
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark ? LColors.dark : LColors.light,
      appBar: AppBar(
        backgroundColor: dark ? LColors.dark : LColors.light,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: dark ? LColors.white : LColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Buscar evento',
            hintStyle: TextStyle(
                color: dark
                    ? LColors.textWhite.withOpacity(0.7)
                    : LColors.black.withOpacity(0.7)),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: dark ? LColors.textWhite : LColors.black,
                    ),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
          ),
          style: TextStyle(
            color: dark ? LColors.textWhite : LColors.black,
            fontSize: LSizes.fontSizeMd,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search results or empty state
          Expanded(
            child: _isSearching
                ? SearchResultsWidget(filteredEvents: _filteredEvents)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.search_normal,
                          size: LSizes.iconLg * 2,
                          color: dark
                              ? LColors.textWhite.withOpacity(0.5)
                              : LColors.black.withOpacity(0.5),
                        ),
                        SizedBox(height: LSizes.spaceBtwItems),
                        Text(
                          'Busca eventos por título',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: dark
                                        ? LColors.textWhite.withOpacity(0.7)
                                        : LColors.black.withOpacity(0.7),
                                  ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
