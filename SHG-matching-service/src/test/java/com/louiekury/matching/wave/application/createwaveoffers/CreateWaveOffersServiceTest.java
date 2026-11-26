package com.louiekury.matching.wave.application.createwaveoffers;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.louiekury.matching.offer.domain.MatchOffer;
import com.louiekury.matching.offer.domain.MatchOfferStatus;
import com.louiekury.matching.shared.exception.BusinessException;
import com.louiekury.matching.shared.exception.ErrorCode;
import com.louiekury.matching.wave.application.model.CreateWaveOffersResult;
import com.louiekury.matching.wave.application.model.MatchRequestSnapshot;
import com.louiekury.matching.wave.application.port.out.LoadMatchRequestPort;
import com.louiekury.matching.wave.application.port.out.SaveMatchOffersPort;
import com.louiekury.matching.wave.application.port.out.SaveMatchWavePort;
import com.louiekury.matching.wave.domain.MatchWave;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class CreateWaveOffersServiceTest {

    @Mock
    private LoadMatchRequestPort loadMatchRequestPort;

    @Mock
    private SaveMatchWavePort saveMatchWavePort;

    @Mock
    private SaveMatchOffersPort saveMatchOffersPort;

    @InjectMocks
    private CreateWaveOffersService createWaveOffersService;

    @Test
    @DisplayName("MATCHING 요청에 wave 1건과 OFFERED offer를 생성한다")
    void createsWaveAndOffersWhenMatching() {
        when(loadMatchRequestPort.findByUuid("rq-1"))
            .thenReturn(Optional.of(MatchRequestSnapshot.of(10L, "rq-1", "MATCHING")));

        when(saveMatchWavePort.save(any(MatchWave.class))).thenAnswer(invocation -> {
            MatchWave wave = invocation.getArgument(0);
            return MatchWave.restore(
                100L,
                wave.getUuid(),
                wave.getRequestId(),
                wave.getWaveNo(),
                wave.getRadiusM(),
                wave.getStartedAt(),
                wave.getFinishedAt()
            );
        });

        when(saveMatchOffersPort.saveAll(anyList())).thenAnswer(invocation -> {
            List<MatchOffer> offers = invocation.getArgument(0);
            return offers.stream()
                .map(offer -> MatchOffer.restore(
                    1L,
                    offer.getUuid(),
                    offer.getRequestId(),
                    offer.getWaveId(),
                    offer.getVetUuid(),
                    offer.getHospitalUuid(),
                    offer.getDistanceM(),
                    offer.getScore(),
                    offer.getStatus(),
                    offer.getOfferedAt(),
                    offer.getRespondBy(),
                    offer.getRespondedAt()
                ))
                .toList();
        });

        OfferCandidate candidate = OfferCandidate.of(
            "vet-1",
            "hosp-1",
            480,
            new BigDecimal("90.00")
        );
        CreateWaveOffersResult result = createWaveOffersService.createWaveOffers(
            CreateWaveOffersCommand.of("rq-1", 1, 3000, List.of(candidate))
        );

        assertEquals(1, result.getWaveNo());
        assertEquals(3000, result.getRadiusM());
        assertEquals(1, result.getOfferUuids().size());

        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<MatchOffer>> offersCaptor = ArgumentCaptor.forClass(List.class);
        verify(saveMatchOffersPort).saveAll(offersCaptor.capture());
        MatchOffer savedOffer = offersCaptor.getValue().get(0);
        assertEquals(100L, savedOffer.getWaveId());
        assertEquals(MatchOfferStatus.OFFERED, savedOffer.getStatus());
        assertEquals("vet-1", savedOffer.getVetUuid());
    }

    @Test
    @DisplayName("요청이 없으면 NOT_FOUND")
    void notFoundWhenMissing() {
        when(loadMatchRequestPort.findByUuid("missing")).thenReturn(Optional.empty());

        BusinessException ex = assertThrows(
            BusinessException.class,
            () -> createWaveOffersService.createWaveOffers(
                CreateWaveOffersCommand.of("missing", 1, 3000, List.of(
                    OfferCandidate.of("vet-1", "hosp-1", 100, new BigDecimal("1.00"))
                ))
            )
        );
        assertEquals(ErrorCode.NOT_FOUND, ex.getErrorCode());
        verifyNoInteractions(saveMatchWavePort, saveMatchOffersPort);
    }

    @Test
    @DisplayName("MATCHING이 아니면 VALIDATION_ERROR")
    void validationWhenNotMatching() {
        when(loadMatchRequestPort.findByUuid("rq-2"))
            .thenReturn(Optional.of(MatchRequestSnapshot.of(2L, "rq-2", "REQUESTED")));

        BusinessException ex = assertThrows(
            BusinessException.class,
            () -> createWaveOffersService.createWaveOffers(
                CreateWaveOffersCommand.of("rq-2", 1, 3000, List.of(
                    OfferCandidate.of("vet-1", "hosp-1", 100, new BigDecimal("1.00"))
                ))
            )
        );
        assertEquals(ErrorCode.VALIDATION_ERROR, ex.getErrorCode());
        verifyNoInteractions(saveMatchWavePort, saveMatchOffersPort);
    }
}
