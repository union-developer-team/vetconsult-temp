package com.louiekury.matching.global.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI matchingOpenApi() {
        return new OpenAPI()
            .info(new Info()
                .title("SHG Matching Service")
                .description("매칭 서비스 API. Gateway Swagger(Eureka 등록 목록)에서 선택해 호출할 수 있다.")
                .version("v1"));
    }
}
