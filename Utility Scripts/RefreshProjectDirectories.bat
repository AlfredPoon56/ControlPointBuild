@echo off

rem STEP 1: DELETE
RMDIR %spDevDir% /S /Q 
RMDIR "%axcelerHive%" /S /Q

rem STEP 2: CREATE
MD %spDevDir%
MD "%axcelerHive%"