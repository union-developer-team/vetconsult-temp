package com.louiekury.matching.request.adapter.in.web;

import com.louiekury.matching.global.web.response.ApiResponse;
import com.louiekury.matching.request.adapter.in.web.dto.request.StartMatchingRequestDto;
import com.louiekury.matching.request.adapter.in.web.dto.response.ConsultationRequestResponseDto;
import com.louiekury.matching.request.application.model.ConsultationRequestResult;
import com.louiekury.matching.request.application.startmatching.StartMatchingCommand;
import com.louiekury.matching.request.application.startmatching.StartMatchingUseCase;
import com.louiekury.matching.request.domain.ConsultationRequestStatus;
import com.louiekury.matching.shared.exception.BusinessException;
import com.louiekury.matching.shared.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

@Profile({"dev", "local"})
@Component
@RequiredArgsConstructor
public class ConsultationRequestWebAdapter {

    private final StartMatchingUseCase startMatchingUseCase;

    public ResponseEntity<ApiResponse<ConsultationRequestResponseDto>> startMatching(
        String requestUuid,
        StartMatchingRequestDto requestDto
    ) {
        if (!ConsultationRequestStatus.MATCHING.name().equals(requestDto.getStatus())) {
            throw new BusinessException(
                ErrorCode.VALIDATION_ERROR,
                "현재는 status=MATCHING 만 지원합니다."
            );
        }

        ConsultationRequestResult result = startMatchingUseCase.startMatching(
            StartMatchingCommand.of(requestUuid)
        );
        return ResponseEntity.ok(ApiResponse.success(ConsultationRequestResponseDto.from(result)));
    }
}
