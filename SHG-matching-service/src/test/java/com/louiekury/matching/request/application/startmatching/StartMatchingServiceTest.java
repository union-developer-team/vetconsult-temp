package com.louiekury.matching.request.application.startmatching;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.louiekury.matching.request.application.model.ConsultationRequestResult;
import com.louiekury.matching.request.application.port.out.ClaimConsultationRequestMatchingPort;
import com.louiekury.matching.request.application.port.out.LoadConsultationRequestPort;
import com.louiekury.matching.request.domain.ConsultationRequest;
import com.louiekury.matching.request.domain.ConsultationRequestStatus;
import com.louiekury.matching.shared.exception.BusinessException;
import com.louiekury.matching.shared.exception.ErrorCode;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class StartMatchingServiceTest {

    @Mock
    private ClaimConsultationRequestMatchingPort claimConsultationRequestMatchingPort;

    @Mock
    private LoadConsultationRequestPort loadConsultationRequestPort;

    @InjectMocks
    private StartMatchingService startMatchingService;

    @Test
    @DisplayName("선점에 성공하면 MATCHING 결과를 반환한다")
    void returnsMatchingWhenClaimSucceeds() {
        ConsultationRequest claimed = sample("rq-1", ConsultationRequestStatus.MATCHING);
        when(claimConsultationRequestMatchingPort.claimMatching("rq-1"))
            .thenReturn(Optional.of(claimed));

        ConsultationRequestResult result = startMatchingService.startMatching(StartMatchingCommand.of("rq-1"));

        assertEquals("rq-1", result.getUuid());
        assertEquals(ConsultationRequestStatus.MATCHING, result.getStatus());
        verifyNoInteractions(loadConsultationRequestPort);
    }

    @Test
    @DisplayName("선점 실패이고 요청이 없으면 NOT_FOUND")
    void notFoundWhenMissing() {
        when(claimConsultationRequestMatchingPort.claimMatching("missing"))
            .thenReturn(Optional.empty());
        when(loadConsultationRequestPort.findByUuid("missing"))
            .thenReturn(Optional.empty());

        BusinessException ex = assertThrows(
            BusinessException.class,
            () -> startMatchingService.startMatching(StartMatchingCommand.of("missing"))
        );
        assertEquals(ErrorCode.NOT_FOUND, ex.getErrorCode());
    }

    @Test
    @DisplayName("선점 실패이고 이미 다른 상태면 VALIDATION_ERROR")
    void validationWhenAlreadyClaimed() {
        when(claimConsultationRequestMatchingPort.claimMatching("rq-2"))
            .thenReturn(Optional.empty());
        when(loadConsultationRequestPort.findByUuid("rq-2"))
            .thenReturn(Optional.of(sample("rq-2", ConsultationRequestStatus.MATCHING)));

        BusinessException ex = assertThrows(
            BusinessException.class,
            () -> startMatchingService.startMatching(StartMatchingCommand.of("rq-2"))
        );
        assertEquals(ErrorCode.VALIDATION_ERROR, ex.getErrorCode());
    }

    private static ConsultationRequest sample(String uuid, ConsultationRequestStatus status) {
        LocalDateTime now = LocalDateTime.now();
        return ConsultationRequest.restore(
            1L,
            uuid,
            "a1000000-0000-4000-8000-000000000001",
            "p1000000-0000-4000-8000-000000000001",
            "ms000000-0000-4000-8000-000000000001",
            "CHAT",
            false,
            status,
            new BigDecimal("37.497900"),
            new BigDecimal("127.028100"),
            "wydm9",
            "서울",
            "서울특별시",
            "강남구",
            3000,
            "memo",
            now,
            now.plusMinutes(10),
            null,
            null,
            null
        );
    }
}
