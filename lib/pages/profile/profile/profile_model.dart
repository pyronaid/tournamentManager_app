import 'package:flutter/material.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/schema/company_information_record.dart';

// ---------------------------------------------------------------------------
// ProfileModel
// Currently holds only the company-info future so it is created once and not
// re-fired on every widget rebuild. Add state fields here as needed.
// ---------------------------------------------------------------------------
class ProfileModel extends ChangeNotifier {
  // Fetched once on construction; read by ProfileWidget via context.read.
  final Future<CompanyInformationRecord?> companyInfoFuture =
      CompanyInformationRecord.getFirstDocumentByFilterOnce(pb, '', false);
}
