package com.pethealthconsult.global.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI petHealthConsultOpenApi() {
        return new OpenAPI()
            .info(new Info()
                .title("Pet Health Consult API")
                .description("단일 모놀리식 백엔드 API (도메인 모듈: matching / clinic / care …)")
                .version("v1"));
    }
}
