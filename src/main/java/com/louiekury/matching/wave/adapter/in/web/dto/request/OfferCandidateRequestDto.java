package com.louiekury.matching.wave.adapter.in.web.dto.request;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder(access = AccessLevel.PRIVATE)
public class OfferCandidateRequestDto {

    @NotBlank
    private final String vetUuid;

    @NotBlank
    private final String hospitalUuid;

    @Min(0)
    private final int distanceM;

    @NotNull
    private final BigDecimal score;

    @JsonCreator
    public static OfferCandidateRequestDto of(
        @JsonProperty("vetUuid") String vetUuid,
        @JsonProperty("hospitalUuid") String hospitalUuid,
        @JsonProperty("distanceM") int distanceM,
        @JsonProperty("score") BigDecimal score
    ) {
        return OfferCandidateRequestDto.builder()
            .vetUuid(vetUuid)
            .hospitalUuid(hospitalUuid)
            .distanceM(distanceM)
            .score(score)
            .build();
    }
}
