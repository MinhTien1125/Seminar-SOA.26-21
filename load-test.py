import time
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor

print("==========================================================")
print(" PYTHON MULTI-THREADED LOAD GENERATOR (PROMETHEUS DEMO)")
print("==========================================================")
print("  [1] tải bình thường (1 luồng, ~20 req/s)")
print("  [2] bão tải flash sale (đa luồng 20 threads, > 150-300 req/s)")
print("  [3] nghẽn mạng & chậm api (bắn vào /simulate-slow)")
print("  [4] sự cố lỗi 500 (bắn lỗi 500 liên tục)")
print("----------------------------------------------------------")

choice = input("nhập số (1, 2, 3, hoặc 4): ").strip()
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
    print("\n đang bắn bão tải đa luồng (20 threads)... mở grafana xem đồ thị rps vọt lên đỉnh!")
    print("nhấn ctrl+c để dừng lại.")
    with ThreadPoolExecutor(max_workers=20) as executor:
        while True:
            futures = [executor.submit(call_endpoint, base_url) for _ in range(25)]
            for f in futures:
                f.result()
            print(" đã bắn thêm 25 requests...", end="\r")

elif choice == "3":
    print("\n đang kích hoạt nghẽn mạng (/simulate-slow)... mở grafana xem p99 latency vọt lên > 1500ms")
    print("nhấn ctrl+c để dừng lại.")
    with ThreadPoolExecutor(max_workers=10) as executor:
        while True:
            futures = [executor.submit(call_endpoint, base_url + "/simulate-slow") for _ in range(10)]
            for f in futures:
                f.result()
            print(" đang gửi request có độ trễ 1.5s...", end="\r")

elif choice == "4":
    print("\n đang bắn lỗi 500 (/simulate-error)... mở grafana xem error rate chuyển sang màu đỏ")
    print("nhấn ctrl+c để dừng lại.")
    while True:
        call_endpoint(base_url + "/simulate-error")
        print(" bắn 1 request lỗi 500...", end="\r")
        time.sleep(0.02)

else:
    print("\n đang chạy tải bình thường (200 ok)... nhấn ctrl+c để dừng.")
    count = 0
    while True:
        count += 1
        call_endpoint(base_url)
        print(f"[{count}] get 200 ok", end="\r")
        time.sleep(0.04)
