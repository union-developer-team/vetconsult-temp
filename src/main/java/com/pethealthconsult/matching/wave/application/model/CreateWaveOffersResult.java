package com.pethealthconsult.matching.wave.application.model;

import java.util.List;
import java.util.Objects;

public class CreateWaveOffersResult {

    private final String waveUuid;
    private final int waveNo;
    private final int radiusM;
    private final List<String> offerUuids;

    private CreateWaveOffersResult(
        String waveUuid,
        int waveNo,
        int radiusM,
        List<String> offerUuids
    ) {
        this.waveUuid = Objects.requireNonNull(waveUuid, "waveUuid");
        this.waveNo = waveNo;
        this.radiusM = radiusM;
        this.offerUuids = List.copyOf(Objects.requireNonNull(offerUuids, "offerUuids"));
    }

    public static CreateWaveOffersResult of(
        String waveUuid,
        int waveNo,
        int radiusM,
        List<String> offerUuids
    ) {
        return new CreateWaveOffersResult(waveUuid, waveNo, radiusM, offerUuids);
    }

    public String getWaveUuid() {
        return waveUuid;
    }

    public int getWaveNo() {
        return waveNo;
    }

    public int getRadiusM() {
        return radiusM;
    }

    public List<String> getOfferUuids() {
        return offerUuids;
    }
}
