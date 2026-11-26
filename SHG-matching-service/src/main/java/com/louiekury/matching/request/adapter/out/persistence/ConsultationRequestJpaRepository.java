package com.louiekury.matching.request.adapter.out.persistence;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ConsultationRequestJpaRepository extends JpaRepository<ConsultationRequestJpaEntity, Long> {

    Optional<ConsultationRequestJpaEntity> findByUuid(String uuid);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
        UPDATE ConsultationRequestJpaEntity e
           SET e.status = 'MATCHING'
         WHERE e.uuid = :uuid
           AND e.status = 'REQUESTED'
        """)
    int claimMatchingFromRequested(@Param("uuid") String uuid);
}
