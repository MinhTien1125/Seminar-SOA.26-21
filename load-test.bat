@echo off
echo ==========================================================
echo  BO BAN TAI CHO PROMETHEUS ^& GRAFANA DEMO (WINDOWS)
echo ==========================================================
echo Chon kich ban muon kich hoat:
echo   [1] Tai binh thuong (200 OK)
echo   [2] BAO TAI FLASH SALE (Ban lien tuc khong delay)
echo   [3] NGHEN MANG ^& CHAM API (Ban vao /simulate-slow)
echo   [4] SU CO LOI 500 (Ban vao /simulate-error)
echo ==========================================================
set /p choice="Nhap lua chon (1, 2, 3 hoac 4): "

if "%choice%"=="1" goto normal
if "%choice%"=="2" goto spike
if "%choice%"=="3" goto slow
if "%choice%"=="4" goto error

:normal
echo [1] Dang chay tai binh thuong... (Nhan Ctrl+C de dung)
:loop_normal
curl -s "http://localhost:8080/api/orders" > nul
goto loop_normal

:spike
echo [2] DANG BAN BAO TAI FLASH SALE! (Nhan Ctrl+C de dung)
echo Mo Grafana xem bieu do Throughput (RPS) nhay vot len!
:loop_spike
curl -s -X POST "http://localhost:8080/api/orders" -H "Content-Type: application/json" -d "{"item":"FlashSale"}" > nul
curl -s "http://localhost:8080/api/orders" > nul
goto loop_spike

:slow
echo [3] DANG KICH HOAT NGHEN MANG (P99 Latency cao)! (Nhan Ctrl+C de dung)
:loop_slow
curl -s "http://localhost:8080/api/orders/simulate-slow" > nul
goto loop_slow

:error
echo [4] DANG BAN LOI 500 LIEN TUC (Bieu do se chuyen do)! (Nhan Ctrl+C de dung)
:loop_error
curl -s "http://localhost:8080/api/orders/simulate-error" > nul
goto loop_error
