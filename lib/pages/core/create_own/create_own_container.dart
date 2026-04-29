import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/create_own/create_own_model.dart';
import 'package:tournamentmanager/pages/core/create_own/create_own_widget.dart';


class CreateOwnContainer extends StatelessWidget {
  const CreateOwnContainer({super.key,});

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
