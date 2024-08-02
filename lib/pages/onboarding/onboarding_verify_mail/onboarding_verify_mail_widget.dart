
class OnboardingVerifyMailWidget extends StatefulWidget {
  const OnboardingVerifyMailWidget({super.key});

  @override
  State<OnboardingVerifyMailWidget> createState() =>
      _OnboardingVerifyMailWidgetState();
}

class _OnboardingVerifyMailWidgetState extends State<OnboardingVerifyMailWidget> {
  late OnboardingVerifyMailModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingVerifyMailModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Onboarding_VerifyMail'});
    animationsMap.addAll({
      'imageOnPageLoadAnimation1': standardAnimationInfo(context),
    });
    
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
        key: scaffoldKey,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ////////////////
                  //CUSTOM BAR
                  /////////////////
                  wrapWithModel(
                    model: _model.customAppbarModel,
                    updateCallback: () => setState(() {}),
                    child: CustomAppbarWidget(
                      backButton: true,
                      actionButton: false,
                      actionButtonAction: () async {},
                      optionsButtonAction: () async {},
                    ),
                  ),
                  ////////////////
                  //IMAGE LOGO 
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: Center(
                      child:Image.asset(
                        'assets/images/logo_slideshow_1.png',
                        height: 35.h,
                        fit: BoxFit.fill,
                      ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation1']!)
                    ),
                  ),
                  ////////////////
                  //PAGE TITLE
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: Text(
                      'Verifica il tuo indirizzo mail!',
                      style: CustomFlowTheme.of(context).displaySmall,
                    ),
                  ),
                  ////////////////
                  //MAIL INDICATION 
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: Text(
                      'pinco.pallino@gmail.com',
                      style: CustomFlowTheme.of(context).displaySmall,
                    ),
                  ),
                  ////////////////
                  //PAGE TITLE
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: Text(
                      'Il tuo account è stato creato ma non è utilizzabile fino a quando non confermerai la mail. Trovi il link nella mail indicata sopra. Controlla che non sia finita erroneamente in spam!',
                      style: CustomFlowTheme.of(context).displaySmall,
                    ),
                  ),
                  ////////////////
                  //CONTINUE BUTTON
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: AFButtonWidget(
                      onPressed: () async {
                        logFirebaseEvent('ONBOARDING_VERIFY_MAIL_CONTINUE');
                        logFirebaseEvent('Button_haptic_feedback');
                        HapticFeedback.lightImpact();
                        logFirebaseEvent('Button_continue');
                        

                        //LOGIC BUTTON
                        

                        logFirebaseEvent('Button_navigate_to');
                        context.goNamedAuth('Dashboard', context.mounted);
                      },
                      text: 'Continua',
                      options: AFButtonOptions(
                        width: double.infinity,
                        height: 50,
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: CustomFlowTheme.of(context).primary,
                        textStyle: CustomFlowTheme.of(context).titleSmall,
                        elevation: 0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  ////////////////
                  //RESEND MAIL BUTTON
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: AFButtonWidget(
                      onPressed: () async {
                        logFirebaseEvent('ONBOARDING_VERIFY_MAIL_RESEND_MAIL');
                        logFirebaseEvent('Button_haptic_feedback');
                        HapticFeedback.lightImpact();
                        logFirebaseEvent('Button_resend_mail');
                        

                        //LOGIC
                        

                        logFirebaseEvent('Button_navigate_to');
                        context.goNamedAuth('Dashboard', context.mounted);
                      },
                      text: 'Rimanda email di verifica',
                      options: AFButtonOptions(
                        width: double.infinity,
                        height: 50,
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: CustomFlowTheme.of(context).primary,
                        textStyle: CustomFlowTheme.of(context).titleSmall,
                        elevation: 0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
