import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../backend/firebase_analytics/analytics.dart';
import 'create_own_model.dart';
import 'create_own_widget.dart';

class CreateOwnContainer extends StatefulWidget {
  const CreateOwnContainer({super.key,});

  @override
  State<CreateOwnContainer> createState() => _CreateOwnContainerState();
}

class _CreateOwnContainerState extends State<CreateOwnContainer> {
  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'CreateOwn'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreateOwnModel(),
      builder: (context, child) {
        return const CreateOwnWidget();
      }
    );
  }
}
