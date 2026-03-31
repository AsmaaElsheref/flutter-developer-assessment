// =============================================================================
// EXERCISE 4: Architecture & DI — "Fix the Dependency Injection Service"
// Time: 20 minutes
// =============================================================================
//
// SCENARIO:
// You've inherited a DI (Dependency Injection) service from a live-streaming
// Flutter app. The original file is 2,000+ lines. Below is a representative
// excerpt showing the patterns used.
//
// TASKS:
// 1. [Junior] Written answer: Explain the difference between registerSingleton,
//    registerLazySingleton, and registerFactory. When would you use each?
//    What's wrong with having BOTH lazySingleton AND factory for the same type?
//
// 2. [Mid] Refactor the code below:
//    - Remove all duplicate registrations
//    - For each BLoC, decide: singleton or factory? Add a comment explaining why.
//    - Fix the FetchUserDataBloc god-class (21 params → split proposal)
//
// 3. [Senior] Design a modular architecture:
//    - Split registrations into per-feature init functions
//    - Propose lazy feature loading strategy
//    - Draw a dependency diagram for the FetchUserDataBloc split
//    - Consider testability implications
//
// WRITE YOUR ANSWERS BELOW EACH SECTION
// =============================================================================

// ignore_for_file: unused_field, unused_local_variable

/// Mock GetIt instance
class _GetIt {
  static final _GetIt instance = _GetIt();

  void registerSingleton<T extends Object>(T instance) {}
  void registerLazySingleton<T extends Object>(T Function() factoryFunc) {}
  void registerFactory<T extends Object>(T Function() factoryFunc,
      {String? instanceName}) {}
  T call<T extends Object>({String? instanceName}) =>
      throw UnimplementedError();
}

final di = _GetIt.instance;

// ---------------------------------------------------------------------------
// MOCK CLASSES (do not modify — just for type reference)
// ---------------------------------------------------------------------------

class DioFactory {}
class HiveManager {}
class SharedPreferences {}

// Data Sources
class HomeRemoteDataSource { HomeRemoteDataSource(DioFactory dio); }
class MessagesRemoteDataSource { MessagesRemoteDataSource(DioFactory dio); }
class ProfileRemoteDataSource { ProfileRemoteDataSource(DioFactory dio); }
class PusherRemoteDataSource { PusherRemoteDataSource(dynamic pusher); }

// Repositories
class HomeRepository { HomeRepository(HomeRemoteDataSource ds); }
class MessagesRepository { MessagesRepository(MessagesRemoteDataSource ds); }
class ProfileRepository { ProfileRepository(ProfileRemoteDataSource ds); }
class PusherRepository { PusherRepository(PusherRemoteDataSource ds); }

// Use Cases (each takes a repository)
class FetchRoomsUC { FetchRoomsUC(HomeRepository repo); }
class FetchLiveRoomsUC { FetchLiveRoomsUC(HomeRepository repo); }
class CreateRoomUC { CreateRoomUC(HomeRepository repo); }
class FetchMessagesUC { FetchMessagesUC(MessagesRepository repo); }
class SendMessageUC { SendMessageUC(MessagesRepository repo); }
class DeleteMessageUC { DeleteMessageUC(MessagesRepository repo); }
class FetchUserProfileUC { FetchUserProfileUC(ProfileRepository repo); }
class FetchMyProfileUC { FetchMyProfileUC(ProfileRepository repo); }
class UpdateProfileUC { UpdateProfileUC(ProfileRepository repo); }
class FetchGiftHistoryUC { FetchGiftHistoryUC(ProfileRepository repo); }
class FetchUserBadgesUC { FetchUserBadgesUC(ProfileRepository repo); }
class FetchMyBadgesUC { FetchMyBadgesUC(ProfileRepository repo); }
class FetchCpProfileUC { FetchCpProfileUC(ProfileRepository repo); }
class FetchUserRoomsUC { FetchUserRoomsUC(ProfileRepository repo); }
class FetchSupporterUC { FetchSupporterUC(ProfileRepository repo); }
class FetchUserIntroUC { FetchUserIntroUC(ProfileRepository repo); }
class FetchReelsUC { FetchReelsUC(HomeRepository repo); }
class LikeReelUC { LikeReelUC(HomeRepository repo); }
class ShareReelUC { ShareReelUC(HomeRepository repo); }
class ViewReelUC { ViewReelUC(HomeRepository repo); }
class FetchMomentsUC { FetchMomentsUC(HomeRepository repo); }
class InitPusherUC { InitPusherUC(PusherRepository repo); }
class SubscribeChatUC { SubscribeChatUC(PusherRepository repo); }
class SubscribeMessagesUC { SubscribeMessagesUC(PusherRepository repo); }
class ListenToBannersUC { ListenToBannersUC(PusherRepository repo); }
class ListenToGamesUC { ListenToGamesUC(PusherRepository repo); }
class SubscribeCounterUC { SubscribeCounterUC(PusherRepository repo); }
class FetchConfigUC { FetchConfigUC(HomeRepository repo); }
class FetchCountriesUC { FetchCountriesUC(HomeRepository repo); }
class UpdateFCMTokenUC { UpdateFCMTokenUC(ProfileRepository repo); }
class FetchLevelDataUC { FetchLevelDataUC(ProfileRepository repo); }
class InitAnalyticsUC { InitAnalyticsUC(HomeRepository repo); }
class FetchWalletUC { FetchWalletUC(ProfileRepository repo); }

// BLoCs
class HomeBloc { HomeBloc(FetchRoomsUC uc1, FetchLiveRoomsUC uc2); }
class CreateRoomBloc { CreateRoomBloc(CreateRoomUC uc); }
class MessagesBloc { MessagesBloc(FetchMessagesUC uc, SendMessageUC uc2); }
class DeleteMessageBloc { DeleteMessageBloc(DeleteMessageUC uc); }
class GiftHistoryBloc { GiftHistoryBloc({required FetchGiftHistoryUC giftHistoryUseCase}); }
class GetBadgesBloc { GetBadgesBloc({required FetchUserBadgesUC getBadgesUseCase, required FetchMyBadgesUC getMyAllBadgeUC}); }
class UserBadgesBloc { UserBadgesBloc({required FetchUserBadgesUC uc}); }
class GetUserBadgesBloc { GetUserBadgesBloc({required FetchUserBadgesUC uc}); }
class CpProfileBloc { CpProfileBloc({required FetchCpProfileUC uc}); }
class GetUserRoomsBloc { GetUserRoomsBloc({required FetchUserRoomsUC uc}); }
class GetSupporterBloc { GetSupporterBloc({required FetchSupporterUC uc}); }
class GetUserIntroBloc { GetUserIntroBloc({required FetchUserIntroUC uc}); }
class GetReelsBloc { GetReelsBloc(FetchReelsUC uc1, LikeReelUC uc2, ShareReelUC uc3, ViewReelUC uc4); }
class ReelViewerBloc { ReelViewerBloc(ViewReelUC uc); }
class MomentBloc { MomentBloc(FetchMomentsUC uc); }

// The God-Class BLoC
class FetchUserDataBloc {
  FetchUserDataBloc(
    FetchMyProfileUC uc1,
    FetchUserProfileUC uc2,
    InitPusherUC uc3,
    SubscribeChatUC uc4,
    SubscribeMessagesUC uc5,
    ListenToBannersUC uc6,
    ListenToGamesUC uc7,
    SubscribeCounterUC uc8,
    FetchConfigUC uc9,
    FetchCountriesUC uc10,
    UpdateFCMTokenUC uc11,
    FetchUserBadgesUC uc12,
    FetchLevelDataUC uc13,
    InitAnalyticsUC uc14,
    FetchWalletUC uc15,
    FetchGiftHistoryUC uc16,
    FetchUserRoomsUC uc17,
    FetchSupporterUC uc18,
    FetchCpProfileUC uc19,
    FetchUserIntroUC uc20,
    FetchMyBadgesUC uc21,
  );
}

// =============================================================================
// THE PROBLEMATIC DI SERVICE (refactor this)
// =============================================================================

class DependencyInjectionService {
  static Future<void> init() async {
    // ── Core Services ──────────────────────────────────────────────────────
    di.registerSingleton<DioFactory>(DioFactory());
    di.registerSingleton<HiveManager>(HiveManager());

    // ── Data Sources ───────────────────────────────────────────────────────
    di.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSource(di<DioFactory>()),
    );
    di.registerLazySingleton<MessagesRemoteDataSource>(
      () => MessagesRemoteDataSource(di<DioFactory>()),
    );
    di.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(di<DioFactory>()),
    );

    // ── Repositories ───────────────────────────────────────────────────────
    di.registerLazySingleton<HomeRepository>(
      () => HomeRepository(di<HomeRemoteDataSource>()),
    );
    di.registerLazySingleton<MessagesRepository>(
      () => MessagesRepository(di<MessagesRemoteDataSource>()),
    );
    di.registerLazySingleton<ProfileRepository>(
      () => ProfileRepository(di<ProfileRemoteDataSource>()),
    );

    // ── Use Cases ──────────────────────────────────────────────────────────
    di.registerLazySingleton(() => FetchRoomsUC(di()));
    di.registerLazySingleton(() => FetchLiveRoomsUC(di()));
    di.registerLazySingleton(() => CreateRoomUC(di()));
    di.registerLazySingleton(() => FetchMessagesUC(di()));
    di.registerLazySingleton(() => SendMessageUC(di()));
    di.registerLazySingleton(() => DeleteMessageUC(di()));
    di.registerLazySingleton(() => FetchUserProfileUC(di()));
    di.registerLazySingleton(() => FetchMyProfileUC(di()));
    di.registerLazySingleton(() => UpdateProfileUC(di()));
    di.registerLazySingleton(() => FetchGiftHistoryUC(di()));
    di.registerLazySingleton(() => FetchUserBadgesUC(di()));
    di.registerLazySingleton(() => FetchMyBadgesUC(di()));
    di.registerLazySingleton(() => FetchCpProfileUC(di()));
    di.registerLazySingleton(() => FetchUserRoomsUC(di()));
    di.registerLazySingleton(() => FetchSupporterUC(di()));
    di.registerLazySingleton(() => FetchUserIntroUC(di()));
    di.registerLazySingleton(() => FetchReelsUC(di()));
    di.registerLazySingleton(() => LikeReelUC(di()));
    di.registerLazySingleton(() => ShareReelUC(di()));
    di.registerLazySingleton(() => ViewReelUC(di()));
    di.registerLazySingleton(() => FetchMomentsUC(di()));
    di.registerLazySingleton(() => InitPusherUC(di()));
    di.registerLazySingleton(() => SubscribeChatUC(di()));
    di.registerLazySingleton(() => SubscribeMessagesUC(di()));
    di.registerLazySingleton(() => ListenToBannersUC(di()));
    di.registerLazySingleton(() => ListenToGamesUC(di()));
    di.registerLazySingleton(() => SubscribeCounterUC(di()));
    di.registerLazySingleton(() => FetchConfigUC(di()));
    di.registerLazySingleton(() => FetchCountriesUC(di()));
    di.registerLazySingleton(() => UpdateFCMTokenUC(di()));
    di.registerLazySingleton(() => FetchLevelDataUC(di()));
    di.registerLazySingleton(() => InitAnalyticsUC(di()));
    di.registerLazySingleton(() => FetchWalletUC(di()));

    // ── BLoCs (Singletons — shared state) ──────────────────────────────────
    di.registerLazySingleton(() => HomeBloc(di(), di()));
    di.registerLazySingleton(() => CreateRoomBloc(di()));
    di.registerLazySingleton(() => MessagesBloc(di(), di()));
    di.registerLazySingleton(() => DeleteMessageBloc(di()));

    // ════════════════════════════════════════════════════════════════════════
    // PROBLEM #1: DUPLICATE REGISTRATIONS
    // These 12 BLoCs are registered as BOTH lazySingleton AND factory.
    // The factory uses instanceName: 'registerFactory' to avoid conflicts.
    // ════════════════════════════════════════════════════════════════════════

    // --- GiftHistoryBloc ---
    di.registerLazySingleton(
      () => GiftHistoryBloc(giftHistoryUseCase: di()),
    );
    di.registerFactory(
      () => GiftHistoryBloc(giftHistoryUseCase: di()),
      instanceName: 'registerFactory',
    );

    // --- GetBadgesBloc ---
    di.registerLazySingleton(
      () => GetBadgesBloc(getBadgesUseCase: di(), getMyAllBadgeUC: di()),
    );
    di.registerFactory(
      () => GetBadgesBloc(getBadgesUseCase: di(), getMyAllBadgeUC: di()),
      instanceName: 'registerFactory',
    );

    // --- UserBadgesBloc ---
    di.registerLazySingleton(
      () => UserBadgesBloc(uc: di()),
    );
    di.registerFactory(
      () => UserBadgesBloc(uc: di()),
      instanceName: 'registerFactory',
    );

    // --- GetUserBadgesBloc ---
    di.registerLazySingleton(
      () => GetUserBadgesBloc(uc: di()),
    );
    di.registerFactory(
      () => GetUserBadgesBloc(uc: di()),
      instanceName: 'registerFactory',
    );

    // --- CpProfileBloc ---
    di.registerLazySingleton(
      () => CpProfileBloc(uc: di()),
    );
    di.registerFactory(
      () => CpProfileBloc(uc: di()),
      instanceName: 'registerFactory',
    );

    // --- GetUserRoomsBloc ---
    di.registerLazySingleton(
      () => GetUserRoomsBloc(uc: di()),
    );
    di.registerFactory(
      () => GetUserRoomsBloc(uc: di()),
      instanceName: 'registerFactory',
    );

    // --- GetSupporterBloc ---
    di.registerLazySingleton(
      () => GetSupporterBloc(uc: di()),
    );
    di.registerFactory(
      () => GetSupporterBloc(uc: di()),
      instanceName: 'registerFactory',
    );

    // --- GetUserIntroBloc ---
    di.registerLazySingleton(
      () => GetUserIntroBloc(uc: di()),
    );
    di.registerFactory(
      () => GetUserIntroBloc(uc: di()),
      instanceName: 'registerFactory',
    );

    // --- GetReelsBloc ---
    di.registerLazySingleton(
      () => GetReelsBloc(di(), di(), di(), di()),
    );
    di.registerFactory(
      () => GetReelsBloc(di(), di(), di(), di()),
      instanceName: 'registerFactory',
    );

    // --- ReelViewerBloc ---
    di.registerLazySingleton(
      () => ReelViewerBloc(di()),
    );
    di.registerFactory(
      () => ReelViewerBloc(di()),
      instanceName: 'registerFactory',
    );

    // --- MomentBloc ---
    di.registerLazySingleton(
      () => MomentBloc(di()),
    );
    di.registerFactory(
      () => MomentBloc(di()),
      instanceName: 'registerFactory',
    );

    // ════════════════════════════════════════════════════════════════════════
    // PROBLEM #2: GOD-CLASS BLOC (21 constructor parameters)
    // ════════════════════════════════════════════════════════════════════════

    di.registerLazySingleton(
      () => FetchUserDataBloc(
        di(), // FetchMyProfileUC
        di(), // FetchUserProfileUC
        di(), // InitPusherUC
        di(), // SubscribeChatUC
        di(), // SubscribeMessagesUC
        di(), // ListenToBannersUC
        di(), // ListenToGamesUC
        di(), // SubscribeCounterUC
        di(), // FetchConfigUC
        di(), // FetchCountriesUC
        di(), // UpdateFCMTokenUC
        di(), // FetchUserBadgesUC
        di(), // FetchLevelDataUC
        di(), // InitAnalyticsUC
        di(), // FetchWalletUC
        di(), // FetchGiftHistoryUC
        di(), // FetchUserRoomsUC
        di(), // FetchSupporterUC
        di(), // FetchCpProfileUC
        di(), // FetchUserIntroUC
        di(), // FetchMyBadgesUC
      ),
    );
    // Also registered as factory!
    di.registerFactory(
      () => FetchUserDataBloc(
        di(), di(), di(), di(), di(),
        di(), di(), di(), di(), di(),
        di(), di(), di(), di(), di(),
        di(), di(), di(), di(), di(),
        di(),
      ),
      instanceName: 'registerFactory',
    );
  }
}

// =============================================================================
// YOUR ANSWERS
// =============================================================================

// QUESTION 1 [Junior]: Explain DI registration types
// ---------------------------------------------------
// registerSingleton:
// Creates the object immediately and keeps one shared instance for the whole app.
// Use it for shared, app-wide services such as DioFactory, HiveManager, SharedPreferences.
//
// registerLazySingleton:
// Creates the object only on first use, then reuses the same instance afterward.
// Use it for repositories, data sources, and use cases that should be shared
// but do not need to be created eagerly at startup.
//
// registerFactory:
// Creates a new instance every time it is requested.
// Use it for presentation-layer classes such as BLoCs/Cubits when each screen
// or flow should receive a fresh state instance.
//
// What's wrong with having BOTH lazySingleton AND factory for the same type?
// It creates inconsistent lifecycle rules for the same dependency.
// Some parts of the app may receive a shared instance while others receive
// a fresh one, which leads to unpredictable behavior, hard-to-track bugs,
// state leakage, confusing tests, and unclear ownership of state.

// QUESTION 2 [Mid]: Refactored DI code
// ---------------------------------------------------
class DependencyInjectionServiceRefactored {
  static Future<void> init() async {
    // ── Core Services ──────────────────────────────────────────────────────
    // Singleton: app-wide infrastructure, expensive/shared instances
    di.registerSingleton<DioFactory>(DioFactory());
    di.registerSingleton<HiveManager>(HiveManager());

    // ── Data Sources ───────────────────────────────────────────────────────
    // Lazy singleton: stateless/shared, no need to create eagerly
    di.registerLazySingleton<HomeRemoteDataSource>(
          () => HomeRemoteDataSource(di<DioFactory>()),
    );
    di.registerLazySingleton<MessagesRemoteDataSource>(
          () => MessagesRemoteDataSource(di<DioFactory>()),
    );
    di.registerLazySingleton<ProfileRemoteDataSource>(
          () => ProfileRemoteDataSource(di<DioFactory>()),
    );

    // NOTE: PusherRemoteDataSource is intentionally omitted here because
    // the excerpt does not provide a real pusher dependency registration.

    // ── Repositories ───────────────────────────────────────────────────────
    // Lazy singleton: repositories are shared abstractions over data sources
    di.registerLazySingleton<HomeRepository>(
          () => HomeRepository(di<HomeRemoteDataSource>()),
    );
    di.registerLazySingleton<MessagesRepository>(
          () => MessagesRepository(di<MessagesRemoteDataSource>()),
    );
    di.registerLazySingleton<ProfileRepository>(
          () => ProfileRepository(di<ProfileRemoteDataSource>()),
    );

    // ── Use Cases ──────────────────────────────────────────────────────────
    // Lazy singleton: stateless business logic, safe to reuse
    di.registerLazySingleton(() => FetchRoomsUC(di<HomeRepository>()));
    di.registerLazySingleton(() => FetchLiveRoomsUC(di<HomeRepository>()));
    di.registerLazySingleton(() => CreateRoomUC(di<HomeRepository>()));
    di.registerLazySingleton(() => FetchMessagesUC(di<MessagesRepository>()));
    di.registerLazySingleton(() => SendMessageUC(di<MessagesRepository>()));
    di.registerLazySingleton(() => DeleteMessageUC(di<MessagesRepository>()));
    di.registerLazySingleton(() => FetchUserProfileUC(di<ProfileRepository>()));
    di.registerLazySingleton(() => FetchMyProfileUC(di<ProfileRepository>()));
    di.registerLazySingleton(() => UpdateProfileUC(di<ProfileRepository>()));
    di.registerLazySingleton(() => FetchGiftHistoryUC(di<ProfileRepository>()));
    di.registerLazySingleton(() => FetchUserBadgesUC(di<ProfileRepository>()));
    di.registerLazySingleton(() => FetchMyBadgesUC(di<ProfileRepository>()));
    di.registerLazySingleton(() => FetchCpProfileUC(di<ProfileRepository>()));
    di.registerLazySingleton(() => FetchUserRoomsUC(di<ProfileRepository>()));
    di.registerLazySingleton(() => FetchSupporterUC(di<ProfileRepository>()));
    di.registerLazySingleton(() => FetchUserIntroUC(di<ProfileRepository>()));
    di.registerLazySingleton(() => FetchReelsUC(di<HomeRepository>()));
    di.registerLazySingleton(() => LikeReelUC(di<HomeRepository>()));
    di.registerLazySingleton(() => ShareReelUC(di<HomeRepository>()));
    di.registerLazySingleton(() => ViewReelUC(di<HomeRepository>()));
    di.registerLazySingleton(() => FetchMomentsUC(di<HomeRepository>()));
    di.registerLazySingleton(() => FetchConfigUC(di<HomeRepository>()));
    di.registerLazySingleton(() => FetchCountriesUC(di<HomeRepository>()));
    di.registerLazySingleton(() => UpdateFCMTokenUC(di<ProfileRepository>()));
    di.registerLazySingleton(() => FetchLevelDataUC(di<ProfileRepository>()));
    di.registerLazySingleton(() => InitAnalyticsUC(di<HomeRepository>()));
    di.registerLazySingleton(() => FetchWalletUC(di<ProfileRepository>()));

    // NOTE:
    // Pusher-related use cases are also omitted in executable DI here because
    // PusherRepository/PusherRemoteDataSource dependencies are not fully wired
    // in this excerpt. In a real codebase they should be registered in a
    // dedicated realtime module.

    // ── BLoCs (Singletons — shared state) ───────────────────────────────────────────────
    // Factory: UI state holders should usually be fresh per screen/route
    di.registerFactory(() => HomeBloc(di<FetchRoomsUC>(), di<FetchLiveRoomsUC>()));
    // Factory because each Home screen instance should own its own state

    di.registerFactory(() => CreateRoomBloc(di<CreateRoomUC>()));
    // Factory because room creation flow should start with a fresh state

    di.registerFactory(() => MessagesBloc(di<FetchMessagesUC>(), di<SendMessageUC>()));
    // Factory because chat/message screens should not leak previous UI state

    di.registerFactory(() => DeleteMessageBloc(di<DeleteMessageUC>()));
    // Factory because this is action-oriented presentation logic

    // --- GiftHistoryBloc ---
    di.registerFactory(
          () => GiftHistoryBloc(giftHistoryUseCase: di<FetchGiftHistoryUC>()),
    );
    // Factory because profile/history screens should receive isolated UI state

    // --- GetBadgesBloc ---
    di.registerFactory(
          () => GetBadgesBloc(
        getBadgesUseCase: di<FetchUserBadgesUC>(),
        getMyAllBadgeUC: di<FetchMyBadgesUC>(),
      ),
    );
    // Factory because badge state is screen-specific

    // --- UserBadgesBloc ---
    di.registerFactory(
          () => UserBadgesBloc(uc: di<FetchUserBadgesUC>()),
    );
    // Factory because it is presentation state, not shared app state

    // --- GetUserBadgesBloc ---
    di.registerFactory(
          () => GetUserBadgesBloc(uc: di<FetchUserBadgesUC>()),
    );
    // Factory for the same reason: fresh UI state per usage

    // --- CpProfileBloc ---
    di.registerFactory(
          () => CpProfileBloc(uc: di<FetchCpProfileUC>()),
    );
    // Factory because profile pages should not reuse stale state

    // --- GetUserRoomsBloc ---
    di.registerFactory(
          () => GetUserRoomsBloc(uc: di<FetchUserRoomsUC>()),
    );
    // Factory because room list state belongs to a single screen instance

    // --- GetSupporterBloc ---
    di.registerFactory(
          () => GetSupporterBloc(uc: di<FetchSupporterUC>()),
    );
    // Factory because supporter screen state should be isolated

    // --- GetUserIntroBloc ---
    di.registerFactory(
          () => GetUserIntroBloc(uc: di<FetchUserIntroUC>()),
    );
    // Factory because intro/profile UI state should be fresh

    // --- GetReelsBloc ---
    di.registerFactory(
          () => GetReelsBloc(
        di<FetchReelsUC>(),
        di<LikeReelUC>(),
        di<ShareReelUC>(),
        di<ViewReelUC>(),
      ),
    );
    // Factory because reel viewer/feed state is highly screen/session specific

    // --- ReelViewerBloc ---
    di.registerFactory(
          () => ReelViewerBloc(di<ViewReelUC>()),
    );
    // Factory because viewer state should not be shared across openings

    // --- MomentBloc ---
    di.registerFactory(
          () => MomentBloc(di<FetchMomentsUC>()),
    );
    // Factory because moments feed state belongs to one screen instance

    // FetchUserDataBloc intentionally not registered here in this form.
    // It should be split into smaller feature-focused BLoCs/Cubits first.
  }
}
//

// QUESTION 3 [Senior]: Modular DI architecture + god-class refactor
// ---------------------------------------------------
// a) How would you split this 2000-line file into modules?
//
// I would split the DI setup by layer and by feature:
//
// core/di/core_module.dart
// - DioFactory
// - HiveManager
// - SharedPreferences
//
// features/home/di/home_module.dart
// - HomeRemoteDataSource
// - HomeRepository
// - FetchRoomsUC, FetchLiveRoomsUC, CreateRoomUC, FetchReelsUC,
//   LikeReelUC, ShareReelUC, ViewReelUC, FetchMomentsUC,
//   FetchConfigUC, FetchCountriesUC, InitAnalyticsUC
// - HomeBloc, CreateRoomBloc, GetReelsBloc, ReelViewerBloc, MomentBloc
//
// features/messages/di/messages_module.dart
// - MessagesRemoteDataSource
// - MessagesRepository
// - FetchMessagesUC, SendMessageUC, DeleteMessageUC
// - MessagesBloc, DeleteMessageBloc
//
// features/profile/di/profile_module.dart
// - ProfileRemoteDataSource
// - ProfileRepository
// - FetchUserProfileUC, FetchMyProfileUC, UpdateProfileUC,
//   FetchGiftHistoryUC, FetchUserBadgesUC, FetchMyBadgesUC,
//   FetchCpProfileUC, FetchUserRoomsUC, FetchSupporterUC,
//   FetchUserIntroUC, UpdateFCMTokenUC, FetchLevelDataUC, FetchWalletUC
// - GiftHistoryBloc, GetBadgesBloc, UserBadgesBloc, GetUserBadgesBloc,
//   CpProfileBloc, GetUserRoomsBloc, GetSupporterBloc, GetUserIntroBloc
//
// features/realtime/di/realtime_module.dart
// - PusherRemoteDataSource
// - PusherRepository
// - InitPusherUC, SubscribeChatUC, SubscribeMessagesUC,
//   ListenToBannersUC, ListenToGamesUC, SubscribeCounterUC
//
// app/di/app_module.dart
// - calls initCoreModule()
// - calls initFeature modules eagerly or lazily as needed
//
// Lazy feature loading strategy:
// - Initialize core services at app startup
// - Initialize home/profile/messages modules when the feature is first opened
// - Initialize realtime module only after login or entering a live room
// This reduces startup work and keeps feature boundaries clearer.
//
// b) How would you split FetchUserDataBloc into focused BLoCs?
//
// FetchUserDataBloc currently mixes profile loading, realtime subscriptions,
// config bootstrapping, analytics, wallet, badges, and engagement features.
// I would split it into:
//
// 1. ProfileBootstrapBloc
//    - FetchMyProfileUC
//    - FetchUserProfileUC
//
// 2. RealtimeConnectionBloc
//    - InitPusherUC
//    - SubscribeChatUC
//    - SubscribeMessagesUC
//    - ListenToBannersUC
//    - ListenToGamesUC
//    - SubscribeCounterUC
//
// 3. AppConfigBloc
//    - FetchConfigUC
//    - FetchCountriesUC
//
// 4. UserMetaBloc
//    - UpdateFCMTokenUC
//    - InitAnalyticsUC
//
// 5. UserRewardsBloc
//    - FetchUserBadgesUC
//    - FetchMyBadgesUC
//    - FetchLevelDataUC
//    - FetchWalletUC
//
// 6. UserActivityBloc
//    - FetchGiftHistoryUC
//    - FetchUserRoomsUC
//    - FetchSupporterUC
//    - FetchCpProfileUC
//    - FetchUserIntroUC
//
// c) Dependency diagram (ASCII)
//
//                    ┌──────────────────────┐
//                    │      Core Module      │
//                    │ Dio / Hive / Shared   │
//                    └──────────┬───────────┘
//                               │
//          ┌────────────────────┼────────────────────┐
//          │                    │                    │
//          ▼                    ▼                    ▼
//  ┌───────────────┐   ┌────────────────┐   ┌─────────────────┐
//  │  Home Module  │   │ Profile Module │   │ Realtime Module │
//  └──────┬────────┘   └───────┬────────┘   └────────┬────────┘
//         │                    │                     │
//         ▼                    ▼                     ▼
//   HomeRepository      ProfileRepository      PusherRepository
//         │                    │                     │
//         ▼                    ▼                     ▼
//    Home UseCases       Profile UseCases       Realtime UseCases
//         │                    │                     │
//         ├────────────┐       ├──────────────┐      ├──────────────┐
//         ▼            ▼       ▼              ▼      ▼              ▼
//   AppConfigBloc  ReelsBloc  ProfileBloc  RewardsBloc  RealtimeConnectionBloc
//                                  │
//                                  ▼
//                           UserActivityBloc
//
// Testability implications:
// - Smaller modules are easier to mock and test independently
// - Each BLoC has fewer constructor parameters and a clearer responsibility
// - Feature tests can register only the needed module dependencies
// - Replacing repositories/use cases with fakes becomes simpler
// - Reduced coupling lowers regression risk and improves maintainability
//
//
