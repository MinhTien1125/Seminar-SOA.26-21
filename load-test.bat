@echo off
echo ==========================================================
echo  BO BAN TAI CHO PROMETHEUS ^& GRAFANA DEMO (WINDOWS)
echo ==========================================================
echo   [1] Tai binh thuong (1 luong on dinh ~20-30 req/s)
echo   [2] Bao tai flash sale (Da luong song song > 150 req/s)
echo   [3] Nghen mang ^& cham API (Ban vao /simulate-slow)
echo   [4] Su co loi 500 (Ban vao /simulate-error)
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
powershell -nop -c "Start-Sleep -Milliseconds 40" 2>nul
goto loop_normal

:spike
echo [2] Dang ban bao tai flash sale da luong (Kich hoat 10 tien trinh chay song song)!
echo Mo Grafana xem bieu do Throughput (RPS) nhay vot len dinh (> 150 req/s)!
echo Nhan Ctrl+C de thoat, sau do go: taskkill /F /IM curl.exe 2>nul
for /L %%i in (1,1,10) do (
  start /B cmd /c "for /L %%x in (1,0,2) do @curl -s http://localhost:8080/api/orders > nul"
)
:loop_spike_keep
curl -s "http://localhost:8080/api/orders" > nul
goto loop_spike_keep

:slow
echo [3] Dang kich hoat nghen mang (P99 Latency cao)! (Nhan Ctrl+C de dung)
for /L %%i in (1,1,6) do (
  start /B cmd /c "for /L %%x in (1,0,2) do @curl -s http://localhost:8080/api/orders/simulate-slow > nul"
)
:loop_slow
curl -s "http://localhost:8080/api/orders/simulate-slow" > nul
goto loop_slow

:error
echo [4] Dang ban loi 500 lien tuc (Bieu do se chuyen do)! (Nhan Ctrl+C de dung)
:loop_error
curl -s "http://localhost:8080/api/orders/simulate-error" > nul
powershell -nop -c "Start-Sleep -Milliseconds 20" 2>nul
goto loop_error
