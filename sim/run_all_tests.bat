@echo off
REM Run all UVM tests sequentially
REM Usage: run_all_tests.bat

echo ========================================
echo Running Pattern Detector Test Suite
echo ========================================
echo.

set TESTS=basic_match_test no_match_test first_window_match_test last_window_match_test multiple_matches_test full_mask_test zero_mask_test reset_test random_test

set PASS_COUNT=0
set FAIL_COUNT=0

for %%T in (%TESTS%) do (
    echo.
    echo ----------------------------------------
    echo Running: %%T
    echo ----------------------------------------
    
    vsim -c -do "run -all; exit" tb_top +UVM_TESTNAME=%%T +UVM_VERBOSITY=UVM_LOW > %%T.log 2>&1
    
    REM Check for "TEST PASSED" in log
    findstr /C:"** TEST PASSED **" %%T.log >nul
    if %ERRORLEVEL% EQU 0 (
        echo [PASS] %%T
        set /A PASS_COUNT+=1
    ) else (
        echo [FAIL] %%T
        set /A FAIL_COUNT+=1
    )
)

echo.
echo ========================================
echo Test Suite Summary
echo ========================================
echo Total Passed: %PASS_COUNT%
echo Total Failed: %FAIL_COUNT%
echo ========================================
