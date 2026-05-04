import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/schema/company_information_record.dart';
import 'package:tournamentmanager/components/custom_appbar_model.dart';

class AboutUsModel extends ChangeNotifier {
  late CustomAppbarModel customAppbarModel;

  // Fetched once on construction; re-used across rebuilds via FutureBuilder.
  final Future<CompanyInformationRecord?> companyInfoFuture =
      CompanyInformationRecord.getFirstDocumentByFilterOnce(pb, '', true);

  void initContextVars(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
  }

  @override
  void dispose() {
    customAppbarModel.dispose();
    super.dispose();
  }
}
