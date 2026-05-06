import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/schema/company_information_record.dart';

import 'package:flutter/material.dart';

class AboutUsModel extends ChangeNotifier {
  // Fetched once on construction; re-used across rebuilds via FutureBuilder.
  final Future<CompanyInformationRecord?> companyInfoFuture =
      CompanyInformationRecord.getFirstDocumentByFilterOnce(pb, '', true);
}
