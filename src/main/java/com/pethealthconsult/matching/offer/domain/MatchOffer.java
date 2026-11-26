package com.pethealthconsult.matching.offer.domain;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Objects;

/**
 * 수의사 앱 콜 카드. 생성 시 상태는 OFFERED.
 */
public class MatchOffer {

    private final Long id;
    private final String uuid;
    private final Long requestId;
    private final Long waveId;
    private final String vetUuid;
    private final String hospitalUuid;
    private final int distanceM;
    private final BigDecimal score;
    private MatchOfferStatus status;
    private final LocalDateTime offeredAt;
    private final LocalDateTime respondBy;
    private LocalDateTime respondedAt;

    private MatchOffer(
        Long id,
        String uuid,
        Long requestId,
        Long waveId,
        String vetUuid,
        String hospitalUuid,
        int distanceM,
        BigDecimal score,
        MatchOfferStatus status,
        LocalDateTime offeredAt,
        LocalDateTime respondBy,
        LocalDateTime respondedAt
    ) {
        this.id = id;
        this.uuid = Objects.requireNonNull(uuid, "uuid");
        this.requestId = Objects.requireNonNull(requestId, "requestId");
        this.waveId = Objects.requireNonNull(waveId, "waveId");
        this.vetUuid = Objects.requireNonNull(vetUuid, "vetUuid");
        this.hospitalUuid = Objects.requireNonNull(hospitalUuid, "hospitalUuid");
        if (distanceM < 0) {
            throw new IllegalArgumentException("distanceM must be >= 0");
        }
        this.distanceM = distanceM;
        this.score = Objects.requireNonNull(score, "score");
        this.status = Objects.requireNonNull(status, "status");
        this.offeredAt = Objects.requireNonNull(offeredAt, "offeredAt");
        this.respondBy = Objects.requireNonNull(respondBy, "respondBy");
        this.respondedAt = respondedAt;
    }

    /**
     * 신규 제안. 저장 전 id는 null, 상태는 OFFERED.
     */
    public static MatchOffer create(
        String uuid,
        Long requestId,
        Long waveId,
        String vetUuid,
        String hospitalUuid,
        int distanceM,
        BigDecimal score,
        LocalDateTime offeredAt,
        LocalDateTime respondBy
    ) {
        return new MatchOffer(
            null,
            uuid,
            requestId,
            waveId,
            vetUuid,
            hospitalUuid,
            distanceM,
            score,
            MatchOfferStatus.OFFERED,
            offeredAt,
            respondBy,
            null
        );
    }

    public static MatchOffer restore(
        Long id,
        String uuid,
        Long requestId,
        Long waveId,
        String vetUuid,
        String hospitalUuid,
        int distanceM,
        BigDecimal score,
        MatchOfferStatus status,
        LocalDateTime offeredAt,
        LocalDateTime respondBy,
        LocalDateTime respondedAt
    ) {
        return new MatchOffer(
            id,
            uuid,
            requestId,
            waveId,
            vetUuid,
            hospitalUuid,
            distanceM,
            score,
            status,
            offeredAt,
            respondBy,
            respondedAt
        );
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

    public Long getWaveId() {
        return waveId;
    }

    public String getVetUuid() {
        return vetUuid;
    }

    public String getHospitalUuid() {
        return hospitalUuid;
    }

    public int getDistanceM() {
        return distanceM;
    }

    public BigDecimal getScore() {
        return score;
    }

    public MatchOfferStatus getStatus() {
        return status;
    }

    public LocalDateTime getOfferedAt() {
        return offeredAt;
    }

    public LocalDateTime getRespondBy() {
        return respondBy;
    }

    public LocalDateTime getRespondedAt() {
        return respondedAt;
    }
}
