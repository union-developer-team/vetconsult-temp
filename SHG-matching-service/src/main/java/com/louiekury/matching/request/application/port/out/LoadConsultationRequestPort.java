package com.louiekury.matching.request.application.port.out;

import com.louiekury.matching.request.domain.ConsultationRequest;
import java.util.Optional;

public interface LoadConsultationRequestPort {

    Optional<ConsultationRequest> findByUuid(String requestUuid);
}
