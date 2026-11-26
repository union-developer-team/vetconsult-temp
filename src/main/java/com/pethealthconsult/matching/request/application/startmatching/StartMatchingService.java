package com.pethealthconsult.matching.request.application.startmatching;

import com.pethealthconsult.matching.request.application.model.ConsultationRequestResult;
import com.pethealthconsult.matching.request.application.port.out.ClaimConsultationRequestMatchingPort;
import com.pethealthconsult.matching.request.application.port.out.LoadConsultationRequestPort;
import com.pethealthconsult.matching.request.domain.ConsultationRequest;
import com.pethealthconsult.shared.exception.BusinessException;
import com.pethealthconsult.shared.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class StartMatchingService implements StartMatchingUseCase {

    private final ClaimConsultationRequestMatchingPort claimConsultationRequestMatchingPort;
    private final LoadConsultationRequestPort loadConsultationRequestPort;

    @Override
    @Transactional
    public ConsultationRequestResult startMatching(StartMatchingCommand command) {
        ConsultationRequest claimed = claimConsultationRequestMatchingPort.claimMatching(command.getRequestUuid())
            .orElseThrow(() -> rejectUnclaimed(command.getRequestUuid()));

        return ConsultationRequestResult.from(claimed);
    }

    private BusinessException rejectUnclaimed(String requestUuid) {
        if (loadConsultationRequestPort.findByUuid(requestUuid).isEmpty()) {
            return new BusinessException(ErrorCode.NOT_FOUND, "호출 요청을 찾을 수 없습니다.");
        }
        return new BusinessException(
            ErrorCode.VALIDATION_ERROR,
            "REQUESTED 상태에서만 MATCHING으로 변경할 수 있습니다."
        );
    }
}
