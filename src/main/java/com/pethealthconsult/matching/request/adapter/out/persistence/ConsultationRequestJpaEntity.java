package com.pethealthconsult.matching.request.adapter.out.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "consultation_request")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ConsultationRequestJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "uuid", nullable = false, length = 36)
    private String uuid;

    @Column(name = "caregiver_uuid", nullable = false, length = 36)
    private String caregiverUuid;

    @Column(name = "pet_uuid", nullable = false, length = 36)
    private String petUuid;

    @Column(name = "medical_subject_uuid", nullable = false, length = 36)
    private String medicalSubjectUuid;

    @Column(name = "channel", nullable = false, length = 20)
    private String channel;

    @Column(name = "is_emergency", nullable = false)
    private boolean emergency;

    @Column(name = "status", nullable = false, length = 20)
    private String status;

    @Column(name = "origin_lat", nullable = false, precision = 9, scale = 6)
    private BigDecimal originLat;

    @Column(name = "origin_lng", nullable = false, precision = 9, scale = 6)
    private BigDecimal originLng;

    @Column(name = "geohash", nullable = false, length = 12)
    private String geohash;

    @Column(name = "region", nullable = false, length = 50)
    private String region;

    @Column(name = "si", nullable = false, length = 50)
    private String si;

    @Column(name = "gu", nullable = false, length = 50)
    private String gu;

    @Column(name = "search_radius_m", nullable = false)
    private int searchRadiusM;

    @Column(name = "symptom_memo", length = 200)
    private String symptomMemo;

    @Column(name = "requested_at", nullable = false)
    private LocalDateTime requestedAt;

    @Column(name = "expire_at", nullable = false)
    private LocalDateTime expireAt;

    @Column(name = "assigned_vet_uuid", length = 36)
    private String assignedVetUuid;

    @Column(name = "assigned_hospital_uuid", length = 36)
    private String assignedHospitalUuid;

    @Column(name = "assigned_at")
    private LocalDateTime assignedAt;

    void applyStatus(String status) {
        this.status = status;
    }

    public static ConsultationRequestJpaEntity newRequested(
        String uuid,
        LocalDateTime requestedAt,
        LocalDateTime expireAt
    ) {
        ConsultationRequestJpaEntity entity = new ConsultationRequestJpaEntity();
        entity.uuid = uuid;
        entity.caregiverUuid = "a1000000-0000-4000-8000-000000000001";
        entity.petUuid = "p1000000-0000-4000-8000-000000000001";
        entity.medicalSubjectUuid = "ms000000-0000-4000-8000-000000000001";
        entity.channel = "CHAT";
        entity.emergency = false;
        entity.status = "REQUESTED";
        entity.originLat = new BigDecimal("37.497900");
        entity.originLng = new BigDecimal("127.028100");
        entity.geohash = "wydm9";
        entity.region = "서울";
        entity.si = "서울특별시";
        entity.gu = "강남구";
        entity.searchRadiusM = 3000;
        entity.symptomMemo = "동시 선점 테스트";
        entity.requestedAt = requestedAt;
        entity.expireAt = expireAt;
        return entity;
    }
}
