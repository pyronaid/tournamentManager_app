import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/backend/schema/users_record.dart';

class TournamentsWithCreatorRecord {
  final TournamentsRecord tournament;
  final String creatorName;

  TournamentsWithCreatorRecord({
    required this.tournament,
    required this.creatorName,
  });


  static Stream<List<TournamentsWithCreatorRecord>> getDocuments(Query<Object?> query) {
    return query.snapshots().switchMap((snapshot) {
      final List<TournamentsRecord> tournaments = snapshot.docs.map((doc) => TournamentsRecord.fromSnapshot(doc)).toList();
      if (tournaments.isEmpty) { return Stream.value([]); }


      final List<Stream<TournamentsWithCreatorRecord>> creatorStreams = tournaments.map((TournamentsRecord tournament) {
        return UsersRecord.getDocument(UsersRecord.collection.doc(tournament.creatorUid))
            .map((user) => TournamentsWithCreatorRecord(
          tournament: tournament,
          creatorName: user.displayName,
        )).onErrorReturn(TournamentsWithCreatorRecord(
          tournament: tournament,
          creatorName: 'Unknown User',
        ));
      }).toList();

      return Rx.combineLatest(creatorStreams, (List<TournamentsWithCreatorRecord> results) => results);
    });
  }
}