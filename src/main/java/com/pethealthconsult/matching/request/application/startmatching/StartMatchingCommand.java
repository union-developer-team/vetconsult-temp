package com.pethealthconsult.matching.request.application.startmatching;

import java.util.Objects;

public class StartMatchingCommand {

    private final String requestUuid;

    private StartMatchingCommand(String requestUuid) {
        this.requestUuid = Objects.requireNonNull(requestUuid, "requestUuid");
    }

    public static StartMatchingCommand of(String requestUuid) {
        return new StartMatchingCommand(requestUuid);
    }

    public String getRequestUuid() {
        return requestUuid;
    }
}
