import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/domain/models/announcement.dart';
import 'package:smart_campus/providers/announcement_provider.dart';
import 'package:smart_campus/data/remote/mysql_announcement_dao.dart';

// 1. We mock the core DAO Native boundary
class MockMysqlAnnouncementDao extends MysqlAnnouncementDao {
  bool shouldThrow = false;
  
  @override
  Future<List<Announcement>> getAnnouncements() async {
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
    late MockMysqlAnnouncementDao mockDao;

    setUp(() {
      mockDao = MockMysqlAnnouncementDao();
      // Inject the mock dependency via constructor injection architecture
      provider = AnnouncementProvider(dao: mockDao);
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
      mockDao.shouldThrow = true;
      
      await provider.fetchAnnouncements();
      
      // 2. Validate the Error Bounds mechanism absorbed the crash correctly
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, contains('Could not load announcements'));
      expect(provider.announcements.isEmpty, true);
    });
  });
}
