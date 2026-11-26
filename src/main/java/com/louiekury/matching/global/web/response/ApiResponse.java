package com.louiekury.matching.global.web.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.Objects;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    private final String code;
    private final String message;
    private final T data;

    public static <T> ApiResponse<T> success(T data) {
        return ApiResponse.<T>builder()
            .data(Objects.requireNonNull(data, "data"))
            .build();
    }

    public static ApiResponse<Void> success() {
        return ApiResponse.<Void>builder().build();
    }

    public static ApiResponse<Void> error(String code, String message) {
        return ApiResponse.<Void>builder()
            .code(Objects.requireNonNull(code, "code"))
            .message(Objects.requireNonNull(message, "message"))
            .build();
    }
}
