FROM eclipse-temurin:17-jre AS builder
WORKDIR /extracted

COPY build/libs/*.jar app.jar
RUN java -Djarmode=tools -jar app.jar extract --layers --destination /extracted/layers

FROM eclipse-temurin:17-jre
WORKDIR /application

COPY --from=builder /extracted/layers/dependencies/ ./
COPY --from=builder /extracted/layers/spring-boot-loader/ ./
COPY --from=builder /extracted/layers/snapshot-dependencies/ ./
COPY --from=builder /extracted/layers/application/ ./

ENTRYPOINT ["java", "-jar", "app.jar"]
