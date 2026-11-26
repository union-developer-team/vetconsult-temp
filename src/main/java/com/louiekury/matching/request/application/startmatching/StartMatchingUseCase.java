package com.louiekury.matching.request.application.startmatching;

import com.louiekury.matching.request.application.model.ConsultationRequestResult;

public interface StartMatchingUseCase {

    ConsultationRequestResult startMatching(StartMatchingCommand command);
}
