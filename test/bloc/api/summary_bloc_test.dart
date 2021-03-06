import 'package:flutterhole/bloc/api/summary.dart';
import 'package:flutterhole/bloc/base/event.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/summary.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mock.dart';

class MockSummaryRepository extends Mock implements SummaryRepository {}

main() {
  MockSummaryRepository summaryRepository;
  SummaryBloc summaryBloc;

  setUp(() {
    summaryRepository = MockSummaryRepository();
    summaryBloc = SummaryBloc(summaryRepository);
  });

  test('has a correct initialState', () {
    expect(summaryBloc.initialState, BlocStateEmpty<Summary>());
  });

  group('Fetch', () {
    test(
        'emits [BlocStateEmpty<Summary>, BlocStateLoading<Summary>, BlocStateSuccess<Summary>] when repository returns Summary',
            () {
          when(summaryRepository.get())
              .thenAnswer((_) => Future.value(mockSummary));

          expectLater(
              summaryBloc.state,
              emitsInOrder([
                BlocStateEmpty<Summary>(),
                BlocStateLoading<Summary>(),
                BlocStateSuccess<Summary>(mockSummary),
              ]));

          summaryBloc.dispatch(Fetch());
        });

    test(
        'emits [BlocStateEmpty<Summary>, BlocStateLoading<Summary>, BlocStateError<Summary>] when home repository throws PiholeException',
            () {
          when(summaryRepository.get()).thenThrow(PiholeException());

          expectLater(
              summaryBloc.state,
              emitsInOrder([
                BlocStateEmpty<Summary>(),
                BlocStateLoading<Summary>(),
                BlocStateError<Summary>(PiholeException()),
              ]));

          summaryBloc.dispatch(Fetch());
        });
  });

  group('repository', () {
    MockPiholeClient client;
    SummaryRepository summaryRepository;

    setUp(() {
      client = MockPiholeClient();
      summaryRepository = SummaryRepository(client);
    });

    test('get', () {
      when(client.fetchSummary()).thenAnswer((_) => Future.value(mockSummary));
      expect(summaryRepository.get(), completion(mockSummary));
    });
  });
}
