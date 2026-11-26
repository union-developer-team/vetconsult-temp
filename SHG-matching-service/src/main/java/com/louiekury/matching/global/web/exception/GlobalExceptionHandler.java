package com.louiekury.matching.global.web.exception;

import com.louiekury.matching.global.web.response.ApiResponse;
import com.louiekury.matching.shared.exception.BusinessException;
import com.louiekury.matching.shared.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
@RequiredArgsConstructor
public class GlobalExceptionHandler {

    private final ErrorCodeHttpMapper errorCodeHttpMapper;

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<Void>> handleBusiness(BusinessException ex) {
        ErrorCode code = ex.getErrorCode();
        return ResponseEntity
            .status(errorCodeHttpMapper.statusOf(code))
            .body(ApiResponse.error(code.name(), ex.getMessage()));
    }
}
