import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';

import '../backend/firebase_analytics/analytics.dart';
import 'app_flow_util.dart';

class DialogPage<T> extends Page<T> {
  final Offset? anchorPoint;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool useSafeArea;
  final CapturedThemes? themes;
  final WidgetBuilder builder;

  const DialogPage({
    required this.builder,
    this.anchorPoint,
    this.barrierColor = Colors.black54,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.useSafeArea = true,
    this.themes,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
      context: context,
      settings: this,
      builder: builder,
      anchorPoint: anchorPoint,
      barrierColor: barrierColor?.withOpacity(0.5),
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      themes: themes);
}

class DialogWidget extends StatelessWidget {
  final AlertRequest request;

  const DialogWidget({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    // If accessed with browser's forwarded button (no 'extra' data will exist), navigate back programmatically
    if (extra == null) {
      // Use addPostFrameCallback to avoid build-time navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Router.neglect(context, () => context.pop());
      });
      // Return an empty container while redirecting
      return Container();
    } else {
      return Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.black.withAlpha(100),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        request.title,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        request.description,
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Router.neglect(context, () => context.pop());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: Text(request.buttonTitleCancelled),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if(request.functionConfirmed != null){ await request.functionConfirmed!(null); }
                              if(request.redirectConfirmed != null){
                                logFirebaseEvent('Button_navigate_to');
                                context.goNamed(
                                  request.redirectConfirmed!,
                                  extra: <String, dynamic>{
                                    kTransitionInfoKey: const TransitionInfo(
                                      hasTransition: true,
                                      transitionType: PageTransitionType.fade,
                                      duration: Duration(milliseconds: 0),
                                    ),
                                  },
                                );
                              } else {
                                Router.neglect(context, () => context.pop());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text(request.buttonTitleConfirmed),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

}

class DialogFormWidget extends StatefulWidget {
  final AlertFormRequest request;

  const DialogFormWidget({super.key, required this.request});

  @override
  State<DialogFormWidget> createState() => _DialogFormState();
}

class _DialogFormState extends State<DialogFormWidget> {

  late List<FormInformation> _formInformations;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Generate FormInformation objects when the widget initializes
    _formInformations = widget.request.formInfo.map((func) => func()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    // If accessed with browser's forwarded button (no 'extra' data will exist), navigate back programmatically
    if (extra == null) {
      // Use addPostFrameCallback to avoid build-time navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Router.neglect(context, () => context.pop());
      });
      // Return an empty container while redirecting
      return Container();
    } else {
      return Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.black.withAlpha(100),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.request.title,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            widget.request.description,
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          const SizedBox(height: 32),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 45.h,
                            ),
                            child: SingleChildScrollView(
                              child: Form(
                                key: formKey,
                                autovalidateMode: AutovalidateMode.disabled,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: _formInformations,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Router.neglect(context, () => context.pop());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                child: Text(widget.request.buttonTitleCancelled),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState?.validate() ?? false) {
                                    List<dynamic> formValues = _formInformations.map((inf) => inf.result()).toList();
                                    if(widget.request.functionConfirmed != null){ await widget.request.functionConfirmed!(formValues); }
                                    if(widget.request.redirectConfirmed != null){
                                      logFirebaseEvent('Button_navigate_to');
                                      context.goNamed(
                                        widget.request.redirectConfirmed!,
                                        extra: <String, dynamic>{
                                          kTransitionInfoKey: const TransitionInfo(
                                            hasTransition: true,
                                            transitionType: PageTransitionType.fade,
                                            duration: Duration(milliseconds: 0),
                                          ),
                                        },
                                      );
                                    } else {
                                      Router.neglect(context, () => context.pop());
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(widget.request.buttonTitleConfirmed),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),
      );
    }
  }

}