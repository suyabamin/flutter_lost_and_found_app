import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lost_and_found/core/models/user_model.dart';
import 'package:flutter_lost_and_found/core/models/post_model.dart';

void main() {
  group('Lost & Found Bangladesh Model Tests', () {
    test('UserModel serialization and deserialization works', () {
      final user = UserModel(
        uid: 'user_123',
        email: 'test@example.com',
        displayName: 'Test User',
        role: 'user',
        isNidVerified: true,
      );

      final map = user.toMap();
      expect(map['uid'], 'user_123');
      expect(map['email'], 'test@example.com');
      expect(map['isNidVerified'], isTrue);

      final restored = UserModel.fromMap(map, 'user_123');
      expect(restored.displayName, 'Test User');
      expect(restored.isNidVerified, isTrue);
    });

    test('PostModel serialization and deserialization works', () {
      final post = PostModel(
        id: 'post_456',
        title: 'Lost Wallet',
        description: 'Black leather wallet lost in Dhanmondi',
        category: 'Wallets',
        type: 'lost',
        location: 'Dhanmondi, Dhaka',
        date: 'Today',
        images: ['https://example.com/wallet.jpg'],
        userId: 'user_123',
        userName: 'Test User',
        rewardAmount: 1000.0,
      );

      final map = post.toMap();
      expect(map['title'], 'Lost Wallet');
      expect(map['rewardAmount'], 1000.0);

      final restored = PostModel.fromMap(map, 'post_456');
      expect(restored.title, 'Lost Wallet');
      expect(restored.rewardAmount, 1000.0);
    });
  });
}
