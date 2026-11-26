package com.louiekury.matching.wave.adapter.out.persistence;

import com.louiekury.matching.request.adapter.out.persistence.ConsultationRequestJpaRepository;
import com.louiekury.matching.wave.application.model.MatchRequestSnapshot;
import com.louiekury.matching.wave.application.port.out.LoadMatchRequestPort;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * consultation_request에서 id/uuid/status만 읽어 wave 유스케이스에 전달한다.
 */
@Component
@RequiredArgsConstructor
public class MatchRequestLoadAdapter implements LoadMatchRequestPort {

    private final ConsultationRequestJpaRepository consultationRequestJpaRepository;

    @Override
    public Optional<MatchRequestSnapshot> findByUuid(String requestUuid) {
        return consultationRequestJpaRepository.findByUuid(requestUuid)
            .map(entity -> MatchRequestSnapshot.of(
                entity.getId(),
                entity.getUuid(),
                entity.getStatus()
            ));
    }
}
