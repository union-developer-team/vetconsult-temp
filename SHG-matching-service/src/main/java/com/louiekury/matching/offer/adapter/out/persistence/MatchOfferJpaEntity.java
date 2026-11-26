package com.louiekury.matching.offer.adapter.out.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "match_offer")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MatchOfferJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "uuid", nullable = false, length = 36)
    private String uuid;

    @Column(name = "request_id", nullable = false)
    private Long requestId;

    @Column(name = "wave_id", nullable = false)
    private Long waveId;

    @Column(name = "vet_uuid", nullable = false, length = 36)
    private String vetUuid;

    @Column(name = "hospital_uuid", nullable = false, length = 36)
    private String hospitalUuid;

    @Column(name = "distance_m", nullable = false)
    private int distanceM;

    @Column(name = "score", nullable = false, precision = 6, scale = 2)
    private BigDecimal score;

    @Column(name = "status", nullable = false, length = 20)
    private String status;

    @Column(name = "offered_at", nullable = false)
    private LocalDateTime offeredAt;

    @Column(name = "respond_by", nullable = false)
    private LocalDateTime respondBy;

    @Column(name = "responded_at")
    private LocalDateTime respondedAt;

    static MatchOfferJpaEntity newOffer(
        String uuid,
        Long requestId,
        Long waveId,
        String vetUuid,
        String hospitalUuid,
        int distanceM,
        BigDecimal score,
        String status,
        LocalDateTime offeredAt,
        LocalDateTime respondBy,
        LocalDateTime respondedAt
    ) {
        MatchOfferJpaEntity entity = new MatchOfferJpaEntity();
        entity.uuid = uuid;
        entity.requestId = requestId;
        entity.waveId = waveId;
        entity.vetUuid = vetUuid;
        entity.hospitalUuid = hospitalUuid;
        entity.distanceM = distanceM;
        entity.score = score;
        entity.status = status;
        entity.offeredAt = offeredAt;
        entity.respondBy = respondBy;
        entity.respondedAt = respondedAt;
        return entity;
    }
}
