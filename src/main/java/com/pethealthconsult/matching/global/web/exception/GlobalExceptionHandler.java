package com.pethealthconsult.matching.global.web.exception;

import com.pethealthconsult.matching.global.web.response.ApiResponse;
import com.pethealthconsult.matching.shared.exception.BusinessException;
import com.pethealthconsult.matching.shared.exception.ErrorCode;
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
