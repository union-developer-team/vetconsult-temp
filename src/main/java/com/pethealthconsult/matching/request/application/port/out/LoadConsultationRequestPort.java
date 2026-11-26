package com.pethealthconsult.matching.request.application.port.out;

import com.pethealthconsult.matching.request.domain.ConsultationRequest;
import java.util.Optional;

public interface LoadConsultationRequestPort {

    Optional<ConsultationRequest> findByUuid(String requestUuid);
}
