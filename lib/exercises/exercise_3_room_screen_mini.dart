// =============================================================================
// EXERCISE 3: Debugging & Refactoring — "Room Screen Mini"
// Time: 30 minutes
// =============================================================================
//
// SCENARIO:
// This is a simplified version of a room screen from a live-streaming app.
// It was hastily written and contains multiple bugs and anti-patterns.
//
// TASK:
// Find ALL bugs (there are 8), fix each one, and write a 1-line comment
// explaining why each fix is necessary.
//
// HINT: Bugs span categories including state management, memory management,
// lifecycle handling, performance, and null safety.
//
// SCORING:
// - 2 points per bug found and fixed correctly
// - 0.5 bonus points per high-quality explanation
// - Maximum: 20 points
// =============================================================================
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ---------------------------------------------------------------------------
// MOCK DEPENDENCIES (do not modify)
// ---------------------------------------------------------------------------

final di = _MockDI();

class _MockDI {
  T call<T>() => throw UnimplementedError('Mock DI');
}

class ZegoService {
  Stream<Map<String, dynamic>> getCommandStream() =>
      Stream.periodic(const Duration(seconds: 5), (i) => {'type': 'ping'});

  Stream<Map<String, dynamic>> getMessageStream() =>
      Stream.periodic(const Duration(seconds: 3), (i) => {'msg': 'hello $i'});

  Stream<Map<String, dynamic>> getUserJoinStream() =>
      Stream.periodic(const Duration(seconds: 10), (i) => {'user': 'user_$i'});
}

final zegoService = ZegoService();

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

// Mock BLoC classes
class RoomState extends Equatable {
  final String roomMode;
  final bool isCommentLocked;
  final List<String> messages;
  final int seatCount;
  final bool isLoading;

  const RoomState({
    this.roomMode = 'normal',
    this.isCommentLocked = false,
    this.messages = const [],
    this.seatCount = 8,
    this.isLoading = false,
  });

  RoomState copyWith({
    String? roomMode,
    bool? isCommentLocked,
    List<String>? messages,
    int? seatCount,
    bool? isLoading,
  }) =>
      RoomState(
        roomMode: roomMode ?? this.roomMode,
        isCommentLocked: isCommentLocked ?? this.isCommentLocked,
        messages: messages ?? this.messages,
        seatCount: seatCount ?? this.seatCount,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props =>
      [roomMode, isCommentLocked, messages, seatCount, isLoading];
}

class RoomEvent extends Equatable {
  const RoomEvent();
  @override
  List<Object?> get props => [];
}

class UpdateModeEvent extends RoomEvent {
  final String mode;
  const UpdateModeEvent(this.mode);
}

class AddMessageEvent extends RoomEvent {
  final String message;
  const AddMessageEvent(this.message);
}

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  RoomBloc() : super(const RoomState()) {
    on<UpdateModeEvent>((event, emit) {
      emit(state.copyWith(roomMode: event.mode));
    });
    on<AddMessageEvent>((event, emit) {
      emit(state.copyWith(
        messages: [...state.messages, event.message],
      ));
    });
  }
}

class BannerState extends Equatable {
  final Map<String, dynamic>? activeBanner;
  final bool isVisible;

  const BannerState({this.activeBanner, this.isVisible = false});

  BannerState copyWith({
    Map<String, dynamic>? activeBanner,
    bool? isVisible,
  }) =>
      BannerState(
        activeBanner: activeBanner ?? this.activeBanner,
        isVisible: isVisible ?? this.isVisible,
      );

  @override
  List<Object?> get props => [activeBanner, isVisible];
}

class BannerEvent extends Equatable {
  const BannerEvent();
  @override
  List<Object?> get props => [];
}

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  BannerBloc() : super(const BannerState());
}

// ---------------------------------------------------------------------------
// THE BUGGY SCREEN (find and fix all 8 bugs)
// ---------------------------------------------------------------------------

class RoomScreenMini extends StatefulWidget {
  final int roomId;
  final bool isLocked;

  const RoomScreenMini({
    super.key,
    required this.roomId,
    this.isLocked = false,
  });

  @override
  State<RoomScreenMini> createState() => _RoomScreenMiniState();
}

class _RoomScreenMiniState extends State<RoomScreenMini>
    with WidgetsBindingObserver {
  // ═══════════════════════════════════════════════════════════════════════════
  // BUG #7: Static mutable map used as instance state
  // ═══════════════════════════════════════════════════════════════════════════
  final Map<String, GlobalKey> seatKeys = {};
  final Map<int, String> seatUserIds = {};

  final RoomBloc _roomBloc = RoomBloc();
  final BannerBloc _bannerBloc = BannerBloc();

  final List<StreamSubscription<dynamic>?> _subscriptions = [];
  late final ScrollController _chatScrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatScrollController = ScrollController();

    _initializeSubscriptions();
    _loadRoomData();
  }

  void _initializeSubscriptions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _subscriptions
        // ═════════════════════════════════════════════════════════════════════
        // BUG #3: Empty stream listener — subscription created but does nothing
        // ═════════════════════════════════════════════════════════════════════
      ..add(zegoService.getMessageStream().listen(_onMessageReceived))
      ..add(zegoService.getCommandStream().listen(_onCommandReceived))
      ..add(zegoService.getUserJoinStream().listen(_onUserJoined));
    });
  }

  Future<void> _loadRoomData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // ═══════════════════════════════════════════════════════════════════════════
    // BUG #1: setState called after async gap without mounted check
    // ═══════════════════════════════════════════════════════════════════════════
    if (!mounted) return;
    setState(() {
      seatKeys.clear();
      for (int i = 0; i < 8; i++) {
        seatKeys['seat_$i'] = GlobalKey();
      }
    });
  }

  void _onMessageReceived(Map<String, dynamic> data) {
    final dynamic msg = data['msg'];
    if (msg == null) return;

    _roomBloc.add(AddMessageEvent(msg.toString()));
  }

  void _onCommandReceived(Map<String, dynamic> data) {
    try {
      final String type = data['type'] ?? '';
      switch (type) {
        case 'mode_change':
          _roomBloc.add(UpdateModeEvent(data['mode'] ?? 'normal'));
          break;
        case 'ban_user':
          // ═════════════════════════════════════════════════════════════════════
          // BUG #5: Force-unwrap navigator without null check
          // ═════════════════════════════════════════════════════════════════════
          final navigatorState = navKey.currentState;
          if (navigatorState != null) {
            Navigator.popUntil(
              navigatorState.context,
                  (route) => route.isFirst,
            );
          }
          break;
        case 'lock_comments':
          _roomBloc.add(const UpdateModeEvent('locked'));
          break;
      }
    } catch (e) {
      if (kDebugMode) print('Error: $e');
    }
  }

  void _onUserJoined(Map<String, dynamic> data) {
    final dynamic user = data['user'];
    if (user == null) return;

    _roomBloc.add(AddMessageEvent('${user.toString()} joined the room'));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUG #8: Async lifecycle override returning void
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _handleLifecycleChange(state);
  }

  Future<void> _handleLifecycleChange(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      // Simulate stopping camera/mic
      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint('Camera stopped');
    } else if (state == AppLifecycleState.resumed) {
      // Simulate restarting camera/mic
      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint('Camera resumed');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // ═══════════════════════════════════════════════════════════════════════════
    // BUG #4: Only cancelling first 2 subscriptions, missing the 3rd
    // ═══════════════════════════════════════════════════════════════════════════
    for (final subscription in _subscriptions) {
      subscription?.cancel();
    }
    _subscriptions.clear();

    _chatScrollController.dispose();
    _roomBloc.close();
    _bannerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- App Bar ---
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Room'),
              background: Container(color: Colors.purple.shade900),
            ),
          ),

          // --- Room Mode Banner ---
          SliverToBoxAdapter(
            child: BlocBuilder<RoomBloc, RoomState>(
              bloc: _roomBloc,
              // Missing: buildWhen: (prev, curr) => prev.roomMode != curr.roomMode,
              buildWhen: (prev, curr) => prev.roomMode != curr.roomMode,
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  color: state.roomMode == 'locked'
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  child: Text('Mode: ${state.roomMode}'),
                );
              },
            ),
          ),

          // --- Seat Grid ---
          BlocBuilder<RoomBloc, RoomState>(
            bloc: _roomBloc,
            buildWhen: (prev, curr) => prev.seatCount != curr.seatCount,
            builder: (context, state) {
              return SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return Container(
                        key: seatKeys['seat_$index'],
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.person, color: Colors.grey),
                              SizedBox(height: 4),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: state.seatCount,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                ),
              );
            },
          ),

          // --- Banner Section ---
          SliverToBoxAdapter(
            child: BlocBuilder<BannerBloc, BannerState>(
              bloc: _bannerBloc,
              // Missing buildWhen
              buildWhen: (prev, curr) => prev.isVisible != curr.isVisible || prev.activeBanner != curr.activeBanner,
              builder: (context, state) {
                if (!state.isVisible) return const SizedBox.shrink();
                return Container(
                  height: 60,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      state.activeBanner?['text'] ?? 'Special Event!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- Chat Messages ---
          SliverToBoxAdapter(
            child: BlocBuilder<RoomBloc, RoomState>(
              bloc: _roomBloc,
              // Missing buildWhen
              buildWhen: (prev, curr) => prev.messages != curr.messages,
              builder: (context, state) {
                return SizedBox(
                  height: 300,
                  child: ListView.separated(
                    controller: _chatScrollController,
                    // Performance issue: shrinkWrap not needed here since
                    // parent container has fixed height, but it's still bad
                    // practice to leave it (it's not present here though)
                    itemCount: state.messages.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Text(
                          state.messages[index],
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // --- Bottom Action Bar ---
      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.card_giftcard),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}