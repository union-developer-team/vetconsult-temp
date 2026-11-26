package com.pethealthconsult.matching.wave.adapter.out.persistence;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

import com.pethealthconsult.matching.offer.adapter.out.persistence.MatchOfferJpaEntity;
import com.pethealthconsult.matching.offer.adapter.out.persistence.MatchOfferJpaRepository;
import com.pethealthconsult.matching.offer.adapter.out.persistence.MatchOfferPersistenceAdapter;
import com.pethealthconsult.matching.offer.domain.MatchOfferStatus;
import com.pethealthconsult.matching.request.adapter.out.persistence.ConsultationRequestJpaEntity;
import com.pethealthconsult.matching.request.adapter.out.persistence.ConsultationRequestJpaRepository;
import com.pethealthconsult.matching.request.adapter.out.persistence.MatchRequestLoadAdapter;
import com.pethealthconsult.matching.wave.application.createwaveoffers.CreateWaveOffersCommand;
import com.pethealthconsult.matching.wave.application.createwaveoffers.CreateWaveOffersService;
import com.pethealthconsult.matching.wave.application.createwaveoffers.OfferCandidate;
import com.pethealthconsult.matching.wave.application.model.CreateWaveOffersResult;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.TestPropertySource;

@DataJpaTest
@Import({
    CreateWaveOffersService.class,
    MatchWavePersistenceAdapter.class,
    MatchOfferPersistenceAdapter.class,
    MatchRequestLoadAdapter.class
})
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:matching_wave_offer;MODE=MySQL;DB_CLOSE_DELAY=-1;DATABASE_TO_LOWER=TRUE",
    "spring.datasource.username=sa",
    "spring.datasource.password=",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "spring.jpa.properties.hibernate.jdbc.time_zone=Asia/Seoul"
})
class CreateWaveOffersPersistenceIntegrationTest {

    @Autowired
    private CreateWaveOffersService createWaveOffersService;

    @Autowired
    private ConsultationRequestJpaRepository consultationRequestJpaRepository;

    @Autowired
    private MatchWaveJpaRepository matchWaveJpaRepository;

    @Autowired
    private MatchOfferJpaRepository matchOfferJpaRepository;

    @Test
    @DisplayName("MATCHING 요청에 wave와 OFFERED offer가 DB에 저장된다")
    void persistsWaveAndOffers() {
        String requestUuid = "rq000000-0000-4000-8000-0000000wave";
        LocalDateTime now = LocalDateTime.now();
        consultationRequestJpaRepository.saveAndFlush(
            ConsultationRequestJpaEntity.newRequested(requestUuid, now, now.plusMinutes(10))
        );
        assertEquals(1, consultationRequestJpaRepository.claimMatchingFromRequested(requestUuid));

        CreateWaveOffersResult result = createWaveOffersService.createWaveOffers(
            CreateWaveOffersCommand.of(
                requestUuid,
                1,
                3000,
                List.of(
                    OfferCandidate.of(
                        "v1000000-0000-4000-8000-000000000001",
                        "h1000000-0000-4000-8000-000000000001",
                        480,
                        new BigDecimal("90.00")
                    )
                )
            )
        );

        assertEquals(1, result.getWaveNo());
        assertEquals(1, result.getOfferUuids().size());
        assertEquals(1, matchWaveJpaRepository.count());
        assertEquals(1, matchOfferJpaRepository.count());

        MatchWaveJpaEntity wave = matchWaveJpaRepository.findAll().get(0);
        assertEquals(1, wave.getWaveNo());
        assertEquals(3000, wave.getRadiusM());

        MatchOfferJpaEntity offer = matchOfferJpaRepository.findAll().get(0);
        assertEquals(wave.getId(), offer.getWaveId());
        assertEquals(MatchOfferStatus.OFFERED.name(), offer.getStatus());
        assertEquals("v1000000-0000-4000-8000-000000000001", offer.getVetUuid());
        assertFalse(offer.getRespondBy().isBefore(offer.getOfferedAt()));
    }
}
