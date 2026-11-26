#!/bin/bash
set -eu
BOOTSTRAP="${KAFKA_BOOTSTRAP:-kafka:9094}"
for i in $(seq 1 40); do
  if /opt/kafka/bin/kafka-topics.sh --bootstrap-server "$BOOTSTRAP" --list >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

create_topic() {
  name="$1"
  parts="$2"
  shift 2
  /opt/kafka/bin/kafka-topics.sh --bootstrap-server "$BOOTSTRAP" \
    --create --if-not-exists \
    --topic "$name" --partitions "$parts" --replication-factor 1 "$@"
}

# 키는 집계 uuid. presence 와 policy 는 최신 상태만 남기는 compact 토픽.
create_topic matching.request.v1 6
create_topic matching.offer.v1 6
create_topic consult.session.v1 6
create_topic consult.chat.v1 6
create_topic clinic.hospital.v1 3
create_topic clinic.vet.duty.v1 3
create_topic notification.dispatch.v1 6
create_topic vet.presence.v1 3 --config cleanup.policy=compact
create_topic platform.policy.v1 1 --config cleanup.policy=compact

/opt/kafka/bin/kafka-topics.sh --bootstrap-server "$BOOTSTRAP" --list
