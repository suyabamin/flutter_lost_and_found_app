import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/models/claim_model.dart';
import '../../core/providers/providers.dart';

class ClaimDetailsScreen extends ConsumerStatefulWidget {
  final String claimId;

  const ClaimDetailsScreen({super.key, required this.claimId});

  @override
  ConsumerState<ClaimDetailsScreen> createState() => _ClaimDetailsScreenState();
}

class _ClaimDetailsScreenState extends ConsumerState<ClaimDetailsScreen> {
  bool _isUpdating = false;
  bool _isSharingLiveLocation = false;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  void _toggleLiveLocationSharing(ClaimModel claim, bool isOwner) async {
    if (_isSharingLiveLocation) {
      // Stop tracking
      await _positionSubscription?.cancel();
      _positionSubscription = null;
      setState(() => _isSharingLiveLocation = false);

      await ref.read(firestoreServiceProvider).updateLiveLocation(
            claimId: claim.claimId,
            isOwner: isOwner,
            isSharing: false,
            lat: claim.latitude,
            lng: claim.longitude,
          );
    } else {
      // Check permissions & fetch live location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      setState(() => _isSharingLiveLocation = true);

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((position) async {
        await ref.read(firestoreServiceProvider).updateLiveLocation(
              claimId: claim.claimId,
              isOwner: isOwner,
              isSharing: true,
              lat: position.latitude,
              lng: position.longitude,
            );
      });
    }
  }

  Future<void> _handleApprove(ClaimModel claim) async {
    setState(() => _isUpdating = true);
    try {
      await ref.read(firestoreServiceProvider).updateClaimStatus(claim.claimId, 'approved');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Claim Approved! Private 1-to-1 Chat created.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving claim: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _handleReject(ClaimModel claim) async {
    setState(() => _isUpdating = true);
    try {
      await ref.read(firestoreServiceProvider).updateClaimStatus(claim.claimId, 'rejected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim rejected.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting claim: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<ClaimModel?>(
        stream: firestoreService.streamClaim(widget.claimId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final claim = snapshot.data;
          if (claim == null) {
            return const Center(child: Text('Claim record not found.'));
          }

          final authUser = FirebaseAuth.instance.currentUser;
          final currentUid = user?.uid ?? authUser?.uid ?? 'guest';
          final isOwner = currentUid == claim.postOwnerId;
          final isApproved = claim.status == 'approved';

          // OpenStreetMap markers setup
          final List<Marker> mapMarkers = [
            Marker(
              point: ll.LatLng(claim.latitude, claim.longitude),
              width: 40,
              height: 40,
              child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
            ),
          ];

          if (claim.isClaimerSharingLocation && claim.claimerLat != null && claim.claimerLng != null) {
            mapMarkers.add(
              Marker(
                point: ll.LatLng(claim.claimerLat!, claim.claimerLng!),
                width: 40,
                height: 40,
                child: const Icon(Icons.person_pin_circle_rounded, color: Colors.blue, size: 36),
              ),
            );
          }

          if (claim.isOwnerSharingLocation && claim.ownerLat != null && claim.ownerLng != null) {
            mapMarkers.add(
              Marker(
                point: ll.LatLng(claim.ownerLat!, claim.ownerLng!),
                width: 40,
                height: 40,
                child: const Icon(Icons.person_pin_circle_rounded, color: Colors.orange, size: 36),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Header Card
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Claim Status', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                          const SizedBox(height: 4),
                          Text(
                            claim.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: claim.status == 'approved'
                                  ? Colors.green
                                  : claim.status == 'rejected'
                                      ? AppColors.error
                                      : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      if (isApproved)
                        ElevatedButton.icon(
                          onPressed: () async {
                            final roomId = await firestoreService.createOrGetChatRoom(
                              posterId: claim.postOwnerId,
                              claimerId: claim.claimerId,
                              postId: claim.postId,
                              postTitle: 'Approved Claim Chat',
                              postImage: claim.claimImages.isNotEmpty ? claim.claimImages.first : '',
                            );
                            if (context.mounted) {
                              context.push('/chat/$roomId');
                            }
                          },
                          icon: const Icon(Icons.chat_rounded, size: 18),
                          label: const Text('Open Private Chat'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Claimer Profile Card
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            child: Icon(Icons.person_rounded),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(claim.claimerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 2),
                                Text(claim.claimerPhone, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                if (claim.claimerEmail.isNotEmpty)
                                  Text(claim.claimerEmail, style: const TextStyle(fontSize: 12, color: AppColors.outline)),
                              ],
                            ),
                          ),
                          const Icon(Icons.verified_user_rounded, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(claim.address, style: const TextStyle(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Claim Statement Card
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Claim Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(claim.description, style: const TextStyle(color: AppColors.onSurfaceVariant)),
                      if (claim.proofDescription.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Proof Identifiers:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(claim.proofDescription, style: const TextStyle(color: AppColors.onSurfaceVariant)),
                      ],
                      if (claim.rewardRequested > 0) ...[
                        const SizedBox(height: 12),
                        Text('Reward Expectation: ৳ ${claim.rewardRequested.round()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Proof Images
                if (claim.claimImages.isNotEmpty) ...[
                  const Text('Proof Images', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: claim.claimImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            claim.claimImages[index],
                            width: 160,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 160,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image_rounded),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Live Location Section (100% Free OpenStreetMap)
                if (isApproved) ...[
                  GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.location_searching_rounded, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text('Live Location Sharing (Free Map)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                            Switch(
                              value: _isSharingLiveLocation,
                              activeColor: AppColors.primary,
                              onChanged: (val) => _toggleLiveLocationSharing(claim, isOwner),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Share real-time GPS location securely to coordinate handoff.',
                          style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: ll.LatLng(claim.latitude, claim.longitude),
                                initialZoom: 14,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.flutter_lost_and_found',
                                ),
                                MarkerLayer(markers: mapMarkers),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Approved Claim Chat Action
                if (isApproved) ...[
                  PrimaryButton(
                    text: 'Open Private 1-to-1 Chat',
                    icon: Icons.chat_rounded,
                    onPressed: () async {
                      final roomId = await firestoreService.createOrGetChatRoom(
                        posterId: claim.postOwnerId,
                        claimerId: claim.claimerId,
                        postId: claim.postId,
                        postTitle: 'Approved Claim Chat',
                        postImage: claim.claimImages.isNotEmpty ? claim.claimImages.first : '',
                      );
                      if (context.mounted) {
                        context.push('/chat/$roomId');
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Poster Approve / Reject Action Buttons
                if (claim.status == 'pending') ...[
                  if (!isOwner)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(Icons.bug_report_rounded, size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'Testing Mode: Poster control panel visible.',
                            style: TextStyle(fontSize: 11, color: AppColors.primary, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: _isUpdating ? null : () => _handleReject(claim),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Reject Claim'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Approve Claim',
                          icon: Icons.check_circle_rounded,
                          isLoading: _isUpdating,
                          onPressed: () => _handleApprove(claim),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
