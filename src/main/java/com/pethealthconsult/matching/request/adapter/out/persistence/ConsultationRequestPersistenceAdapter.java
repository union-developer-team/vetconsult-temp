package com.pethealthconsult.matching.request.adapter.out.persistence;

import com.pethealthconsult.matching.request.application.port.out.ClaimConsultationRequestMatchingPort;
import com.pethealthconsult.matching.request.application.port.out.LoadConsultationRequestPort;
import com.pethealthconsult.matching.request.domain.ConsultationRequest;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ConsultationRequestPersistenceAdapter
    implements LoadConsultationRequestPort, ClaimConsultationRequestMatchingPort {

    private final ConsultationRequestJpaRepository consultationRequestJpaRepository;

    @Override
    public Optional<ConsultationRequest> findByUuid(String requestUuid) {
        return consultationRequestJpaRepository.findByUuid(requestUuid)
            .map(ConsultationRequestPersistenceMapper::toDomain);
    }

    @Override
    public Optional<ConsultationRequest> claimMatching(String requestUuid) {
        int updated = consultationRequestJpaRepository.claimMatchingFromRequested(requestUuid);
        if (updated != 1) {
            return Optional.empty();
        }
        return consultationRequestJpaRepository.findByUuid(requestUuid)
            .map(ConsultationRequestPersistenceMapper::toDomain);
    }
}
