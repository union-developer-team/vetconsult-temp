package com.louiekury.matching.wave.application.createwaveoffers;

import java.math.BigDecimal;
import java.util.Objects;

/**
 * wave에 넣을 수의사 후보 (이번 단계는 시드/고정 목록에서 전달).
 */
public class OfferCandidate {

    private final String vetUuid;
    private final String hospitalUuid;
    private final int distanceM;
    private final BigDecimal score;

    private OfferCandidate(
        String vetUuid,
        String hospitalUuid,
        int distanceM,
        BigDecimal score
    ) {
        this.vetUuid = Objects.requireNonNull(vetUuid, "vetUuid");
        this.hospitalUuid = Objects.requireNonNull(hospitalUuid, "hospitalUuid");
        if (distanceM < 0) {
            throw new IllegalArgumentException("distanceM must be >= 0");
        }
        this.distanceM = distanceM;
        this.score = Objects.requireNonNull(score, "score");
    }

    public static OfferCandidate of(
        String vetUuid,
        String hospitalUuid,
        int distanceM,
        BigDecimal score
    ) {
        return new OfferCandidate(vetUuid, hospitalUuid, distanceM, score);
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
}
