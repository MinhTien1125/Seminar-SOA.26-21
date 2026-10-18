import time
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor

print("==========================================================")
print(" 🚀 PYTHON MULTI-THREADED LOAD GENERATOR (PROMETHEUS DEMO)")
print("==========================================================")
print("Chọn kịch bản bắn tải:")
print("  [1] Tải bình thường (1 luồng, ~20 req/s)")
print("  [2] BÃO TẢI FLASH SALE (Đa luồng 20 threads, > 150-300 req/s)")
print("  [3] NGHẼN MẠNG & CHẬM API (Chuyên bắn vào /simulate-slow để P99 vọt lên)")
print("  [4] SỰ CỐ LỖI 500 (Bắn lỗi 500 liên tục để Error Rate chuyển sang màu đỏ)")
print("----------------------------------------------------------")

choice = input("Nhập số (1, 2, 3, hoặc 4): ").strip()
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
    print("\n🔥 ĐANG BẮN BÃO TẢI ĐA LUỒNG (20 Threads)... Mở Grafana xem đồ thị RPS vọt lên đỉnh!")
    print("Nhấn Ctrl+C để dừng lại.")
    with ThreadPoolExecutor(max_workers=20) as executor:
        while True:
            futures = [executor.submit(call_endpoint, base_url) for _ in range(25)]
            for f in futures:
                f.result()
            print("⚡ Đã bắn thêm 25 requests...", end="\r")

elif choice == "3":
    print("\n⏱️ ĐANG KÍCH HOẠT NGHẼN MẠNG (/simulate-slow)... Mở Grafana xem P99 Latency vọt lên > 1500ms!")
    print("Nhấn Ctrl+C để dừng lại.")
    with ThreadPoolExecutor(max_workers=10) as executor:
        while True:
            futures = [executor.submit(call_endpoint, base_url + "/simulate-slow") for _ in range(10)]
            for f in futures:
                f.result()
            print("⏳ Đang gửi request có độ trễ 1.5s...", end="\r")

elif choice == "4":
    print("\n⚠️ ĐANG BẮN LỖI 500 (/simulate-error)... Mở Grafana xem Error Rate chuyển sang màu đỏ!")
    print("Nhấn Ctrl+C để dừng lại.")
    while True:
        call_endpoint(base_url + "/simulate-error")
        print("🚨 Bắn 1 request lỗi 500...", end="\r")
        time.sleep(0.02)

else:
    print("\n🟢 Đang chạy tải bình thường (200 OK)... Nhấn Ctrl+C để dừng.")
    count = 0
    while True:
        count += 1
        call_endpoint(base_url)
        print(f"[{count}] GET 200 OK", end="\r")
        time.sleep(0.04)
