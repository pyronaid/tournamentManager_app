import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'my_tournaments_model.dart';
import 'my_tournaments_widget.dart';


class MyTournamentsContainer extends StatelessWidget {
  const MyTournamentsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyTournamentsModel(),
        builder: (context, child) {
          return const MyTournamentsWidget();
        }
    );
  }
}