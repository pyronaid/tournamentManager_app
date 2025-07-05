import 'package:flutter/material.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';
import '../../../components/fab_expandable/fab_expandable_widget.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentGeneralPeopleModel extends ChangeNotifier {

  final TournamentModel tournamentModel;

  late PageController _pageController;
  late bool _isLoading;
  late bool _tournamentPreRegistrationEn;
  late bool _tournamentWaitingListEn;

  List<ListType> _availablePages = [];
  ListType _currentPage = ListType.registered;
  int _currentIndex = 0;


  /////////////////////////////CONSTRUCTOR
  TournamentGeneralPeopleModel({required this.tournamentModel}){
    _isLoading = tournamentModel.isLoading;
    _tournamentPreRegistrationEn = tournamentModel.tournamentPreRegistrationEn;
    _tournamentWaitingListEn = tournamentModel.tournamentWaitingListEn;
    _pageController = PageController();
    _availablePages = _calculateAvailablePages();
  }

  /////////////////////////////GETTER
  bool get isLoading => _isLoading;
  bool get tournamentPreRegistrationEn => _tournamentPreRegistrationEn;
  bool get tournamentWaitingListEn => _tournamentWaitingListEn;
  PageController get pageController => _pageController;
  ListType get currentPage => _currentPage;
  int get currentIndex => _currentIndex;
  int getTotalPartecipants() => tournamentModel.tournamentPreRegisteredSize+tournamentModel.tournamentRegisteredSize+tournamentModel.tournamentWaitingSize;
  List<ListType> get availablePages => List.unmodifiable(_availablePages);
  List<ListType> _calculateAvailablePages(){
    final pages = <ListType>[
      ListType.registered
    ];

    if (_tournamentPreRegistrationEn) {
      pages.add(ListType.preregistered);
    }

    if (_tournamentWaitingListEn) {
      pages.add(ListType.waiting);
    }

    return pages;
  }
  List<ActionButton> buildFabActions() {
    final actions = <ActionButton>[];

    for (final pageType in _availablePages.reversed) {
      late IconData icon;
      late String title;

      switch (pageType) {
        case ListType.registered:
          icon = Icons.remember_me;
          title = " Iscritti list ";
          break;
        case ListType.preregistered:
          icon = Icons.airline_seat_recline_normal;
          title = " Pre iscritti list ";
          break;
        case ListType.waiting:
          icon = Icons.sensor_occupied;
          title = " Waiting list ";
          break;
      }

      actions.add(
        ActionButton(
          onPressed: () => navigateToPage(pageType),
          icon: icon,
          title: title,
        ),
      );
    }
    return actions;
  }



  /////////////////////////////SETTER
  bool _listEquals<T>(List<T> a, List<T> b){
    if(a.length != b.length) return false;
    for(int i = 0; i < a.length; i++){
      if(a[i] != b[i]) return false;
    }
    return true;
  }
  bool updateAvailablePagesAndCurrentPage(){
    bool needPageReset = false;
    List<ListType> newAvailablePages = _calculateAvailablePages();
    if(!_listEquals(_availablePages, newAvailablePages)){
      _availablePages = newAvailablePages;
      if(!_availablePages.contains(_currentPage)) {
        _currentPage = _availablePages.first;
        _currentIndex = 0;
        needPageReset = true;
      } else {
        _currentIndex = _availablePages.indexOf(_currentPage);
      }
    }
    return needPageReset;
  }
  void onPageChanged(int index){
    if(index >= 0 && index < _availablePages.length){
      _currentIndex = 0;
      _currentPage = _availablePages[index];
      notifyListeners();
    }
  }
  void navigateToPage(ListType pageType){
    final index = _availablePages.indexOf(pageType);
    if(index != -1 && _currentPage != pageType){
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut
      );
    }
  }
  void resetToFirstPage(){
    if(_availablePages.isNotEmpty && _pageController.hasClients){
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut
      );
    }
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

}