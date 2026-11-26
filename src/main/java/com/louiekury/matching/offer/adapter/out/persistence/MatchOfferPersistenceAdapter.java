package com.louiekury.matching.offer.adapter.out.persistence;

import com.louiekury.matching.offer.domain.MatchOffer;
import com.louiekury.matching.wave.application.port.out.SaveMatchOffersPort;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class MatchOfferPersistenceAdapter implements SaveMatchOffersPort {

    private final MatchOfferJpaRepository matchOfferJpaRepository;

    @Override
    public List<MatchOffer> saveAll(List<MatchOffer> offers) {
        List<MatchOfferJpaEntity> entities = offers.stream()
            .map(MatchOfferPersistenceMapper::toNewEntity)
            .toList();
        return matchOfferJpaRepository.saveAll(entities).stream()
            .map(MatchOfferPersistenceMapper::toDomain)
            .toList();
    }
}
