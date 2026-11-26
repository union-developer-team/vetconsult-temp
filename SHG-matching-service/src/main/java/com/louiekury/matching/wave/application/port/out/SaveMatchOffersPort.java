package com.louiekury.matching.wave.application.port.out;

import com.louiekury.matching.offer.domain.MatchOffer;
import java.util.List;

public interface SaveMatchOffersPort {

    List<MatchOffer> saveAll(List<MatchOffer> offers);
}
