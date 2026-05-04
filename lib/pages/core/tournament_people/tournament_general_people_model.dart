import 'package:flutter/material.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';

import '../../../components/fab_expandable/fab_expandable_widget.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentGeneralPeopleModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  late PageController _pageController;

  List<ListType> _availablePages = [];
  ListType _currentPage = ListType.registered;
  int _currentIndex = 0;

  /////////////////////////////CONSTRUCTOR
  TournamentGeneralPeopleModel({
    required this.tournamentModel,
    int? currentIndex,
    ListType? currentPage,
  }) {
    _availablePages = _calculateAvailablePages();
    _initializePageState(currentIndex, currentPage);
    _pageController = PageController(initialPage: _currentIndex);
    tournamentModel.addListener(_onTournamentChanged);
  }

  // ---------------------------------------------------------------------------
  // TOURNAMENT MODEL LISTENER
  // FIX: stale snapshot fields (_isLoading, _tournamentPreRegistrationEn, etc.)
  // removed. All live values now delegate to tournamentModel. Page availability
  // recalculated here rather than during build, which eliminates the side-effect
  // call to updateAvailablePagesAndCurrentPage() from the widget's build method.
  // ---------------------------------------------------------------------------
  void _onTournamentChanged() {
    final needsReset = _recalculateAvailablePages();
    notifyListeners();
    if (needsReset) {
      // Defer the PageController animation until after the build phase.
      WidgetsBinding.instance.addPostFrameCallback((_) => resetToFirstPage());
    }
  }

  /////////////////////////////GETTER
  // FIX: all were stale snapshot fields; now delegate live to tournamentModel.
  bool get isLoading => tournamentModel.isLoading;
  bool get tournamentPreRegistrationEn => tournamentModel.tournamentPreRegistrationEn;
  bool get tournamentWaitingListEn => tournamentModel.tournamentWaitingListEn;
  PageController get pageController => _pageController;
  ListType get currentPage => _currentPage;
  int get currentIndex => _currentIndex;
  List<ListType> get availablePages => List.unmodifiable(_availablePages);

  int getTotalPartecipants() =>
      tournamentModel.tournamentPreRegisteredSize +
      tournamentModel.tournamentRegisteredSize +
      tournamentModel.tournamentWaitingSize;

  List<ActionButton> buildFabActions() {
    final actions = <ActionButton>[];
    for (final pageType in _availablePages.reversed) {
      late final IconData icon;
      late final String title;
      switch (pageType) {
        case ListType.registered:
          icon = Icons.remember_me;
          title = ' Iscritti list ';
          break;
        case ListType.preregistered:
          icon = Icons.airline_seat_recline_normal;
          title = ' Pre iscritti list ';
          break;
        case ListType.waiting:
          icon = Icons.sensor_occupied;
          title = ' Waiting list ';
          break;
      }
      actions.add(ActionButton(
        onPressed: () => navigateToPage(pageType),
        icon: icon,
        title: title,
      ));
    }
    return actions;
  }

  /////////////////////////////PRIVATE HELPERS
  List<ListType> _calculateAvailablePages() {
    return [
      ListType.registered,
      if (tournamentModel.tournamentPreRegistrationEn) ListType.preregistered,
      if (tournamentModel.tournamentWaitingListEn) ListType.waiting,
    ];
  }

  void _initializePageState(int? currentIndex, ListType? currentPage) {
    if (currentIndex != null && currentPage != null) {
      _currentIndex = currentIndex;
      _currentPage = currentPage;
    }
    _syncCurrentPageAndIndex();
  }

  void _syncCurrentPageAndIndex() {
    if (_availablePages.isEmpty) {
      _currentPage = ListType.registered;
      _currentIndex = 0;
      return;
    }
    if (!_availablePages.contains(_currentPage)) {
      _currentPage = _availablePages.first;
      _currentIndex = 0;
    } else {
      _currentIndex = _availablePages.indexOf(_currentPage);
    }
  }

  // Returns true if the current page is no longer in the available list
  // (i.e. a page reset is needed).
  bool _recalculateAvailablePages() {
    final newPages = _calculateAvailablePages();
    if (_listEquals(_availablePages, newPages)) return false;

    _availablePages = newPages;
    if (!_availablePages.contains(_currentPage)) {
      _currentPage = _availablePages.first;
      _currentIndex = 0;
      _syncCurrentPageAndIndex();
      return true;
    }
    _currentIndex = _availablePages.indexOf(_currentPage);
    _syncCurrentPageAndIndex();
    return false;
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /////////////////////////////SETTER
  void onPageChanged(int index) {
    if (index >= 0 && index < _availablePages.length) {
      _currentIndex = index;
      _currentPage = _availablePages[index];
      notifyListeners();
    }
  }

  void navigateToPage(ListType pageType) {
    final index = _availablePages.indexOf(pageType);
    if (index != -1 && _currentPage != pageType && _pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void resetToFirstPage() {
    if (_availablePages.isNotEmpty && _pageController.hasClients) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    tournamentModel.removeListener(_onTournamentChanged);
    _pageController.dispose();
    super.dispose();
  }
}
