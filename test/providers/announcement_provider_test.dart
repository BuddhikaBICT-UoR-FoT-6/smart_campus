import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/domain/models/announcement.dart';
import 'package:smart_campus/providers/announcement_provider.dart';
import 'package:smart_campus/domain/usecases/get_announcements.dart';

// 1. We mock the core Use-Case Native boundary
class MockGetAnnouncements implements GetAnnouncements {
  bool shouldThrow = false;
  
  @override
  Future<List<Announcement>> call() async {
    if (shouldThrow) {
      throw Exception('Mock socket exception');
    }
    return [
      Announcement(
        id: 1, 
        title: 'Test', 
        body: 'Body', 
        postedBy: 'Admin', 
        date: '2026-03-16'
      ),
    ];
  }
}

void main() {
  group('AnnouncementProvider Caching & Error Bounds Validation', () {
    late AnnouncementProvider provider;
    late MockGetAnnouncements mockUseCase;

    setUp(() {
      mockUseCase = MockGetAnnouncements();
      // Inject the mock dependency via constructor injection architecture
      provider = AnnouncementProvider(getAnnouncements: mockUseCase);
    });

    test('Initial tri-state bounds are strictly null/false', () {
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      expect(provider.announcements.isEmpty, true);
    });

    test('fetchAnnouncements handles mathematical success paths correctly', () async {
      final fetchFuture = provider.fetchAnnouncements();
      
      // Verify loading state is structurally enacted
      expect(provider.isLoading, true);
      
      await fetchFuture;
      
      // Verify loading state is dismantled
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      expect(provider.announcements.length, 1);
    });

    test('fetchAnnouncements catches explicit thrown errors and routes them to State', () async {
      mockUseCase.shouldThrow = true;
      
      await provider.fetchAnnouncements();
      
      // 2. Validate the Error Bounds mechanism absorbed the crash correctly
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, contains('Could not load announcements'));
      expect(provider.announcements.isEmpty, true);
    });
  });
}
