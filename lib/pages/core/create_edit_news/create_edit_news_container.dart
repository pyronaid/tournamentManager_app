import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../backend/firebase_analytics/analytics.dart';
import '../../nav_bar/news_model.dart';
import 'create_edit_news_model.dart';
import 'create_edit_news_widget.dart';

class CreateEditNewsContainer extends StatefulWidget {
  const CreateEditNewsContainer({
    super.key,
    required this.tournamentsRef,
    required this.newsRef,
    required this.createEditFlag,
  });

  final String? tournamentsRef;
  final String? newsRef;
  final bool createEditFlag;

  @override
  State<CreateEditNewsContainer> createState() => _CreateEditNewsContainerState();
}

class _CreateEditNewsContainerState extends State<CreateEditNewsContainer> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'CreateEditNews'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NewsModel>(
          create: (context) => NewsModel(tournamentsRef: widget.tournamentsRef, newsRef: widget.newsRef),
        ),
        ChangeNotifierProvider<CreateEditNewsModel>(
          create: (context) => CreateEditNewsModel(saveWay: widget.createEditFlag),
        ),
      ],
      builder: (context, child) {
        return const CreateEditNewsWidget();
      },
    );
  }
}
