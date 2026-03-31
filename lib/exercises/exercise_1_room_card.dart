// =============================================================================
// EXERCISE 1: UI & Layout — "Room Card Widget"
// Time: 30 minutes
// =============================================================================
//
// SCENARIO:
// You're building a social/live-streaming app. The home screen shows a list
// of active rooms. Each room is displayed as a card with the room's cover image,
// name, intro text, visitor count, country flag, and status icons.
//
// The previous developer left a broken implementation. Your job is to fix it
// and improve it.
//
// TASKS:
// 1. [All Levels] Fix the layout bugs (overflow, alignment, null handling)
// 2. [Mid+] Add a shimmer loading state for the image
// 3. [Mid+] Make the card responsive (don't use hardcoded pixel values)
// 4. [Senior] Add const constructors throughout where possible
// 5. [Senior] Create a reusable CachedImage widget with loading/error/success states
// 6. [Senior] Add RepaintBoundary where appropriate
//
// RULES:
// - You may add any Flutter/Dart packages you need (shimmer, cached_network_image, etc.)
// - Focus on code quality, not just making it "work"
// - Consider edge cases (null data, long text, missing images)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_developer_assessment/core/utils/extensions/contextSizeX.dart';
import 'package:flutter_developer_assessment/core/utils/extensions/number_format_extension.dart';
import '../core/widgets/app_cached_image.dart';

// ---------------------------------------------------------------------------
// DATA MODEL (do not modify)
// ---------------------------------------------------------------------------

class RoomEntity {
  final int id;
  final String roomName;
  final String? roomIntro;
  final String? coverUrl;
  final int visitorsCount;
  final String? countryFlag; // emoji flag like "🇺🇸"
  final bool isLive;
  final bool hasPassword;
  final String? ownerName;
  final String? ownerAvatarUrl;

  const RoomEntity({
    required this.id,
    required this.roomName,
    this.roomIntro,
    this.coverUrl,
    this.visitorsCount = 0,
    this.countryFlag,
    this.isLive = false,
    this.hasPassword = false,
    this.ownerName,
    this.ownerAvatarUrl,
  });
}

// ---------------------------------------------------------------------------
// SAMPLE DATA (do not modify)
// ---------------------------------------------------------------------------

final sampleRooms = [
  RoomEntity(
    id: 1,
    roomName: 'Welcome to the Super Amazing Party Room 🎉🎉🎉',
    roomIntro: 'Join us for music and fun! Everyone is welcome.',
    coverUrl: 'https://picsum.photos/200/200',
    visitorsCount: 1234,
    countryFlag: '🇺🇸',
    isLive: true,
    hasPassword: false,
    ownerName: 'DJ_Master',
    ownerAvatarUrl: 'https://picsum.photos/50/50',
  ),
  RoomEntity(
    id: 2,
    roomName: 'Chill Zone',
    roomIntro: null, // No intro set
    coverUrl: null, // No cover image
    visitorsCount: 0,
    countryFlag: '🇹🇷',
    isLive: false,
    hasPassword: true,
    ownerName: 'Relaxer',
  ),
  RoomEntity(
    id: 3,
    roomName: 'Gaming Arena - Competitive Matches Every Hour - Join Now!',
    roomIntro: 'Competitive gaming room with hourly tournaments and prizes for top players',
    coverUrl: 'https://picsum.photos/200/201',
    visitorsCount: 56789,
    countryFlag: null, // No country
    isLive: true,
    hasPassword: false,
  ),
];

// ---------------------------------------------------------------------------
// BROKEN IMPLEMENTATION (fix this)
// ---------------------------------------------------------------------------

class RoomCardList extends StatelessWidget {
  const RoomCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: ListView.builder(
        // BUG: Should use ListView.builder for performance
        itemBuilder: (context, index) => RoomCard(room: sampleRooms[index]),
        itemCount: sampleRooms.length,
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final RoomEntity room;

  // BUG: Missing const constructor
  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      // BUG: Hardcoded margin and dimensions
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          const BoxShadow(
            color: Colors.grey,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // --- Cover Image ---
          // BUG: No loading state, no error handling, no placeholder
          SizedBox(
            width: context.screenWidth*0.22,
            height: context.screenHeight*0.1,
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AppCachedImage(imageUrl: room.coverUrl),
                    ),
                    if (room.isLive)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10,),
          // BUG: No spacing between image and text
          // --- Room Info ---
          Expanded(
            child: Column(
              // BUG: Column not wrapped in Expanded, will overflow
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Room Name + Visitor Count
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BUG: Text will overflow on long names
                    Expanded(
                      child: Text(
                        room.roomName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // BUG: No spacing
                    _VisitorCount(count: room.visitorsCount),
                  ],
                ),
                // Row 2: Room Intro
                if(room.roomIntro!=null)
                Text(
                  // BUG: Will show "null" if roomIntro is null
                  room.roomIntro!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFa5a7a4),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  // BUG: No maxLines or overflow handling
                ),
                // Row 3: Country + Lock icon
                const SizedBox(height: 5,),
                Row(
                  children: [
                    // BUG: Will show "null" text if no country flag
                    if(room.countryFlag!=null)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Text(room.countryFlag!, style: const TextStyle(fontSize: 16)),
                    ),
                    // BUG: No spacing
                    if (room.hasPassword)
                      const Icon(Icons.lock, size: 14, color: Color(0xFF32e5ac)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitorCount extends StatelessWidget {
  final int count;

  const _VisitorCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.visibility, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          count.compact,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}