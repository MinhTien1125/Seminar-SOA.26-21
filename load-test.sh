#!/bin/bash
echo "=========================================================="
echo "  BỘ BẮN TẢI CHO PROMETHEUS & GRAFANA DEMO"
echo "=========================================================="
echo "  [1] tải bình thường (20-30 req/s, 200 ok)"
echo "  [2] bão tải flash sale (bắn song song nhiều luồng > 150 req/s)"
echo "  [3] nghẽn mạng & chậm api (bắn vào /simulate-slow)"
echo "  [4] sự cố lỗi 500 (bắn vào /simulate-error)"
echo "----------------------------------------------------------"
read -p "nhập lựa chọn (1, 2, 3, hoặc 4): " choice

case $choice in
  1)
    echo " bắt đầu: tải bình thường (ctrl+c để dừng)..."
    while true; do
      curl -s "http://localhost:8080/api/orders" > /dev/null
      echo -ne "get /api/orders (200 ok)\r"
      sleep 0.05
    done
    ;;
  2)
    echo " bắt đầu: bão tải flash sale (chạy nền song song)..."
    for j in {1..15}; do
      (
        while true; do
          curl -s -X POST "http://localhost:8080/api/orders" -H "Content-Type: application/json" -d '{"item":"iPhone 16"}' > /dev/null
          curl -s "http://localhost:8080/api/orders" > /dev/null
        done
      ) &
    done
    echo " đang bắn tải nặng (> 150 rps)! mở grafana xem đồ thị throughput đang vọt lên đỉnh!"
    echo "nhấn ctrl+c rồi chạy 'killall curl 2>/dev/null' để dừng."
    wait
    ;;
  3)
    echo " bắt đầu: nghẽn mạng (độ trễ cao 1.5s)..."
    for j in {1..8}; do
      (
        while true; do
          curl -s "http://localhost:8080/api/orders/simulate-slow" > /dev/null
        done
      ) &
    done
    echo " đang kích hoạt độ trễ cao! mở grafana xem đồ thị p99 latency đang vọt lên > 1500ms!"
    wait
    ;;
  4)
    echo " bắt đầu: sự cố lỗi 500 (bắn lỗi liên tục)..."
    while true; do
      curl -s "http://localhost:8080/api/orders/simulate-error" > /dev/null
      echo -ne " bắn lỗi 500 vào /simulate-error\r"
      sleep 0.02
    done
    ;;
  *)
    echo "lựa chọn không hợp lệ. vui lòng chạy lại."
    ;;
esac
