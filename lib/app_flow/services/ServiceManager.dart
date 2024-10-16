import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/AlertClasses.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/SnackBarClasses.dart';

import '../../backend/firebase_analytics/analytics.dart';
import '../../components/standard_graphics/standard_graphics_widgets.dart';
import '../app_flow_theme.dart';
import 'DialogService.dart';

class ServiceManager extends StatefulWidget {
  final Widget child;
  const ServiceManager({super.key, required this.child});

  @override
  State<ServiceManager> createState() => _ServiceManagerState();
}

class _ServiceManagerState extends State<ServiceManager> {

  final DialogService _dialogService = GetIt.instance<DialogService>();
  final SnackBarService _snackBarService = GetIt.instance<SnackBarService>();
  //Declare SneakToast service
  //Declare Loader service

  @override
  void initState() {
    super.initState();

    _dialogService.registerDialogListener(_showDialog);
    _dialogService.registerDialogFormListener(_showDialogForm);

    _snackBarService.registerSnackBarListener(_showSnackBar);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _showDialog(AlertRequest request) {
    showDialog(
      context: context,
      builder: (_) {
        return PopScope(
          onPopInvoked: (bool didPop) {
            if(!_dialogService.dialogIsCompleted()) {
              _dialogService.dialogComplete(AlertResponse(confirmed: false));
            }
          },
          child: AlertDialog(
            title: Text(request.title),
            content: Text(
              request.description,
              style: CustomFlowTheme.of(context).labelMedium,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _dialogService.dialogComplete(AlertResponse(confirmed: false));
                  Navigator.of(context).pop();
                },
                child: Text(request.buttonTitleCancelled),
              ),
              ElevatedButton(
                onPressed: () {
                  _dialogService.dialogComplete(AlertResponse(confirmed: true));
                  Navigator.of(context).pop();
                },
                child: Text(request.buttonTitleConfirmed),
              ),
            ],
          ),
        );
      }
    );
  }
  void _showDialogForm(AlertFormRequest request) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(request.title),
            content: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: request.controller,
                    focusNode: request.focusNode,
                    autofocus: request.autofocus,
                    keyboardType: request.keyboardType,
                    inputFormatters: request.inputFormatters,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    obscureText: false,
                    decoration: standardInputDecoration(
                      context,
                      prefixIcon: request.iconPrefix != null ?
                        Icon(
                          request.iconPrefix,
                          color: CustomFlowTheme.of(context).secondaryText,
                          size: 18,
                        ) : null,
                      suffixIcon: request.iconSuffix != null ?
                        Icon(
                          request.iconSuffix,
                          color: CustomFlowTheme.of(context).secondaryText,
                          size: 18,
                        ) : null,
                    ),
                    style: CustomFlowTheme.of(context).bodyLarge.override(
                      fontWeight: FontWeight.w500,
                      lineHeight: 1,
                    ),
                    minLines: 1,
                    cursorColor: CustomFlowTheme.of(context).primary,
                    validator: request.validatorFunction?.asValidator(context, request.validatorParameter),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    request.description,
                    style: CustomFlowTheme.of(context).labelMedium,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _dialogService.dialogComplete(AlertResponse(confirmed: false));
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
                child: Text(request.buttonTitleCancelled),
              ),
              ElevatedButton(
                onPressed: () {
                  logFirebaseEvent('Button_validate_form');
                  if (formKey.currentState == null ||
                      !formKey.currentState!.validate()) {
                    return;
                  }
                  _dialogService.dialogComplete(AlertResponse(confirmed: true, formValue: request.controller.text));
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
                child: Text(request.buttonTitleConfirmed),
              ),
            ],
          );
        }
    );
  }

  void _showSnackBar(SnackBarRequest request){
    late Flushbar flush;
    flush = Flushbar<void>(
      title: request.title, //ignored since titleText != null
      titleColor: Colors.white,
      message: request.message, //ignored since messageText != null
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      reverseAnimationCurve: Curves.decelerate,
      //forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: CustomFlowTheme.of(context).primaryBackground, //ignored since backgroundGradient != null
      //boxShadows: [BoxShadow(color: Colors.blue[800]!, offset: const Offset(0.0, 2.0), blurRadius: 3.0)],
      backgroundGradient: LinearGradient(colors: [CustomFlowTheme.of(context).gradientBackgroundBegin, CustomFlowTheme.of(context).gradientBackgroundEnd]),
      isDismissible: request.isDismissibleFlag,
      duration: request.duration,
      icon: request.sentiment != null ? Icon(
        request.sentiment!.icon,
        color: request.sentiment!.color,
      ) : null,
      shouldIconPulse: false, //close
      mainButton: TextButton(
        onPressed: () {
          flush.dismiss();
        },
        child: const Icon(
          Icons.close,
          color: Colors.amber,
        ),
      ),
      showProgressIndicator: request.showProgressIndicatorFlag,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: Text(
        request.title,
        style: CustomFlowTheme.of(context).titleMedium,
      ),
      messageText: Text(
        request.message,
        style: CustomFlowTheme.of(context).bodyMedium,
      ),
    )..show(context);
  }
}