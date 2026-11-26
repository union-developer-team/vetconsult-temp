// 실시간 위치, 채팅 원문, 화상 이벤트, 매칭 추적.
// 하트비트 TTL 은 데모에서 2시간. 운영 값은 90초로 바꾼다.

const app = db.getSiblingDB("vetconsult");

app.createCollection("vet_live_location", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["vet_uuid", "status", "location", "accept_chat", "accept_video", "service_radius_m", "hospital_uuid", "duty_session_uuid", "heartbeat_at"],
      properties: {
        vet_uuid: { bsonType: "string" },
        status: { enum: ["AVAILABLE", "BUSY", "BREAK"] },
        location: {
          bsonType: "object",
          required: ["type", "coordinates"],
          properties: {
            type: { enum: ["Point"] },
            coordinates: { bsonType: "array", minItems: 2, maxItems: 2 }
          }
        },
        accept_chat: { bsonType: "bool" },
        accept_video: { bsonType: "bool" },
        service_radius_m: { bsonType: "int" },
        hospital_uuid: { bsonType: "string" },
        duty_session_uuid: { bsonType: "string" },
        heartbeat_at: { bsonType: "date" }
      }
    }
  }
});
app.vet_live_location.createIndex({ location: "2dsphere" });
app.vet_live_location.createIndex({ vet_uuid: 1 }, { unique: true });
app.vet_live_location.createIndex({ status: 1, accept_video: 1, accept_chat: 1 });
app.vet_live_location.createIndex({ heartbeat_at: 1 }, { expireAfterSeconds: 7200 });

app.createCollection("chat_messages", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["room_uuid", "client_msg_id", "sender_uuid", "sender_role", "type", "sent_at"],
      properties: {
        room_uuid: { bsonType: "string" },
        client_msg_id: { bsonType: "string" },
        sender_uuid: { bsonType: "string" },
        sender_role: { enum: ["CAREGIVER", "VETERINARIAN", "SYSTEM"] },
        type: { enum: ["TEXT", "IMAGE", "SYSTEM"] },
        body: { bsonType: "string" },
        sent_at: { bsonType: "date" }
      }
    }
  }
});
app.chat_messages.createIndex({ room_uuid: 1, sent_at: 1 });
app.chat_messages.createIndex({ room_uuid: 1, client_msg_id: 1 }, { unique: true });

app.createCollection("chat_room_state");
app.chat_room_state.createIndex({ room_uuid: 1 }, { unique: true });
app.chat_room_state.createIndex({ "participants.uuid": 1, updated_at: -1 });

app.createCollection("video_events");
app.video_events.createIndex({ video_session_uuid: 1, at: 1 });

app.createCollection("match_trace");
app.match_trace.createIndex({ request_uuid: 1, at: 1 });

const now = new Date();
app.vet_live_location.insertMany([
  {
    vet_uuid: "v1000000-0000-4000-8000-000000000001",
    status: "BUSY",
    location: { type: "Point", coordinates: [127.026382, 37.501274] },
    accept_chat: true,
    accept_video: true,
    service_radius_m: NumberInt(5000),
    hospital_uuid: "h1000000-0000-4000-8000-000000000001",
    duty_session_uuid: "du000000-0000-4000-8000-000000000001",
    heartbeat_at: now
  },
  {
    vet_uuid: "v1000000-0000-4000-8000-000000000002",
    status: "AVAILABLE",
    location: { type: "Point", coordinates: [129.163534, 35.163112] },
    accept_chat: true,
    accept_video: true,
    service_radius_m: NumberInt(4000),
    hospital_uuid: "h1000000-0000-4000-8000-000000000002",
    duty_session_uuid: "du000000-0000-4000-8000-000000000002",
    heartbeat_at: now
  }
]);

app.chat_messages.insertMany([
  {
    room_uuid: "cr000000-0000-4000-8000-000000000001",
    client_msg_id: "m-001",
    sender_uuid: "a1000000-0000-4000-8000-000000000001",
    sender_role: "CAREGIVER",
    type: "TEXT",
    body: "콩이가 계속 구토해서 화상으로 보여드릴게요",
    sent_at: new Date("2026-11-23T05:00:20Z")
  },
  {
    room_uuid: "cr000000-0000-4000-8000-000000000001",
    client_msg_id: "m-002",
    sender_uuid: "v1000000-0000-4000-8000-000000000001",
    sender_role: "VETERINARIAN",
    type: "TEXT",
    body: "화면 켜 주세요. 잇몸 색부터 보겠습니다",
    sent_at: new Date("2026-11-23T05:00:30Z")
  }
]);

app.chat_room_state.insertOne({
  room_uuid: "cr000000-0000-4000-8000-000000000001",
  consultation_uuid: "c1000000-0000-4000-8000-000000000003",
  participants: [
    { uuid: "a1000000-0000-4000-8000-000000000001", role: "CAREGIVER", unread: 1 },
    { uuid: "v1000000-0000-4000-8000-000000000001", role: "VETERINARIAN", unread: 0 }
  ],
  last_message: "화면 켜 주세요. 잇몸 색부터 보겠습니다",
  updated_at: new Date("2026-11-23T05:00:30Z")
});

app.video_events.insertOne({
  video_session_uuid: "vs000000-0000-4000-8000-000000000001",
  type: "JOINED",
  participant_uuid: "v1000000-0000-4000-8000-000000000001",
  at: new Date("2026-11-23T05:00:28Z")
});

app.match_trace.insertMany([
  {
    request_uuid: "rq000000-0000-4000-8000-000000000001",
    type: "WAVE_OPENED",
    wave_no: 1,
    radius_m: 3000,
    at: new Date("2026-11-23T05:00:00Z")
  },
  {
    request_uuid: "rq000000-0000-4000-8000-000000000001",
    type: "OFFER_ACCEPTED",
    vet_uuid: "v1000000-0000-4000-8000-000000000001",
    distance_m: NumberInt(480),
    at: new Date("2026-11-23T05:00:18Z")
  }
]);
