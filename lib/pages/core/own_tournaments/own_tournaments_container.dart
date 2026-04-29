import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'own_tournaments_model.dart';
import 'own_tournaments_widget.dart';


class OwnTournamentsContainer extends StatelessWidget {
  const OwnTournamentsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => OwnTournamentsModel(),
        builder: (context, child) {
          return const OwnTournamentsWidget();
        }
    );
  }
}