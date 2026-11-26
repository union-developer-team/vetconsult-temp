package com.pethealthconsult.matching.request.application.startmatching;

import com.pethealthconsult.matching.request.application.model.ConsultationRequestResult;

public interface StartMatchingUseCase {

    ConsultationRequestResult startMatching(StartMatchingCommand command);
}
