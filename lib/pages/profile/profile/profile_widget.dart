import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/custom_functions.dart' as functions;
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/backend/schema/company_information_record.dart';
import 'package:tournamentmanager/pages/profile/profile/profile_model.dart';
import 'package:url_launcher/url_launcher.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double pagePaddingH          = 24.0;
  static const double pagePaddingTop        = 24.0;
  static const double greetingPaddingTop    = 24.0;
  static const double greetingPaddingBtm    = 6.0;
  static const double bannerPaddingTop      = 24.0;
  static const double bannerPaddingAll      = 18.0;
  static const double bannerRadius          = 8.0;
  static const double bannerDescPaddingTop  = 6.0;
  static const double qrPaddingV            = 20.0;
  static const double qrSize               = 200.0;
  static const double tileIconContainerSize = 40.0;
  static const double tileIconPadding       = 4.0;
  static const double tileIconSize          = 20.0;
  static const double tileRowPaddingV       = 12.0;
  static const double tileLabelPaddingL     = 18.0;
  static const double loadingSize           = 25.0;
  static const double endSpacerHeight       = 44.0;
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------
class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  // FIX: model resolved once in initState — not inside _CompanyInfoSection
  //   build(). The future stored in ProfileModel must be obtained exactly
  //   once; reading the model in a descendant build() risks calling it after
  //   a hot-reload or tree restructure where the model may be briefly absent.
  late final ProfileModel _model;

  @override
  void initState() {
    super.initState();
    _model = context.read<ProfileModel>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      logFirebaseEvent('PROFILE_PAGE_Profile_ON_INIT_STATE');
      HapticFeedback.mediumImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      debugPrint('[BUILD] profile_widget.dart');
      return true;
    }());

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                _Dims.pagePaddingH,
                _Dims.pagePaddingTop,
                _Dims.pagePaddingH,
                0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _GreetingSection(),
                  const _SupportBanner(),
                  const _QrSection(),
                  // FIX: model passed as parameter — no context.read in
                  //   _CompanyInfoSection.build().
                  _CompanyInfoSection(model: _model),
                  const SizedBox(height: _Dims.endSpacerHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GREETING SECTION
// ---------------------------------------------------------------------------
class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            0, _Dims.greetingPaddingTop, 0, _Dims.greetingPaddingBtm,
          ),
          child: Text(
            valueOrDefault<String>(
              functions.returnProfileGreeting(getCurrentTimestamp),
              'Ciao,',
            ),
            style: CustomFlowTheme.of(context).labelLarge,
          ),
        ),
        AuthUserStreamWidget(
          builder: (context) => Text(
            currentUserName,
            style: CustomFlowTheme.of(context).displaySmall,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SUPPORT BANNER
// ---------------------------------------------------------------------------
class _SupportBanner extends StatelessWidget {
  const _SupportBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, _Dims.bannerPaddingTop, 0, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: CustomFlowTheme.of(context).primary,
          borderRadius: BorderRadius.circular(_Dims.bannerRadius),
          border: Border.all(color: CustomFlowTheme.of(context).accent1),
        ),
        padding: const EdgeInsets.all(_Dims.bannerPaddingAll),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clicca qui se vuoi supportarci!',
              style: CustomFlowTheme.of(context).titleMedium,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                0, _Dims.bannerDescPaddingTop, 0, 0,
              ),
              child: Text(
                'Da parte del team ti ringraziamo del tuo supporto e speriamo '
                "che l'app possa esserti utile",
                style: CustomFlowTheme.of(context)
                    .labelLarge
                    .override(color: CustomFlowTheme.of(context).info),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QR SECTION
// ---------------------------------------------------------------------------
class _QrSection extends StatelessWidget {
  const _QrSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, _Dims.qrPaddingV, 0, _Dims.qrPaddingV),
      child: Center(
        child: QrImageView(
          data: currentUserUid,
          version: QrVersions.auto,
          size: _Dims.qrSize,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: CustomFlowTheme.of(context).primaryText,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: CustomFlowTheme.of(context).primaryText,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// COMPANY INFO SECTION
//
// FIX: model received as constructor parameter — no context.read in build().
// ---------------------------------------------------------------------------
class _CompanyInfoSection extends StatelessWidget {
  const _CompanyInfoSection({required this.model});

  final ProfileModel model;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CompanyInformationRecord?>(
      future: model.companyInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: _Dims.loadingSize,
              height: _Dims.loadingSize,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  CustomFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        return _ActionList(record: snapshot.data!);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// ACTION LIST
// ---------------------------------------------------------------------------
class _ActionList extends StatelessWidget {
  const _ActionList({required this.record});

  final CompanyInformationRecord record;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _ActionTile(
          icon: Icons.person_outline_rounded,
          label: 'Edit Profile',
          onTap: () {
            logFirebaseEvent('PROFILE_PAGE_EditProfileTile_ON_TAP');
            logFirebaseEvent('EditProfileTile_navigate_to');
            context.pushNamedAuth('EditProfile', context.mounted);
          },
        ),
        if (record.name != '' && record.companyBio != '')
          _ActionTile(
            icon: Icons.info_outlined,
            label: 'About Us',
            onTap: () {
              logFirebaseEvent('PROFILE_PAGE_AboutUsTile_ON_TAP');
              logFirebaseEvent('AboutUsTile_navigate_to');
              context.pushNamedAuth('AboutUs', context.mounted);
            },
          ),
        if (record.email != '' || record.phone != '')
          _ActionTile(
            icon: Icons.mail_outlined,
            label: 'Contact Us',
            onTap: () async {
              logFirebaseEvent('PROFILE_PAGE_ContactUsTile_ON_TAP');
              if (record.email != '') {
                logFirebaseEvent('ContactUsTile_send_email');
                await launchUrl(
                    Uri(scheme: 'mailto', path: record.email));
              } else {
                logFirebaseEvent('ContactUsTile_call_number');
                await launchUrl(Uri(scheme: 'tel', path: record.phone));
              }
            },
          ),
        _ActionTile(
          icon: Icons.emoji_events_outlined,
          label: 'Create Own',
          onTap: () {
            logFirebaseEvent('PROFILE_PAGE_CreateOwnTile_ON_TAP');
            logFirebaseEvent('CreateOwnTile_navigate_to');
            context.pushNamedAuth('CreateOwn', context.mounted);
          },
        ),
        const _LogoutTile(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ACTION TILE  (icon + label row + divider)
// ---------------------------------------------------------------------------
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              0, _Dims.tileRowPaddingV, 0, _Dims.tileRowPaddingV,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                _TileIcon(icon: icon),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    _Dims.tileLabelPaddingL, 0, 0, 0,
                  ),
                  child: Text(label, style: CustomFlowTheme.of(context).bodyLarge),
                ),
              ],
            ),
          ),
          Divider(thickness: 1, color: CustomFlowTheme.of(context).primary),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LOGOUT TILE
// ---------------------------------------------------------------------------
class _LogoutTile extends StatelessWidget {
  const _LogoutTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        0, _Dims.tileRowPaddingV, 0, _Dims.tileRowPaddingV,
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          logFirebaseEvent('PROFILE_PAGE_LogoutTile_ON_TAP');
          logFirebaseEvent('LogoutTile_auth');
          GoRouter.of(context).prepareAuthEvent();
          await pocketAuthManager.signOut();
          context.goNamedAuth('Splash', context.mounted);
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const _TileIcon(icon: Icons.logout),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                _Dims.tileLabelPaddingL, 0, 0, 0,
              ),
              child: Text('Log out', style: CustomFlowTheme.of(context).bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TILE ICON  (circle container shared by all tiles)
// ---------------------------------------------------------------------------
class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _Dims.tileIconContainerSize,
      height: _Dims.tileIconContainerSize,
      decoration: BoxDecoration(
        color: CustomFlowTheme.of(context).accent1,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(_Dims.tileIconPadding),
        child: Icon(
          icon,
          color: CustomFlowTheme.of(context).primary,
          size: _Dims.tileIconSize,
        ),
      ),
    );
  }
}
