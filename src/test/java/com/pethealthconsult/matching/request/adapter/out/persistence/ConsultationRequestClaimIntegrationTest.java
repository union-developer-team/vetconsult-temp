package com.pethealthconsult.matching.request.adapter.out.persistence;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

@DataJpaTest
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:matching_claim;MODE=MySQL;DB_CLOSE_DELAY=-1;DATABASE_TO_LOWER=TRUE",
    "spring.datasource.username=sa",
    "spring.datasource.password=",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "spring.jpa.properties.hibernate.jdbc.time_zone=Asia/Seoul"
})
class ConsultationRequestClaimIntegrationTest {

    @Autowired
    private ConsultationRequestJpaRepository consultationRequestJpaRepository;

    @Autowired
    private PlatformTransactionManager transactionManager;

    @Test
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    @DisplayName("같은 UUID를 동시에 선점하면 정확히 한 트랜잭션만 성공한다")
    void onlyOneConcurrentClaimSucceeds() throws Exception {
        String uuid = "rq000000-0000-4000-8000-00000000conc";
        LocalDateTime now = LocalDateTime.now();
        TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);

        transactionTemplate.executeWithoutResult(status ->
            consultationRequestJpaRepository.saveAndFlush(
                ConsultationRequestJpaEntity.newRequested(uuid, now, now.plusMinutes(10))
            )
        );

        CountDownLatch ready = new CountDownLatch(2);
        CountDownLatch start = new CountDownLatch(1);
        AtomicInteger successCount = new AtomicInteger();

        ExecutorService executor = Executors.newFixedThreadPool(2);
        try {
            List<Future<?>> futures = new ArrayList<>();
            for (int i = 0; i < 2; i++) {
                futures.add(executor.submit(() -> {
                    ready.countDown();
                    start.await(5, TimeUnit.SECONDS);
                    Integer updated = transactionTemplate.execute(status ->
                        consultationRequestJpaRepository.claimMatchingFromRequested(uuid)
                    );
                    if (updated != null && updated == 1) {
                        successCount.incrementAndGet();
                    }
                    return null;
                }));
            }

            assertTrue(ready.await(5, TimeUnit.SECONDS));
            start.countDown();
            for (Future<?> future : futures) {
                future.get(10, TimeUnit.SECONDS);
            }
        } finally {
            executor.shutdownNow();
        }

        assertEquals(1, successCount.get());
        String status = transactionTemplate.execute(tx ->
            consultationRequestJpaRepository.findByUuid(uuid).orElseThrow().getStatus()
        );
        assertEquals("MATCHING", status);
    }
}
