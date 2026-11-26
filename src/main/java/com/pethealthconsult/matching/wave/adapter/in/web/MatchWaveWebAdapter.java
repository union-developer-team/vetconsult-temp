package com.pethealthconsult.matching.wave.adapter.in.web;

import com.pethealthconsult.global.web.response.ApiResponse;
import com.pethealthconsult.matching.wave.adapter.in.web.dto.request.CreateWaveOffersRequestDto;
import com.pethealthconsult.matching.wave.adapter.in.web.dto.request.OfferCandidateRequestDto;
import com.pethealthconsult.matching.wave.adapter.in.web.dto.response.CreateWaveOffersResponseDto;
import com.pethealthconsult.matching.wave.application.createwaveoffers.CreateWaveOffersCommand;
import com.pethealthconsult.matching.wave.application.createwaveoffers.CreateWaveOffersUseCase;
import com.pethealthconsult.matching.wave.application.createwaveoffers.OfferCandidate;
import com.pethealthconsult.matching.wave.application.model.CreateWaveOffersResult;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

/**
 * 워커·Mongo 후보 조회 도입 전 수동 검증용.
 */
@Profile({"dev", "local"})
@Component
@RequiredArgsConstructor
public class MatchWaveWebAdapter {

    private final CreateWaveOffersUseCase createWaveOffersUseCase;

    public ResponseEntity<ApiResponse<CreateWaveOffersResponseDto>> createWaveOffers(
        String requestUuid,
        CreateWaveOffersRequestDto requestDto
    ) {
        List<OfferCandidate> candidates = requestDto.getCandidates().stream()
            .map(this::toCandidate)
            .toList();

        CreateWaveOffersResult result = createWaveOffersUseCase.createWaveOffers(
            CreateWaveOffersCommand.of(
                requestUuid,
                requestDto.getWaveNo(),
                requestDto.getRadiusM(),
                candidates
            )
        );

        return ResponseEntity.ok(ApiResponse.success(CreateWaveOffersResponseDto.from(result)));
    }

    private OfferCandidate toCandidate(OfferCandidateRequestDto dto) {
        return OfferCandidate.of(
            dto.getVetUuid(),
            dto.getHospitalUuid(),
            dto.getDistanceM(),
            dto.getScore()
        );
    }
}
