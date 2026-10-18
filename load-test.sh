#!/bin/bash
echo "=========================================================="
echo " 🚀 BỘ BẮN TẢI CHUYÊN NGHIỆP CHO PROMETHEUS & GRAFANA DEMO"
echo "=========================================================="
echo "Chọn kịch bản bạn muốn kích hoạt:"
echo "  [1] Tải bình thường (20-30 req/s, 200 OK)"
echo "  [2] BÃO TẢI FLASH SALE (Bắn song song nhiều luồng > 150 req/s)"
echo "  [3] NGHẼN MẠNG & CHẬM API (Chuyên bắn vào /simulate-slow để P99 Latency tăng vọt)"
echo "  [4] SỰ CỐ LỖI 500 (Bắn lỗi liên tục để Error Rate chuyển màu đỏ)"
echo "----------------------------------------------------------"
read -p "Nhập lựa chọn (1, 2, 3, hoặc 4): " choice

case $choice in
  1)
    echo "🟢 Bắt đầu Kịch Bản 1: Tải bình thường (Ctrl+C để dừng)..."
    while true; do
      curl -s "http://localhost:8080/api/orders" > /dev/null
      echo -ne "GET /api/orders (200 OK)\r"
      sleep 0.05
    done
    ;;
  2)
    echo "🟡 Bắt đầu Kịch Bản 2: BÃO TẢI FLASH SALE (Chạy nền song song 15 tiến trình)..."
    for j in {1..15}; do
      (
        while true; do
          curl -s -X POST "http://localhost:8080/api/orders" -H "Content-Type: application/json" -d '{"item":"iPhone 16"}' > /dev/null
          curl -s "http://localhost:8080/api/orders" > /dev/null
        done
      ) &
    done
    echo "⚡ Đang bắn tải nặng (> 150 RPS)! Nhìn Grafana đồ thị Throughput đang vọt lên đỉnh!"
    echo "Nhấn Ctrl+C rồi chạy 'killall curl 2>/dev/null' để dừng."
    wait
    ;;
  3)
    echo "🟣 Bắt đầu Kịch Bản 3: NGHẼN MẠNG (Độ trễ cao 1.5s)..."
    for j in {1..8}; do
      (
        while true; do
          curl -s "http://localhost:8080/api/orders/simulate-slow" > /dev/null
        done
      ) &
    done
    echo "⏱️ Đang kích hoạt độ trễ cao! Nhìn Grafana đồ thị P99 Latency đang vọt lên > 1500ms!"
    wait
    ;;
  4)
    echo "🔴 Bắt đầu Kịch Bản 4: BẮN LỖI 500 (Alerting)..."
    while true; do
      curl -s "http://localhost:8080/api/orders/simulate-error" > /dev/null
      echo -ne "⚠️ Bắn lỗi 500 vào /simulate-error\r"
      sleep 0.02
    done
    ;;
  *)
    echo "Lựa chọn không hợp lệ. Vui lòng chạy lại."
    ;;
esac
