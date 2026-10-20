# SEMINAR PROMETHEUS & GRAFANA (PRODUCTION READINESS)
Đề tài Seminar số 9-1: Metrics Collection, Dashboards & System Monitoring in Microservices.

---

## MỤC LỤC
1. [Yêu Cầu Chuẩn Bị (Prerequisites)](#1-yêu-cầu-chuẩn-bị)
2. [Khởi Động Hệ Thống Bằng Docker](#2-khởi-động-hệ-thống-1-click)
3. [Kiểm Tra Các Cổng Mạng Trên Trình Duyệt](#3-kiểm-tra-các-cổng-mạng)
4. [Hướng Dẫn Chi Tiết Demo](#4-hướng-dẫn-chi-tiết-demo)
5. [Dừng và Dọn Dẹp Hệ Thống](#6-dừng-và-dọn-dẹp-hệ-thống)

---


## 1. YÊU CẦU CHUẨN BỊ
- Máy tính có cài sẵn **Docker Desktop** (hoặc Docker Engine + Docker Compose).
- Kiểm tra bằng lệnh: `docker compose version` hoặc `docker --version`.

---

## 2. KHỞI ĐỘNG HỆ THỐNG 1-CLICK

### Bước 1: Mở Terminal tại thư mục này
```bash
cd prometheus-grafana-spring-boot-demo
```

### Bước 2: Chạy lệnh khởi động
```bash
docker compose up -d --build
```
*(Từ lần thứ 2 trở đi, chỉ cần gõ `docker compose up -d`, khởi động chỉ mất 2-3 giây!)*

### Bước 3: Kiểm tra trạng thái
```bash
docker compose ps
```
Cả 3 container `order-service`, `prometheus`, `grafana` đều báo trạng thái **Up**.

---

## 3. KIỂM TRA CÁC CỔNG MẠNG
- **Spring Boot Actuator:** http://localhost:8080/actuator/prometheus *(Xuất số liệu OpenMetrics)*
- **Prometheus Targets:** http://localhost:9090/targets *(Trạng thái order-service màu xanh lá UP)*
- **Grafana Dashboard:** http://localhost:3000
  - Tài khoản: `admin` / Mật khẩu: `admin`
  - Dashboard đã được tự nạp sẵn: **"Spring Boot Production Readiness Dashboard"**

---

## 4. HƯỚNG DẪN CHI TIẾT DEMO

Mở một cửa sổ Terminal mới và chạy script bắn tải:
- **Trên macOS / Linux / Git Bash:** `bash load-test.sh`
- **Trên Windows CMD:** `load-test.bat`
- **Hoặc chạy bằng Python:** `python load-test.py`

### 1: Hoạt động bình thường (Healthy Baseline)
- **Hành động:** Script gửi các request `GET /api/orders` (HTTP 200 OK).
- **Hiện tượng trên Grafana:**
  - Biểu đồ **Throughput (RPS)** giữ đều đặn ở mức 20-30 req/s.
  - Biểu đồ **P99 Latency** ở mức an toàn (~15-20 ms).
  - Biểu đồ **Error Rate** bằng **0%** (màu xanh lá cây).

### 2: Bão tải (Traffic Spike / Flash Sale)
- **Hành động:** Bắn dồn dập request `POST /api/orders` tạo đơn hàng liên tục.
- **Hiện tượng trên Grafana:**
  - Biểu đồ **RPS** nhảy vọt lên đỉnh (> 100 req/s).
  - Bộ nhớ **JVM Heap** tăng dần và số kết nối **HikariCP Database** tăng theo.

### 3: Nghẽn mạng & Chậm API (High Latency)
- **Hành động:** Bắn request vào endpoint `/api/orders/simulate-slow` (bị delay 1.5s).
- **Hiện tượng trên Grafana:**
  - Biểu đồ **P99 Response Time** lập tức vọt lên **> 1500 ms** (chuyển sang màu tím/vàng cảnh báo).
  - Giúp chứng minh hệ thống phát hiện chính xác tình trạng nghẽn cổ chai (bottleneck).

### 4: Sự cố sập Server (Lỗi HTTP 500)
- **Hành động:** Bắn request vào endpoint `/api/orders/simulate-error` (ném ra RuntimeException).
- **Hiện tượng trên Grafana:**
  - Biểu đồ **HTTP 5xx Error Rate** vọt lên **> 10%** và **chuyển sang màu đỏ rực**.
  - Kích hoạt quy tắc cảnh báo (Alertmanager) gửi tin nhắn khẩn cấp cho đội ngũ vận hành.

---

## 5. DỪNG VÀ DỌN DẸP HỆ THỐNG

### 5.1. Lỗi xung đột tên container (`Conflict: container name "/order-service" is already in use`)
* **Nguyên nhân:** Có container cũ từ lần chạy trước chưa được xóa sạch.
* **Cách xử lý triệt để:**
  ```bash
  docker rm -f order-service prometheus grafana
  docker compose up -d
  ```

### 5.2. Lỗi trùng cổng mạng (`Port is already allocated: 8080 or 3000`)
* **Nguyên nhân:** Máy tính của bạn đang mở sẵn ứng dụng khác (như Tomcat, Oracle DB, hoặc Grafana cài rời).
* **Cách xử lý:** Mở file `docker-compose.yml`, đổi cổng bên ngoài thành `"8081:8080"` hoặc `"3001:3000"`.

### 5.3. Lệnh dừng và dọn dẹp hệ thống sau khi báo cáo xong
Khi kết thúc buổi thuyết trình, giải phóng hoàn toàn bộ nhớ RAM và CPU bằng lệnh:
```bash
docker compose down
```
*(Nếu muốn xóa sạch cả dữ liệu bộ nhớ đệm ổ cứng: `docker compose down -v`)*.


## Cấu trúc thư mục

```text

prometheus-grafana-spring-boot-demo/
│
├── docker-compose.yml                     # File chính: Khởi chạy 3 container (Spring Boot, Prometheus, Grafana)
├── load-test.sh                           # Script bắn tải có menu 4 kịch bản (Linux / macOS / Git Bash)
├── load-test.bat                          # Script bắn tải có menu 4 kịch bản (Windows Command Prompt)
├── load-test.py                           # Script bắn tải đa luồng 20 threads (Python - chạy mọi hệ điều hành)
├── README.md                              # Tài liệu hướng dẫn toàn diện từ A-Z
│
├── prometheus/                            # Cấu hình máy chủ Prometheus
│   └── prometheus.yml                     # Khai báo job scrape định kỳ kéo metric từ Spring Boot (/actuator/prometheus)
│
├── grafana/                               # Cấu hình tự động nạp (Provisioning) cho Grafana
│   ├── dashboards/
│   │   └── spring-boot-dashboard.json     # File JSON định nghĩa 4 panel biểu đồ (Throughput, P99 Latency, Error Rate, JVM Heap)
│   └── provisioning/
│       ├── datasources/
│       │   └── datasource.yml             # Tự động kết nối Grafana với Prometheus (không cần bấm tay)
│       └── dashboards/
│           └── dashboards.yml             # Tự động nạp thư mục dashboards khi container khởi động
│
└── backend/                               # Mã nguồn ứng dụng Spring Boot Microservice
    ├── pom.xml                            # Khai báo thư viện: spring-boot-starter-web, actuator, micrometer-registry-prometheus
    ├── Dockerfile                         # Multi-stage build container Java 17 siêu nhẹ (Eclipse Temurin JRE)
    └── src/
        └── main/
            ├── java/com/example/demo/
            │   ├── DemoApplication.java    # File chạy chính của Spring Boot (@SpringBootApplication)
            │   └── OrderController.java   # REST Controller: API /api/orders, /simulate-slow (1.5s), /simulate-error (500)
            └── resources/
                └── application.yml        # Cấu hình Actuator expose /actuator/prometheus & percentiles-histogram
```
