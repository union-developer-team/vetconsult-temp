package com.pethealthconsult.matching.wave.application.createwaveoffers;

import com.pethealthconsult.matching.offer.domain.MatchOffer;
import com.pethealthconsult.matching.shared.exception.BusinessException;
import com.pethealthconsult.matching.shared.exception.ErrorCode;
import com.pethealthconsult.matching.wave.application.model.CreateWaveOffersResult;
import com.pethealthconsult.matching.wave.application.model.MatchRequestSnapshot;
import com.pethealthconsult.matching.wave.application.port.out.LoadMatchRequestPort;
import com.pethealthconsult.matching.wave.application.port.out.SaveMatchOffersPort;
import com.pethealthconsult.matching.wave.application.port.out.SaveMatchWavePort;
import com.pethealthconsult.matching.wave.domain.MatchWave;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 1차(또는 N차) wave를 열고 후보마다 OFFERED offer를 저장한다.
 * Mongo 위치 조회·Kafka는 후속. 후보는 Command로 전달받는다.
 */
@Service
@RequiredArgsConstructor
public class CreateWaveOffersService implements CreateWaveOffersUseCase {

    private static final String STATUS_MATCHING = "MATCHING";
    private static final int MAX_OFFERS_PER_WAVE = 5;
    private static final int OFFER_TTL_SECONDS = 20;

    private final LoadMatchRequestPort loadMatchRequestPort;
    private final SaveMatchWavePort saveMatchWavePort;
    private final SaveMatchOffersPort saveMatchOffersPort;

    @Override
    @Transactional
    public CreateWaveOffersResult createWaveOffers(CreateWaveOffersCommand command) {
        MatchRequestSnapshot request = loadMatchRequestPort.findByUuid(command.getRequestUuid())
            .orElseThrow(() -> new BusinessException(
                ErrorCode.NOT_FOUND,
                "호출 요청을 찾을 수 없습니다."
            ));

        if (!STATUS_MATCHING.equals(request.getStatus())) {
            throw new BusinessException(
                ErrorCode.VALIDATION_ERROR,
                "MATCHING 상태에서만 wave/offer를 생성할 수 있습니다. 현재: " + request.getStatus()
            );
        }

        List<OfferCandidate> candidates = command.getCandidates();
        if (candidates.isEmpty()) {
            throw new BusinessException(
                ErrorCode.VALIDATION_ERROR,
                "offer 후보가 없습니다."
            );
        }
        if (candidates.size() > MAX_OFFERS_PER_WAVE) {
            throw new BusinessException(
                ErrorCode.VALIDATION_ERROR,
                "차수당 offer는 최대 " + MAX_OFFERS_PER_WAVE + "건입니다."
            );
        }

        LocalDateTime now = LocalDateTime.now();
        MatchWave wave = saveMatchWavePort.save(
            MatchWave.create(
                UUID.randomUUID().toString(),
                request.getId(),
                command.getWaveNo(),
                command.getRadiusM(),
                now
            )
        );

        Long waveId = wave.getId();
        if (waveId == null) {
            throw new IllegalStateException("저장된 match_wave에 id가 없습니다.");
        }

        LocalDateTime respondBy = now.plusSeconds(OFFER_TTL_SECONDS);
        List<MatchOffer> offers = new ArrayList<>();
        for (OfferCandidate candidate : candidates) {
            offers.add(
                MatchOffer.create(
                    UUID.randomUUID().toString(),
                    request.getId(),
                    waveId,
                    candidate.getVetUuid(),
                    candidate.getHospitalUuid(),
                    candidate.getDistanceM(),
                    candidate.getScore(),
                    now,
                    respondBy
                )
            );
        }

        List<MatchOffer> saved = saveMatchOffersPort.saveAll(offers);
        List<String> offerUuids = saved.stream()
            .map(MatchOffer::getUuid)
            .toList();

        return CreateWaveOffersResult.of(
            wave.getUuid(),
            wave.getWaveNo(),
            wave.getRadiusM(),
            offerUuids
        );
    }
}
