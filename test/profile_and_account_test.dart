import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lost_and_found/core/models/user_model.dart';
import 'package:flutter_lost_and_found/core/models/post_model.dart';

void main() {
  group('UserModel Profile Updates & Serialization Tests', () {
    test('UserModel serializes and deserializes correctly with photoUrl', () {
      final user = UserModel(
        uid: 'user_123',
        email: 'test@example.com',
        displayName: 'John Doe',
        photoUrl: 'https://cloudinary.com/profile.jpg',
        phoneNumber: '+8801700000000',
        role: 'user',
        location: 'Dhaka, Bangladesh',
      );

      final map = user.toMap();
      expect(map['uid'], 'user_123');
      expect(map['displayName'], 'John Doe');
      expect(map['photoUrl'], 'https://cloudinary.com/profile.jpg');
      expect(map['phoneNumber'], '+8801700000000');
      expect(map['location'], 'Dhaka, Bangladesh');

      final deserialized = UserModel.fromMap(map, 'user_123');
      expect(deserialized.uid, 'user_123');
      expect(deserialized.displayName, 'John Doe');
      expect(deserialized.photoUrl, 'https://cloudinary.com/profile.jpg');
      expect(deserialized.phoneNumber, '+8801700000000');
      expect(deserialized.location, 'Dhaka, Bangladesh');
    });

    test(
      'UserModel preserves protected fields (role, rewardPoints, trustScore)',
      () {
        final user = UserModel(
          uid: 'admin_123',
          email: 'admin@example.com',
          displayName: 'Admin User',
          role: 'admin',
          rewardPoints: 500,
          trustScore: 98,
          isNidVerified: true,
        );

        final map = user.toMap();
        expect(map['role'], 'admin');
        expect(map['rewardPoints'], 500);
        expect(map['trustScore'], 98);
        expect(map['isNidVerified'], true);

        final deserialized = UserModel.fromMap(map, 'admin_123');
        expect(deserialized.role, 'admin');
        expect(deserialized.rewardPoints, 500);
        expect(deserialized.trustScore, 98);
        expect(deserialized.isNidVerified, true);
      },
    );

    test('UserModel handles empty photoUrl gracefully', () {
      final map = {
        'email': 'user@example.com',
        'displayName': 'No Photo User',
        'photoUrl': '',
      };

      final user = UserModel.fromMap(map, 'user_no_photo');
      expect(user.photoUrl, '');
      expect(user.displayName, 'No Photo User');
    });
  });

  group('Post Ownership & Deletion Guard Tests', () {
    test('Identifies post owner correctly', () {
      final post = PostModel(
        id: 'post_123',
        userId: 'owner_uid',
        userName: 'Owner Name',
        images: const [],
        title: 'Lost Phone',
        description: 'iPhone 13 lost at library',
        category: 'Electronics',
        type: 'lost',
        location: 'Dhaka',
        date: '2026-08-17',
      );

      const currentUserId = 'owner_uid';
      const nonOwnerId = 'other_user_uid';

      final bool isOwner = post.userId == currentUserId;
      final bool isNonOwner = post.userId == nonOwnerId;

      expect(isOwner, true);
      expect(isNonOwner, false);
    });
  });
}
