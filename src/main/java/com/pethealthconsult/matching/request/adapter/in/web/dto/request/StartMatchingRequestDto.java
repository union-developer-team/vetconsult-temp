package com.pethealthconsult.matching.request.adapter.in.web.dto.request;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
public class StartMatchingRequestDto {

    @NotBlank
    private final String status;

    @JsonCreator
    public static StartMatchingRequestDto of(@JsonProperty("status") String status) {
        return StartMatchingRequestDto.builder()
            .status(status)
            .build();
    }
}
