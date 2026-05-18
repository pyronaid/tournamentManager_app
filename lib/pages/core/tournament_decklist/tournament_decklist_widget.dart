import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/pages/core/tournament_decklist/tournament_decklist_model.dart';
import 'package:tournamentmanager/pages/core/tournament_rounds/tournament_rounds_model.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';

import '../../../backend/schema/rounds_record.dart';
import '../../../components/fab_expandable/fab_expandable_widget.dart';
import '../../../components/generic_loading/generic_loading_widget.dart';
import '../../../components/no_content_card/no_content_card_widget.dart';
import '../../../components/tournament_round_card/tournament_rounds_card_widget.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double listTopPadding = 20.0;

  // ── Bottom spacer — derived, not guessed ──────────────────────────────────
  /// Standard Material FAB diameter.
  static const double fabSize = 56.0;

  /// Breathing room between the last card and the FAB.
  static const double fabClearance = 24.0;

  /// Total bottom spacing = FAB height + clearance.
  /// Derived so it stays correct if either value above changes.
  static const double listBottomSpacing = fabSize + fabClearance; // 80.0

  // ── FAB expandable ────────────────────────────────────────────────────────
  /// The radius of the arc on which child FABs are spread when the
  /// FabExpandableWidget is open.  This is a design value that controls
  /// how far the children fan out — not related to screen size.
  static const double fabDistance = 60.0;
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------

class TournamentDecklistWidget extends StatefulWidget {
  const TournamentDecklistWidget({super.key});

  @override
  State<TournamentDecklistWidget> createState() => _TournamentDecklistWidgetState();
}


class _TournamentDecklistWidgetState extends State<TournamentDecklistWidget> {
  final _formKey = GlobalKey<FormState>();

  late final TournamentDecklistModel _model;

  @override
  void initState() {
    super.initState();
    _model = context.read<TournamentDecklistModel>();
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    logFirebaseEvent('ONBOARDING_UPLOAD_DECKLIST');
    logFirebaseEvent('Button_validate_form');

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    logFirebaseEvent('Button_haptic_feedback');
    HapticFeedback.lightImpact();

    final result = await _model.uploadDecklist();

    if (!mounted) return;

    if (result) {
      notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        // ── Body: loading gate rebuilds only when isLoading changes.
        body: SafeArea(
          top: true,
          child: Selector<TournamentDecklistModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              assert(() {
                debugPrint('[BUILD] tournament_decklist_widget.dart');
                return true;
              }());

              if (isLoading) return const _LoadingBody();
        
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: _DecklistForm(
                    model: _model,
                    formKey: _formKey,
                    onSave: _handleSave,
                    // Resolved once here; both carousel and dropdown consume it.
                    availableHeight: constraints.maxHeight,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LOADING BODY
// ---------------------------------------------------------------------------

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

// ---------------------------------------------------------------------------
// ROUNDS BODY
// Owns the RefreshIndicator and the CustomScrollView.
// context.read is correct here: _RoundsBody only rebuilds when isLoading
// flips (Selector above), so there is no stale-reference risk on the model.
// ---------------------------------------------------------------------------

class _DecklistForm extends StatelessWidget {
  const _DecklistForm({
    required this.model,
    required this.formKey,
    required this.onSave,
    required this.availableHeight,
  });

  final TournamentDecklistModel model;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: model.onRefresh,
      child: FutureBuilder<EnrollmentCheckResult>(
        future: enrollCheckFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final status = model.resolveRegistrationStatus(snapshot.data!);

          return switch (status) {
            RegistrationStatus.canRegister       => _PreRegisterButton(model: model),
            RegistrationStatus.canJoinWaiting    => _WaitingListButton(model: model),
            RegistrationStatus.alreadyEnrolled   => _DeEnrollSection(model: model),
            RegistrationStatus.tournamentFull    => _InfoBox(
              message:
              'Il torneo ha raggiunto il limite e non è stata abilitata una waiting list. '
                  'Monitoralo per vedere se vengono aggiunti nuovi posti o se ne liberano alcuni.',
              context: context,
            ),
            RegistrationStatus.preRegDisabled    => _InfoBox(
              message:
              'Non è possibile preregistrarsi. Recati il giorno stabilito presso la sede '
                  'dell\'evento o contatta l\'organizzatore per avere le modalità di registrazione.',
              context: context,
            ),
          };
        },
      ),
    );
  }
}

