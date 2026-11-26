package com.louiekury.matching.wave.adapter.in.web;

import com.louiekury.matching.global.web.response.ApiResponse;
import com.louiekury.matching.wave.adapter.in.web.dto.request.CreateWaveOffersRequestDto;
import com.louiekury.matching.wave.adapter.in.web.dto.response.CreateWaveOffersResponseDto;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 워커 도입 전 수동 검증용 임시 API.
 * prod 등 운영 프로필에서는 등록되지 않는다.
 */
@Profile({"dev", "local"})
@RestController
@RequestMapping("/api/matching/requests")
@RequiredArgsConstructor
public class MatchWaveController {

    private final MatchWaveWebAdapter matchWaveWebAdapter;

    @PostMapping("/{requestUuid}/waves")
    public ResponseEntity<ApiResponse<CreateWaveOffersResponseDto>> createWaveOffers(
        @PathVariable String requestUuid,
        @Valid @RequestBody CreateWaveOffersRequestDto requestDto
    ) {
        return matchWaveWebAdapter.createWaveOffers(requestUuid, requestDto);
    }
}
