package com.louiekury.matching.wave.adapter.out.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "match_wave")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MatchWaveJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "uuid", nullable = false, length = 36)
    private String uuid;

    @Column(name = "request_id", nullable = false)
    private Long requestId;

    @Column(name = "wave_no", nullable = false)
    private int waveNo;

    @Column(name = "radius_m", nullable = false)
    private int radiusM;

    @Column(name = "started_at", nullable = false)
    private LocalDateTime startedAt;

    @Column(name = "finished_at")
    private LocalDateTime finishedAt;

    static MatchWaveJpaEntity newWave(
        String uuid,
        Long requestId,
        int waveNo,
        int radiusM,
        LocalDateTime startedAt,
        LocalDateTime finishedAt
    ) {
        MatchWaveJpaEntity entity = new MatchWaveJpaEntity();
        entity.uuid = uuid;
        entity.requestId = requestId;
        entity.waveNo = waveNo;
        entity.radiusM = radiusM;
        entity.startedAt = startedAt;
        entity.finishedAt = finishedAt;
        return entity;
    }
}
