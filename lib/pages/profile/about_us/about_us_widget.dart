import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/schema/company_information_record.dart';
import 'package:tournamentmanager/backend/schema/developer_information_record.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/pages/profile/about_us/about_us_model.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double headerPaddingAll     = 24.0;
  static const double headerTitlePaddingH  = 24.0;
  static const double coverPaddingH        = 24.0;
  static const double coverPaddingTop      = 20.0;
  static const double coverPaddingBtm      = 18.0;
  static const double coverHeight          = 200.0;
  static const double coverRadius          = 12.0;
  static const double logoOverlaySize      = 80.0;
  static const double logoOverlayRadius    = 8.0;
  static const double logoOverlayPadding   = 12.0;
  static const double logoPaddingH         = 24.0;
  static const double logoPaddingBtm       = 18.0;
  static const double logoOnlySize         = 120.0;
  static const double logoOnlyRadius       = 24.0;
  static const double namePaddingH         = 24.0;
  static const double namePaddingBtm       = 6.0;
  static const double bioPaddingH          = 24.0;
  static const double devSectionPaddingH   = 24.0;
  static const double devSectionPaddingTop = 32.0;
  static const double devItemSpacing       = 12.0;
  static const double devPicSize           = 100.0;
  static const double devPicRadius         = 12.0;
  static const double devContentPaddingL   = 12.0;
  static const double devBioPaddingTop     = 6.0;
  static const double loadingSize          = 25.0;
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------
class AboutUsWidget extends StatefulWidget {
  const AboutUsWidget({super.key});

  @override
  State<AboutUsWidget> createState() => _AboutUsWidgetState();
}

class _AboutUsWidgetState extends State<AboutUsWidget> {
  // FIX: model resolved once in initState — not inside _Body.build().
  //   The future stored in the model must be obtained exactly once;
  //   resolving the model in a descendant build() risks reading it after
  //   hot-reload or tree restructure.
  late final AboutUsModel _model;

  @override
  void initState() {
    super.initState();
    _model = context.read<AboutUsModel>();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const _Header(),
                _Body(model: _model),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HEADER
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomFlowTheme.of(context).secondary,
      padding: const EdgeInsets.all(_Dims.headerPaddingAll),
      child: Column(
        children: [
          const CustomAppbarWidget(backButton: true),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              _Dims.headerTitlePaddingH, 0, _Dims.headerTitlePaddingH, 0,
            ),
            child: Text(
              'About Us',
              style: CustomFlowTheme.of(context).displaySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BODY
//
// FIX: model received as constructor parameter — no context.read in build().
// ---------------------------------------------------------------------------
class _Body extends StatelessWidget {
  const _Body({required this.model});

  final AboutUsModel model;

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
        return _Content(record: snapshot.data!);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// CONTENT
// ---------------------------------------------------------------------------
class _Content extends StatelessWidget {
  const _Content({required this.record});

  final CompanyInformationRecord record;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (record.coverImage != '') _CoverWithLogo(record: record),
        if (record.logo != '' && record.coverImage == '') _LogoOnly(record: record),
        _CompanyNameAndBio(record: record),
        if (record.devInfo.isNotEmpty) _DevelopersSection(record: record),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// COVER IMAGE + optional overlay logo
// ---------------------------------------------------------------------------
class _CoverWithLogo extends StatelessWidget {
  const _CoverWithLogo({required this.record});

  final CompanyInformationRecord record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        _Dims.coverPaddingH, _Dims.coverPaddingTop,
        _Dims.coverPaddingH, _Dims.coverPaddingBtm,
      ),
      child: Container(
        width: double.infinity,
        height: _Dims.coverHeight,
        decoration: BoxDecoration(
          color: CustomFlowTheme.of(context).secondaryBackground,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: Image.network(
              valueOrDefault<String>(
                record.coverImage,
                'https://firebasestorage.googleapis.com/v0/b/tournament-manager-ee897.appspot.com/o/assets%2FTM_logo.png?alt=media',
              ),
            ).image,
          ),
          borderRadius: BorderRadius.circular(_Dims.coverRadius),
        ),
        child: Visibility(
          visible: record.logo != '',
          child: Align(
            alignment: const AlignmentDirectional(-1, -1),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                _Dims.logoOverlayPadding, _Dims.logoOverlayPadding, 0, 0,
              ),
              child: Container(
                width: _Dims.logoOverlaySize,
                height: _Dims.logoOverlaySize,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: Image.network(record.logo).image,
                  ),
                  borderRadius: BorderRadius.circular(_Dims.logoOverlayRadius),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LOGO ONLY
// ---------------------------------------------------------------------------
class _LogoOnly extends StatelessWidget {
  const _LogoOnly({required this.record});

  final CompanyInformationRecord record;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(-1, -1),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          _Dims.logoPaddingH, 0, _Dims.logoPaddingH, _Dims.logoPaddingBtm,
        ),
        child: Container(
          width: _Dims.logoOnlySize,
          height: _Dims.logoOnlySize,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.contain,
              image: Image.network(
                valueOrDefault<String>(
                  record.logo,
                  'https://firebasestorage.googleapis.com/v0/b/tournament-manager-ee897.appspot.com/o/assets%2FTM_logo_letters.png?alt=media',
                ),
              ).image,
            ),
            borderRadius: BorderRadius.circular(_Dims.logoOnlyRadius),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// COMPANY NAME + BIO
// ---------------------------------------------------------------------------
class _CompanyNameAndBio extends StatelessWidget {
  const _CompanyNameAndBio({required this.record});

  final CompanyInformationRecord record;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            _Dims.namePaddingH, 0, _Dims.namePaddingH, _Dims.namePaddingBtm,
          ),
          child: Text(
            valueOrDefault<String>(record.name, 'Company Name'),
            style: CustomFlowTheme.of(context).displaySmall,
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            _Dims.bioPaddingH, 0, _Dims.bioPaddingH, 0,
          ),
          child: Text(
            record.companyBio,
            style: CustomFlowTheme.of(context).labelLarge.override(lineHeight: 1.4),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// DEVELOPERS SECTION
// ---------------------------------------------------------------------------
class _DevelopersSection extends StatelessWidget {
  const _DevelopersSection({required this.record});

  final CompanyInformationRecord record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        _Dims.devSectionPaddingH, _Dims.devSectionPaddingTop,
        _Dims.devSectionPaddingH, 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gli sviluppatori', style: CustomFlowTheme.of(context).headlineSmall),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, _Dims.devItemSpacing, 0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: record.devInfo.map((dev) => _DevItem(dev: dev)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DEVELOPER ITEM ROW
// ---------------------------------------------------------------------------
class _DevItem extends StatelessWidget {
  const _DevItem({required this.dev});

  final DevelopersInformationRecord dev;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, _Dims.devItemSpacing),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dev.profilePic != '')
            Container(
              width: _Dims.devPicSize,
              height: _Dims.devPicSize,
              decoration: BoxDecoration(
                color: CustomFlowTheme.of(context).secondaryBackground,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.network(dev.profilePic).image,
                ),
                borderRadius: BorderRadius.circular(_Dims.devPicRadius),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                _Dims.devContentPaddingL, 0, 0, 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dev.name, style: CustomFlowTheme.of(context).titleMedium),
                  if (dev.bio != '')
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        0, _Dims.devBioPaddingTop, 0, 0,
                      ),
                      child: Text(dev.bio, style: CustomFlowTheme.of(context).bodyMedium),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
