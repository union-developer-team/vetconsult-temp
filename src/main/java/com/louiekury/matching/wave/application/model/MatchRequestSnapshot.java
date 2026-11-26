package com.louiekury.matching.wave.application.model;

import java.util.Objects;

/**
 * wave 유스케이스가 필요로 하는 호출 요청 요약 (request 모듈 도메인 비참조).
 */
public class MatchRequestSnapshot {

    private final Long id;
    private final String uuid;
    private final String status;

    private MatchRequestSnapshot(Long id, String uuid, String status) {
        this.id = Objects.requireNonNull(id, "id");
        this.uuid = Objects.requireNonNull(uuid, "uuid");
        this.status = Objects.requireNonNull(status, "status");
    }

    public static MatchRequestSnapshot of(Long id, String uuid, String status) {
        return new MatchRequestSnapshot(id, uuid, status);
    }

    public Long getId() {
        return id;
    }

    public String getUuid() {
        return uuid;
    }

    public String getStatus() {
        return status;
    }
}
