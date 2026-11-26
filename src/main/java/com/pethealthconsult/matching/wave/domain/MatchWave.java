package com.pethealthconsult.matching.wave.domain;

import java.time.LocalDateTime;
import java.util.Objects;

/**
 * 매칭 차수. 반경을 넓혀 가며 후보에게 콜을 보내는 한 라운드.
 */
public class MatchWave {

    private final Long id;
    private final String uuid;
    private final Long requestId;
    private final int waveNo;
    private final int radiusM;
    private final LocalDateTime startedAt;
    private LocalDateTime finishedAt;

    private MatchWave(
        Long id,
        String uuid,
        Long requestId,
        int waveNo,
        int radiusM,
        LocalDateTime startedAt,
        LocalDateTime finishedAt
    ) {
        this.id = id;
        this.uuid = Objects.requireNonNull(uuid, "uuid");
        this.requestId = Objects.requireNonNull(requestId, "requestId");
        if (waveNo < 1) {
            throw new IllegalArgumentException("waveNo must be >= 1");
        }
        if (radiusM < 1) {
            throw new IllegalArgumentException("radiusM must be >= 1");
        }
        this.waveNo = waveNo;
        this.radiusM = radiusM;
        this.startedAt = Objects.requireNonNull(startedAt, "startedAt");
        this.finishedAt = finishedAt;
    }

    /**
     * 신규 차수. 저장 전 id는 null.
     */
    public static MatchWave create(
        String uuid,
        Long requestId,
        int waveNo,
        int radiusM,
        LocalDateTime startedAt
    ) {
        return new MatchWave(null, uuid, requestId, waveNo, radiusM, startedAt, null);
    }

    public static MatchWave restore(
        Long id,
        String uuid,
        Long requestId,
        int waveNo,
        int radiusM,
        LocalDateTime startedAt,
        LocalDateTime finishedAt
    ) {
        return new MatchWave(id, uuid, requestId, waveNo, radiusM, startedAt, finishedAt);
    }

    public void finish(LocalDateTime finishedAt) {
        this.finishedAt = Objects.requireNonNull(finishedAt, "finishedAt");
    }

    public Long getId() {
        return id;
    }

    public String getUuid() {
        return uuid;
    }

    public Long getRequestId() {
        return requestId;
    }

    public int getWaveNo() {
        return waveNo;
    }

    public int getRadiusM() {
        return radiusM;
    }

    public LocalDateTime getStartedAt() {
        return startedAt;
    }

    public LocalDateTime getFinishedAt() {
        return finishedAt;
    }
}
