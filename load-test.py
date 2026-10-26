import sys
import os
import time
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor

print("  [1] Tai binh thuong (1 luong, ~20-25 req/s)")
print("  [2] Bao tai flash sale (Da luong 20 threads, > 150-300 req/s)")
print("  [3] Nghen mang & cham API (Ban vao /simulate-slow)")
print("  [4] Su co loi 500 (Ban loi 500 lien tuc)")

choice = input("Nhap lua chon (1, 2, 3 hoac 4): ").strip()
base_url = "http://localhost:8080/api/orders"

def call_endpoint(url):
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'LoadBot/1.0'})
        with urllib.request.urlopen(req, timeout=5) as response:
            return response.status
    except Exception:
        return 0

try:
    if choice == "2":
        print("\n[2] Dang ban bao tai flash sale da luong (> 150 req/s)...")
        print("Mo Grafana quan sat Throughput vot len dinh! Nhan Ctrl+C de dung.")
        with ThreadPoolExecutor(max_workers=20) as executor:
            while True:
                futures = [executor.submit(call_endpoint, base_url) for _ in range(25)]
                for f in futures:
                    f.result()
    elif choice == "3":
        print("\n[3] Dang mo phong nghen mang (P99 Latency > 1500ms)...")
        print("Mo Grafana quan sat P99 Latency chuyen sang mau do! Nhan Ctrl+C de dung.")
        with ThreadPoolExecutor(max_workers=10) as executor:
            while True:
                futures = [executor.submit(call_endpoint, base_url + "/simulate-slow") for _ in range(10)]
                for f in futures:
                    f.result()
    elif choice == "4":
        print("\n[4] Dang ban loi 500 lien tuc... Nhan Ctrl+C de dung.")
        while True:
            call_endpoint(base_url + "/simulate-error")
            time.sleep(0.02)
    else:
        print("\n[1] Dang chay tai binh thuong (~20-25 req/s)... Nhan Ctrl+C de dung.")
        while True:
            call_endpoint(base_url)
            time.sleep(0.04)

except KeyboardInterrupt:
    os._exit(0)