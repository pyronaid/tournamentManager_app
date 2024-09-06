import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';

import '../../../backend/firebase_analytics/analytics.dart';
import '../../../backend/schema/tournaments_record.dart';
import 'create_edit_news_model.dart';
import 'create_edit_news_widget.dart';

class CreateEditNewsContainer extends StatefulWidget {
  const CreateEditNewsContainer({
    super.key,
    required this.tournamentsRef,
    required this.newsRef,
    required this.createEditFlag,
  });

  final TournamentsRecord? tournamentsRef;
  final NewsRecord? newsRef;
  final bool createEditFlag;

  @override
  State<CreateEditNewsContainer> createState() => _CreateEditNewsContainerState();
}

class _CreateEditNewsContainerState extends State<CreateEditNewsContainer> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'CreateNews'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreateEditNewsModel(tournamentsRef: widget.tournamentsRef, newsRef: widget.newsRef, saveWay: widget.createEditFlag),
      builder: (context, child) {
        return const CreateEditNewsWidget();
      }
    );
  }
}
