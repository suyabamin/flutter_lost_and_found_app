import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lost_and_found/core/models/report_model.dart';

void main() {
  group('ReportModel Tests', () {
    test('ReportModel instantiation and getters', () {
      final now = DateTime.now();
      final report = ReportModel(
        reportId: 'user123_post456',
        postId: 'post456',
        reporterId: 'user123',
        reporterName: 'John Doe',
        reason: 'Spam',
        description: 'Test spam report description',
        status: 'pending',
        postTitle: 'Lost iPhone 13',
        createdAt: now,
        updatedAt: now,
      );

      expect(report.reportId, equals('user123_post456'));
      expect(report.postId, equals('post456'));
      expect(report.reporterId, equals('user123'));
      expect(report.reporterName, equals('John Doe'));
      expect(report.reason, equals('Spam'));
      expect(report.description, equals('Test spam report description'));
      expect(report.status, equals('pending'));
      expect(report.postTitle, equals('Lost iPhone 13'));
    });

    test('ReportModel.fromMap deserialization', () {
      final map = {
        'postId': 'post789',
        'reporterId': 'user999',
        'reporterName': 'Jane Smith',
        'reason': 'Fraud/Scam',
        'description': 'Suspicious request for money',
        'status': 'reviewing',
        'postTitle': 'Found Wallet',
        'createdAt': '2026-08-16T12:00:00.000Z',
        'updatedAt': '2026-08-16T12:30:00.000Z',
        'reviewedBy': 'admin1',
      };

      final report = ReportModel.fromMap(map, 'user999_post789');

      expect(report.reportId, equals('user999_post789'));
      expect(report.postId, equals('post789'));
      expect(report.reporterId, equals('user999'));
      expect(report.reporterName, equals('Jane Smith'));
      expect(report.reason, equals('Fraud/Scam'));
      expect(report.status, equals('reviewing'));
      expect(report.reviewedBy, equals('admin1'));
    });

    test('ReportModel.toMap serialization contains expected keys', () {
      final now = DateTime.now();
      final report = ReportModel(
        reportId: 'user1_post1',
        postId: 'post1',
        reporterId: 'user1',
        reporterName: 'Reporter One',
        reason: 'Duplicate Post',
        createdAt: now,
        updatedAt: now,
      );

      final map = report.toMap();

      expect(map['reportId'], equals('user1_post1'));
      expect(map['postId'], equals('post1'));
      expect(map['reporterId'], equals('user1'));
      expect(map['reason'], equals('Duplicate Post'));
      expect(map['status'], equals('pending'));
    });
  });
}
