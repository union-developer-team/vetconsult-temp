package com.pethealthconsult.matching.wave.application.createwaveoffers;

import java.util.List;
import java.util.Objects;

public class CreateWaveOffersCommand {

    private final String requestUuid;
    private final int waveNo;
    private final int radiusM;
    private final List<OfferCandidate> candidates;

    private CreateWaveOffersCommand(
        String requestUuid,
        int waveNo,
        int radiusM,
        List<OfferCandidate> candidates
    ) {
        this.requestUuid = Objects.requireNonNull(requestUuid, "requestUuid");
        this.waveNo = waveNo;
        this.radiusM = radiusM;
        this.candidates = List.copyOf(Objects.requireNonNull(candidates, "candidates"));
    }

    public static CreateWaveOffersCommand of(
        String requestUuid,
        int waveNo,
        int radiusM,
        List<OfferCandidate> candidates
    ) {
        return new CreateWaveOffersCommand(requestUuid, waveNo, radiusM, candidates);
    }

    public String getRequestUuid() {
        return requestUuid;
    }

    public int getWaveNo() {
        return waveNo;
    }

    public int getRadiusM() {
        return radiusM;
    }

    public List<OfferCandidate> getCandidates() {
        return candidates;
    }
}
