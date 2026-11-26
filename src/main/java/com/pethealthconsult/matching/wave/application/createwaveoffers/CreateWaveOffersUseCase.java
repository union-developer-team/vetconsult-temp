package com.pethealthconsult.matching.wave.application.createwaveoffers;

import com.pethealthconsult.matching.wave.application.model.CreateWaveOffersResult;

public interface CreateWaveOffersUseCase {

    CreateWaveOffersResult createWaveOffers(CreateWaveOffersCommand command);
}
