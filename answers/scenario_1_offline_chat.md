# Scenario 1: Offline-First Chat Architecture

---

## 1. Architecture Design

### Local Storage Strategy

I would design the offline chat using a local storage solution like Hive, where messages are stored immediately when the user sends them. Each message would have a status such as pending, sent, or failed.

### Sync Strategy: Optimistic Local-First

1. **Write locally first** — message is saved to Hive with status `pending` and shown in UI immediately.
2. **Send to server** — Dio picks it up from a background sync queue.
3. **On success** — update status to `sent`.
4. **On failure** — keep status as `pending`.

The UI should rely on the local database as the single source of truth, while the sync layer handles communication with the network and keeps the data updated.

### Conflict Resolution

Conflicts in 1-on-1 chat are simpler than group chat. My rules:

- **Message ordering**: Use **server timestamp** as the source of truth for ordering, while local timestamps are used temporarily for pending messages.

---

## 2. Sprint 1 (Weeks 1–2): MVP — Make Messages Survive Offline

**Goal: Messages don't disappear when the user loses connection.**

- Set up Hive boxes and message model
- Implement `MessageRepository` — single source of truth that reads from local DB
- Build `SyncQueue` — a simple service that watches for `pending` messages and upload them to the server.
- Save the message locally, show it immediately in the UI, and send it in the background.
- Show message status indicators: pending (clock icon), sent (single check), delivered (double check)

The goal is to make the message persistent locally first, then handle syncing in the background.
---

## 3. Sprint 2 (Weeks 3–4): Real Sync — Reconnection & History

**Goal: App feels seamless when connection comes and goes.**

- Implement connectivity listener to detect when the device goes back online. 
- For message history, I would implement pagination where the UI reads from the local database first, and older messages are fetched lazily from the server as needed. This keeps the app fast and scalable.

---

## 4. Data Model
```
    @HiveType(typeId: 0)
    class LocalMessage extends HiveObject {
    @HiveField(0)
    final String clientMessageId;
    
    @HiveField(1)
    String? serverMessageId;
    
    @HiveField(2)
    final String conversationId;
    
    @HiveField(3)
    final String senderId;
    
    @HiveField(4)
    final String content;
    
    @HiveField(5)
    final String messageType;
    
    @HiveField(6)
    String status;
    
    @HiveField(7)
    final DateTime localCreatedAt;
    
    @HiveField(8)
    DateTime? serverCreatedAt;
    
    @HiveField(9)
    final bool isMine;
    
    @HiveField(10)
    DateTime updatedAt;
    
    LocalMessage({
    required this.clientMessageId,
    this.serverMessageId,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.status,
    required this.localCreatedAt,
    this.serverCreatedAt,
    required this.isMine,
    required this.updatedAt,
    });
    }
```