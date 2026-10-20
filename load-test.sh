#!/bin/bash
echo "=========================================================="
echo " BO BAN TAI CHO PROMETHEUS & GRAFANA DEMO"
echo "=========================================================="
echo "  [1] Tai binh thuong (20-30 req/s, 200 OK)"
echo "  [2] Bao tai flash sale (Ban song song da luong > 150 req/s)"
echo "  [3] Nghen mang & cham API (Ban vao /simulate-slow)"
echo "  [4] Su co loi 500 (Ban vao /simulate-error)"
echo "----------------------------------------------------------"
read -p "Nhap lua chon (1, 2, 3, hoac 4): " choice

case $choice in
  1)
    echo "[1] Bat dau: Tai binh thuong (Nhan Ctrl+C de dung)..."
    while true; do
      curl -s "http://localhost:8080/api/orders" > /dev/null
      echo -ne "[OK] GET /api/orders (200 OK)\r"
      sleep 0.05
    done
    ;;
  2)
    echo "[2] Bat dau: Bao tai flash sale (Chay nen da luong)..."
    for j in {1..15}; do
      (
        while true; do
          curl -s -X POST "http://localhost:8080/api/orders" -H "Content-Type: application/json" -d '{"item":"iPhone 16"}' > /dev/null
          curl -s "http://localhost:8080/api/orders" > /dev/null
        done
      ) &
    done
    echo "[SPIKE] Dang ban tai nang (> 150 rps)! Mo Grafana xem do thi Throughput tang vot!"
    echo "Nhan Ctrl+C roi chay 'killall curl 2>/dev/null' de dung."
    wait
    ;;
  3)
    echo "[3] Bat dau: Nghen mang (Do tre cao 1.5s)..."
    for j in {1..8}; do
      (
        while true; do
          curl -s "http://localhost:8080/api/orders/simulate-slow" > /dev/null
        done
      ) &
    done
    echo "[SLOW] Dang kich hoat do tre cao! Mo Grafana xem do thi P99 Latency tang vot > 1500ms!"
    wait
    ;;
  4)
    echo "[4] Bat dau: Su co loi 500 (Ban loi lien tuc)..."
    while true; do
      curl -s "http://localhost:8080/api/orders/simulate-error" > /dev/null
      echo -ne "[ERROR 500] Ban vao /simulate-error\r"
      sleep 0.02
    done
    ;;
  *)
    echo "Lua chon khong hop le. Vui long chay lai."
    ;;
esac
