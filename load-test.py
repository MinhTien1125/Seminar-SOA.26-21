import time
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor

print("==========================================================")
print(" PYTHON MULTI-THREADED LOAD GENERATOR (PROMETHEUS DEMO)")
print("==========================================================")
print("  [1] Tai binh thuong (1 luong, ~20-25 req/s)")
print("  [2] Bao tai flash sale (Da luong 20 threads, > 150-300 req/s)")
print("  [3] Nghen mang & cham API (Ban vao /simulate-slow)")
print("  [4] Su co loi 500 (Ban loi 500 lien tuc)")
print("----------------------------------------------------------")

choice = input("Nhap so (1, 2, 3, hoac 4): ").strip()
base_url = "http://localhost:8080/api/orders"

def call_endpoint(url):
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'LoadBot/1.0'})
        with urllib.request.urlopen(req, timeout=5) as response:
            return response.status
    except urllib.error.HTTPError as e:
        return e.code
    except Exception:
        return 0

if choice == "2":
    print("\n[SPIKE] Dang ban bao tai da luong (20 threads)... Mo Grafana xem do thi RPS vot len dinh!")
    print("Nhan Ctrl+C de dung lai.")
    with ThreadPoolExecutor(max_workers=20) as executor:
        while True:
            futures = [executor.submit(call_endpoint, base_url) for _ in range(25)]
            for f in futures:
                f.result()
            print("[SPIKE] Da ban them 25 requests...", end="\r")

elif choice == "3":
    print("\n[SLOW] Dang kich hoat nghen mang (/simulate-slow)... Mo Grafana xem P99 Latency vot len > 1500ms!")
    print("Nhan Ctrl+C de dung lai.")
    with ThreadPoolExecutor(max_workers=10) as executor:
        while True:
            futures = [executor.submit(call_endpoint, base_url + "/simulate-slow") for _ in range(10)]
            for f in futures:
                f.result()
            print("[SLOW] Dang gui request co do tre 1.5s...", end="\r")

elif choice == "4":
    print("\n[ERROR] Dang ban loi 500 (/simulate-error)... Mo Grafana xem error rate chuyen sang mau do!")
    print("Nhan Ctrl+C de dung lai.")
    while True:
        call_endpoint(base_url + "/simulate-error")
        print("[ERROR 500] Ban 1 request loi 500...", end="\r")
        time.sleep(0.02)

else:
    print("\n[NORMAL] Dang chay tai binh thuong (200 OK)... Nhan Ctrl+C de dung.")
    count = 0
    while True:
        count += 1
        call_endpoint(base_url)
        print(f"[{count}] GET 200 OK", end="\r")
        time.sleep(0.04)
