package com.pethealthconsult.matching.wave.adapter.in.web.dto.response;

import com.pethealthconsult.matching.wave.application.model.CreateWaveOffersResult;
import java.util.List;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder(access = AccessLevel.PRIVATE)
public class CreateWaveOffersResponseDto {

    private final String waveUuid;
    private final int waveNo;
    private final int radiusM;
    private final List<String> offerUuids;

    public static CreateWaveOffersResponseDto from(CreateWaveOffersResult result) {
        return CreateWaveOffersResponseDto.builder()
            .waveUuid(result.getWaveUuid())
            .waveNo(result.getWaveNo())
            .radiusM(result.getRadiusM())
            .offerUuids(result.getOfferUuids())
            .build();
    }
}
