import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/segments/data/segment_repository.dart';
import 'package:virya/features/segments/domain/segment_models.dart';

final segmentRepositoryProvider = Provider<SegmentRepository>(
  (ref) => SegmentRepository(ref.watch(databaseProvider)),
);

final segmentListProvider = StreamProvider<List<SegmentSummary>>(
  (ref) => ref.watch(segmentRepositoryProvider).watchSummaries(),
);

final segmentEffortsProvider =
    StreamProvider.family<List<SegmentEffortRow>, String>(
      (ref, id) => ref.watch(segmentRepositoryProvider).watchEfforts(id),
    );

final activitySegmentsProvider =
    StreamProvider.family<List<ActivitySegmentRow>, String>(
      (ref, id) =>
          ref.watch(segmentRepositoryProvider).watchActivitySegments(id),
    );
