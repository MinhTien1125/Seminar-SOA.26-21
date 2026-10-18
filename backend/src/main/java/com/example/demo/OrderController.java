package com.example.demo;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.concurrent.TimeUnit;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final Counter orderCreatedCounter;
    private final Counter orderFailedCounter;
    private final Timer orderProcessingTimer;

    public OrderController(MeterRegistry registry) {
        // Đăng ký custom business metrics vào Micrometer
        this.orderCreatedCounter = Counter.builder("business_orders_created_total")
                .description("Tong so don hang da duoc tao")
                .tag("status", "success")
                .register(registry);

        this.orderFailedCounter = Counter.builder("business_orders_created_total")
                .description("Tong so don hang bi that bai")
                .tag("status", "failed")
                .register(registry);

        this.orderProcessingTimer = Timer.builder("business_order_process_duration_seconds")
                .description("Thoi gian xu ly mot don hang")
                .publishPercentiles(0.5, 0.95, 0.99)
                .register(registry);
    }

    // 1. API Lay danh sach don hang (Tra ve 200 OK nhanh - ~15ms)
    @GetMapping
    public ResponseEntity<Map<String, Object>> getOrders() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "Danh sach don hang lay thanh cong");
        response.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(response);
    }

    // 2. API Tao don hang (Do thoi gian Timer va tang Counter)
    @PostMapping
    public ResponseEntity<Map<String, Object>> createOrder(@RequestBody(required = false) Map<String, Object> payload) {
        long startTime = System.currentTimeMillis();

        // Gia lap xu ly nghiep vu
        orderCreatedCounter.increment();
        long duration = System.currentTimeMillis() - startTime;
        orderProcessingTimer.record(duration, TimeUnit.MILLISECONDS);

        Map<String, Object> response = new HashMap<>();
        response.put("orderId", UUID.randomUUID().toString());
        response.put("status", "CREATED");
        return ResponseEntity.status(201).body(response);
    }

    // 3. API Co tinh cham de demo P99 Latency tang vot
    @GetMapping("/simulate-slow")
    public ResponseEntity<Map<String, Object>> simulateSlow() throws InterruptedException {
        // Delay 1.5 giay
        Thread.sleep(1500);
        Map<String, Object> response = new HashMap<>();
        response.put("message", "API da hoan thanh sau 1500ms");
        return ResponseEntity.ok(response);
    }

    // 4. API Co tinh nem loi 500 de demo Error Rate tren Grafana
    @GetMapping("/simulate-error")
    public ResponseEntity<Void> simulateError() {
        orderFailedCounter.increment();
        throw new RuntimeException("Simulated Server Internal Error for Prometheus Demo!");
    }
}
