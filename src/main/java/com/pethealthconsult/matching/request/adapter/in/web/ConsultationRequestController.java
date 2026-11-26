package com.pethealthconsult.matching.request.adapter.in.web;

import com.pethealthconsult.global.web.response.ApiResponse;
import com.pethealthconsult.matching.request.adapter.in.web.dto.request.StartMatchingRequestDto;
import com.pethealthconsult.matching.request.adapter.in.web.dto.response.ConsultationRequestResponseDto;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PatchMapping;
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
public class ConsultationRequestController {

    private final ConsultationRequestWebAdapter consultationRequestWebAdapter;

    @PatchMapping("/{requestUuid}/status")
    public ResponseEntity<ApiResponse<ConsultationRequestResponseDto>> updateStatus(
        @PathVariable String requestUuid,
        @Valid @RequestBody StartMatchingRequestDto requestDto
    ) {
        return consultationRequestWebAdapter.startMatching(requestUuid, requestDto);
    }
}
