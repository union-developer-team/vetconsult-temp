package com.louiekury.matching.request.domain;

import com.louiekury.matching.shared.exception.BusinessException;
import com.louiekury.matching.shared.exception.ErrorCode;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Objects;

public class ConsultationRequest {

    private final Long id;
    private final String uuid;
    private final String caregiverUuid;
    private final String petUuid;
    private final String medicalSubjectUuid;
    private final String channel;
    private final boolean emergency;
    private ConsultationRequestStatus status;
    private final BigDecimal originLat;
    private final BigDecimal originLng;
    private final String geohash;
    private final String region;
    private final String si;
    private final String gu;
    private final int searchRadiusM;
    private final String symptomMemo;
    private final LocalDateTime requestedAt;
    private final LocalDateTime expireAt;
    private String assignedVetUuid;
    private String assignedHospitalUuid;
    private LocalDateTime assignedAt;

    private ConsultationRequest(
        Long id,
        String uuid,
        String caregiverUuid,
        String petUuid,
        String medicalSubjectUuid,
        String channel,
        boolean emergency,
        ConsultationRequestStatus status,
        BigDecimal originLat,
        BigDecimal originLng,
        String geohash,
        String region,
        String si,
        String gu,
        int searchRadiusM,
        String symptomMemo,
        LocalDateTime requestedAt,
        LocalDateTime expireAt,
        String assignedVetUuid,
        String assignedHospitalUuid,
        LocalDateTime assignedAt
    ) {
        this.id = id;
        this.uuid = Objects.requireNonNull(uuid, "uuid");
        this.caregiverUuid = Objects.requireNonNull(caregiverUuid, "caregiverUuid");
        this.petUuid = Objects.requireNonNull(petUuid, "petUuid");
        this.medicalSubjectUuid = Objects.requireNonNull(medicalSubjectUuid, "medicalSubjectUuid");
        this.channel = Objects.requireNonNull(channel, "channel");
        this.emergency = emergency;
        this.status = Objects.requireNonNull(status, "status");
        this.originLat = Objects.requireNonNull(originLat, "originLat");
        this.originLng = Objects.requireNonNull(originLng, "originLng");
        this.geohash = Objects.requireNonNull(geohash, "geohash");
        this.region = Objects.requireNonNull(region, "region");
        this.si = Objects.requireNonNull(si, "si");
        this.gu = Objects.requireNonNull(gu, "gu");
        this.searchRadiusM = searchRadiusM;
        this.symptomMemo = symptomMemo;
        this.requestedAt = Objects.requireNonNull(requestedAt, "requestedAt");
        this.expireAt = Objects.requireNonNull(expireAt, "expireAt");
        this.assignedVetUuid = assignedVetUuid;
        this.assignedHospitalUuid = assignedHospitalUuid;
        this.assignedAt = assignedAt;
    }

    public static ConsultationRequest restore(
        Long id,
        String uuid,
        String caregiverUuid,
        String petUuid,
        String medicalSubjectUuid,
        String channel,
        boolean emergency,
        ConsultationRequestStatus status,
        BigDecimal originLat,
        BigDecimal originLng,
        String geohash,
        String region,
        String si,
        String gu,
        int searchRadiusM,
        String symptomMemo,
        LocalDateTime requestedAt,
        LocalDateTime expireAt,
        String assignedVetUuid,
        String assignedHospitalUuid,
        LocalDateTime assignedAt
    ) {
        return new ConsultationRequest(
            id,
            uuid,
            caregiverUuid,
            petUuid,
            medicalSubjectUuid,
            channel,
            emergency,
            status,
            originLat,
            originLng,
            geohash,
            region,
            si,
            gu,
            searchRadiusM,
            symptomMemo,
            requestedAt,
            expireAt,
            assignedVetUuid,
            assignedHospitalUuid,
            assignedAt
        );
    }

    public void markMatching() {
        if (this.status != ConsultationRequestStatus.REQUESTED) {
            throw new BusinessException(
                ErrorCode.VALIDATION_ERROR,
                "REQUESTED 상태에서만 MATCHING으로 변경할 수 있습니다. 현재: " + this.status
            );
        }
        this.status = ConsultationRequestStatus.MATCHING;
    }

    public Long getId() {
        return id;
    }

    public String getUuid() {
        return uuid;
    }

    public String getCaregiverUuid() {
        return caregiverUuid;
    }

    public String getPetUuid() {
        return petUuid;
    }

    public String getMedicalSubjectUuid() {
        return medicalSubjectUuid;
    }

    public String getChannel() {
        return channel;
    }

    public boolean isEmergency() {
        return emergency;
    }

    public ConsultationRequestStatus getStatus() {
        return status;
    }

    public BigDecimal getOriginLat() {
        return originLat;
    }

    public BigDecimal getOriginLng() {
        return originLng;
    }

    public String getGeohash() {
        return geohash;
    }

    public String getRegion() {
        return region;
    }

    public String getSi() {
        return si;
    }

    public String getGu() {
        return gu;
    }

    public int getSearchRadiusM() {
        return searchRadiusM;
    }

    public String getSymptomMemo() {
        return symptomMemo;
    }

    public LocalDateTime getRequestedAt() {
        return requestedAt;
    }

    public LocalDateTime getExpireAt() {
        return expireAt;
    }

    public String getAssignedVetUuid() {
        return assignedVetUuid;
    }

    public String getAssignedHospitalUuid() {
        return assignedHospitalUuid;
    }

    public LocalDateTime getAssignedAt() {
        return assignedAt;
    }
}
