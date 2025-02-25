import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';

import 'loading_model.dart';


class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  late LoadingModel _model;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Loading'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    CustomFlowTheme.of(context).gradientBackgroundBegin,
                    CustomFlowTheme.of(context).gradientBackgroundEnd,
                  ],
                )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Lottie.asset(
                    'assets/animation/splash_animation.json',
                    fit: BoxFit.cover,
                    width: 80.sp, // Adjust the width and height as needed
                    height: 70.sp,
                    repeat: true, // Set to true if you want the animation to loop
                  ),
                ),
                Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent
                    ),
                    child: const Center(
                        child: Text(
                          "Tournament Manager",
                          textAlign: TextAlign.center,
                        )
                    ),
                  ),
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}
