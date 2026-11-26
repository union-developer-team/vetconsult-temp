package com.pethealthconsult.matching.wave.adapter.in.web.dto.request;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder(access = AccessLevel.PRIVATE)
public class CreateWaveOffersRequestDto {

    @NotNull
    @Min(1)
    private final Integer waveNo;

    @NotNull
    @Min(1)
    private final Integer radiusM;

    @NotEmpty
    @Valid
    private final List<OfferCandidateRequestDto> candidates;

    @JsonCreator
    public static CreateWaveOffersRequestDto of(
        @JsonProperty("waveNo") Integer waveNo,
        @JsonProperty("radiusM") Integer radiusM,
        @JsonProperty("candidates") List<OfferCandidateRequestDto> candidates
    ) {
        return CreateWaveOffersRequestDto.builder()
            .waveNo(waveNo)
            .radiusM(radiusM)
            .candidates(candidates)
            .build();
    }
}
