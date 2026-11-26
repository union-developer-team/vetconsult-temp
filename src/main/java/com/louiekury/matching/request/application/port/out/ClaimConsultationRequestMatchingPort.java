package com.louiekury.matching.request.application.port.out;

import com.louiekury.matching.request.domain.ConsultationRequest;
import java.util.Optional;

/**
 * REQUESTED → MATCHING 원자적 선점.
 * DB에서 status 조건 갱신에 성공한 호출만 결과를 반환한다.
 */
public interface ClaimConsultationRequestMatchingPort {

    Optional<ConsultationRequest> claimMatching(String requestUuid);
}
