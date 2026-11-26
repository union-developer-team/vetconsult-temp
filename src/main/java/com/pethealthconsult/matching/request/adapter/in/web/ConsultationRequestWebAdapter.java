package com.pethealthconsult.matching.request.adapter.in.web;

import com.pethealthconsult.global.web.response.ApiResponse;
import com.pethealthconsult.matching.request.adapter.in.web.dto.request.StartMatchingRequestDto;
import com.pethealthconsult.matching.request.adapter.in.web.dto.response.ConsultationRequestResponseDto;
import com.pethealthconsult.matching.request.application.model.ConsultationRequestResult;
import com.pethealthconsult.matching.request.application.startmatching.StartMatchingCommand;
import com.pethealthconsult.matching.request.application.startmatching.StartMatchingUseCase;
import com.pethealthconsult.matching.request.domain.ConsultationRequestStatus;
import com.pethealthconsult.shared.exception.BusinessException;
import com.pethealthconsult.shared.exception.ErrorCode;
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
