package com.pethealthconsult.global.web.exception;

import com.pethealthconsult.global.web.response.ApiResponse;
import com.pethealthconsult.shared.exception.BusinessException;
import com.pethealthconsult.shared.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
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

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidation(MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult().getFieldErrors().stream()
            .findFirst()
            .map(error -> error.getField() + ": " + error.getDefaultMessage())
            .orElse(ErrorCode.VALIDATION_ERROR.getMessage());
        return ResponseEntity
            .status(errorCodeHttpMapper.statusOf(ErrorCode.VALIDATION_ERROR))
            .body(ApiResponse.error(ErrorCode.VALIDATION_ERROR.name(), message));
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiResponse<Void>> handleDataIntegrity(DataIntegrityViolationException ex) {
        return ResponseEntity
            .status(errorCodeHttpMapper.statusOf(ErrorCode.CONFLICT))
            .body(ApiResponse.error(
                ErrorCode.CONFLICT.name(),
                "데이터 제약 조건에 위배됩니다. 중복 생성을 확인하세요."
            ));
    }
}
