package com.pethealthconsult.matching.request.adapter.in.web.dto.response;

import com.pethealthconsult.matching.request.application.model.ConsultationRequestResult;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder(access = AccessLevel.PRIVATE)
public class ConsultationRequestResponseDto {

    private final String uuid;
    private final String status;

    public static ConsultationRequestResponseDto from(ConsultationRequestResult result) {
        return ConsultationRequestResponseDto.builder()
            .uuid(result.getUuid())
            .status(result.getStatus().name())
            .build();
    }
}
