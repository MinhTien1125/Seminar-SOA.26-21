@echo off
echo ==========================================================
echo  BO BAN TAI CHO PROMETHEUS ^& GRAFANA DEMO (WINDOWS)
echo ==========================================================
echo   [1] tai binh thuong (200 ok)
echo   [2] bao tai flash sale (ban lien tuc khong delay)
echo   [3] nghen mang ^& cham api (ban vao /simulate-slow)
echo   [4] su co loi 500 (ban vao /simulate-error)
echo ==========================================================
set /p choice="nhap lua chon (1, 2, 3 hoac 4): "

if "%choice%"=="1" goto normal
if "%choice%"=="2" goto spike
if "%choice%"=="3" goto slow
if "%choice%"=="4" goto error

:normal
echo [1] dang chay tai binh thuong... (nhan ctrl+c de dung)
:loop_normal
curl -s "http://localhost:8080/api/orders" > nul
goto loop_normal

:spike
echo [2] dang ban bao tai flash sale! (nhan ctrl+c de dung)
echo mo grafana xem bieu do throughput (rps) nhay vot len!
:loop_spike
curl -s -X POST "http://localhost:8080/api/orders" -H "Content-Type: application/json" -d "{\"item\":\"FlashSale\"}" > nul
curl -s "http://localhost:8080/api/orders" > nul
goto loop_spike

:slow
echo [3] dang kich hoat nghen mang (p99 latency cao)! (nhan ctrl+c de dung)
:loop_slow
curl -s "http://localhost:8080/api/orders/simulate-slow" > nul
goto loop_slow

:error
echo [4] dang ban loi 500 lien tuc (bieu do se chuyen do)! (nhan ctrl+c de dung)
:loop_error
curl -s "http://localhost:8080/api/orders/simulate-error" > nul
goto loop_error
