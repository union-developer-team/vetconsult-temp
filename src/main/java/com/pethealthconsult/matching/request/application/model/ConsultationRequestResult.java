package com.pethealthconsult.matching.request.application.model;

import com.pethealthconsult.matching.request.domain.ConsultationRequest;
import com.pethealthconsult.matching.request.domain.ConsultationRequestStatus;
import java.util.Objects;

public class ConsultationRequestResult {

    private final String uuid;
    private final ConsultationRequestStatus status;

    private ConsultationRequestResult(String uuid, ConsultationRequestStatus status) {
        this.uuid = Objects.requireNonNull(uuid, "uuid");
        this.status = Objects.requireNonNull(status, "status");
    }

    public static ConsultationRequestResult from(ConsultationRequest request) {
        return new ConsultationRequestResult(request.getUuid(), request.getStatus());
    }

    public String getUuid() {
        return uuid;
    }

    public ConsultationRequestStatus getStatus() {
        return status;
    }
}
