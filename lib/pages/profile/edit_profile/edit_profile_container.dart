import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../backend/firebase_analytics/analytics.dart';
import 'edit_profile_model.dart';
import 'edit_profile_widget.dart';

class EditProfileContainer extends StatefulWidget {
  const EditProfileContainer({super.key,});

  @override
  State<EditProfileContainer> createState() => _EditProfileContainerState();
}

class _EditProfileContainerState extends State<EditProfileContainer> {
  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'EditProfile'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => EditProfileModel(),
        builder: (context, child) {
          return const EditProfileWidget();
        }
    );
  }
}