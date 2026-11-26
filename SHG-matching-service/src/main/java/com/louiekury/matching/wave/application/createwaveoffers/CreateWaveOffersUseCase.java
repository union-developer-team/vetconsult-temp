package com.louiekury.matching.wave.application.createwaveoffers;

import com.louiekury.matching.wave.application.model.CreateWaveOffersResult;

public interface CreateWaveOffersUseCase {

    CreateWaveOffersResult createWaveOffers(CreateWaveOffersCommand command);
}
