@echo off
REM Pattern Detector UVM Testbench Run Script for Windows
REM Usage: run_sim.bat <test_name>

setlocal

REM Default test
if "%1"=="" (
    set TEST=basic_match_test
) else (
    set TEST=%1
)

REM Directories
set RTL_DIR=..\rtl
set TB_DIR=..\tb
set TEST_DIR=..\tests

echo ========================================
echo Pattern Detector UVM Simulation
echo Test: %TEST%
echo ========================================

REM Clean previous simulation
if exist work rmdir /s /q work
if exist transcript del /q transcript
if exist *.wlf del /q *.wlf
if exist *.vcd del /q *.vcd

REM Create library
vlib work

REM Compile RTL
echo.
echo [1/3] Compiling RTL...
vlog -sv +acc -timescale=1ns/1ps ^
     %RTL_DIR%\pattern_detector.sv
if errorlevel 1 goto error

REM Compile Testbench
echo.
echo [2/3] Compiling Testbench...
vlog -sv +acc -timescale=1ns/1ps ^
     +incdir+%TB_DIR% +incdir+%TEST_DIR% ^
     %TB_DIR%\pattern_detector_if.sv ^
     %TB_DIR%\pattern_detector_pkg.sv ^
     %TB_DIR%\tb_top.sv
if errorlevel 1 goto error

REM Run simulation
echo.
echo [3/3] Running simulation...
vsim -c -do "run -all; quit -f" ^
     +UVM_TESTNAME=%TEST% ^
     +UVM_VERBOSITY=UVM_MEDIUM ^
     -sv_seed=random ^
     tb_top
if errorlevel 1 goto error

echo.
echo ========================================
echo Simulation completed successfully!
echo ========================================
goto end

:error
echo.
echo ========================================
echo ERROR: Simulation failed!
echo ========================================
exit /b 1

:end
endlocal
