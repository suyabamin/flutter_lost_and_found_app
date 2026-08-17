import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lost_and_found/core/models/claim_model.dart';

void main() {
  group('ClaimModel Tests', () {
    test('ClaimModel instantiation and getters', () {
      final now = DateTime.now();
      final claim = ClaimModel(
        claimId: 'claim_user1_post100',
        postId: 'post100',
        postOwnerId: 'owner123',
        claimerId: 'user1',
        claimerName: 'Tanvir Ahmed',
        claimerPhone: '+8801700000000',
        claimerEmail: 'tanvir@example.com',
        address: 'Dhanmondi, Dhaka',
        description: 'Lost my blue wallet near Starbucks',
        proofDescription: 'Contains NID and student card',
        rewardRequested: 500.0,
        claimImages: ['https://res.cloudinary.com/demo/image1.jpg'],
        status: 'pending',
        createdAt: now,
      );

      expect(claim.claimId, equals('claim_user1_post100'));
      expect(claim.postId, equals('post100'));
      expect(claim.postOwnerId, equals('owner123'));
      expect(claim.claimerId, equals('user1'));
      expect(claim.claimerName, equals('Tanvir Ahmed'));
      expect(claim.claimImages.length, equals(1));
      expect(claim.status, equals('pending'));
    });

    test(
      'ClaimModel.fromMap deserializes claimImages and imageUrls fallback',
      () {
        final mapLegacy = {
          'postId': 'post200',
          'postOwnerId': 'owner456',
          'claimerId': 'user2',
          'claimerName': 'Rahim Uddin',
          'claimerPhone': '+8801800000000',
          'claimerEmail': 'rahim@example.com',
          'address': 'Uttara, Dhaka',
          'description': 'Found black backpack',
          'imageUrls': [
            'https://res.cloudinary.com/demo/img_a.jpg',
            'https://res.cloudinary.com/demo/img_b.jpg',
          ],
          'status': 'approved',
        };

        final claim = ClaimModel.fromMap(mapLegacy, 'claim_legacy_1');

        expect(claim.claimId, equals('claim_legacy_1'));
        expect(claim.claimImages.length, equals(2));
        expect(
          claim.claimImages.first,
          equals('https://res.cloudinary.com/demo/img_a.jpg'),
        );
        expect(claim.status, equals('approved'));
      },
    );

    test('ClaimModel.toMap populates both claimImages and imageUrls keys', () {
      final claim = ClaimModel(
        claimId: 'claim_test_3',
        postId: 'post300',
        postOwnerId: 'owner789',
        claimerId: 'user3',
        claimerName: 'Fatima',
        claimerPhone: '+8801900000000',
        claimerEmail: 'fatima@example.com',
        address: 'Banani, Dhaka',
        description: 'Lost keychain',
        claimImages: ['https://res.cloudinary.com/demo/key.jpg'],
      );

      final map = claim.toMap();

      expect(
        map['claimImages'],
        equals(['https://res.cloudinary.com/demo/key.jpg']),
      );
      expect(
        map['imageUrls'],
        equals(['https://res.cloudinary.com/demo/key.jpg']),
      );
      expect(map['status'], equals('pending'));
    });
  });
}
