@echo off
setlocal enabledelayedexpansion

set destfile=%~1
set remove=%~2
set output=%~3

call set destsubfile=%%destfile:%remove%=%%
call set destrelfile=%%destfile:%remove%=.\%%


set thirdparty=%destrelfile:.\third_party=%
if x%thirdparty% EQU x%destrelfile% goto copyfile 

set testfile=%destrelfile:abseil-cpp=%
if x%testfile% NEQ x%destrelfile% goto copyfile 
set testfile=%destrelfile:boringssl=%
if x%testfile% NEQ x%destrelfile% goto copyfile 
set testfile=%destrelfile:expat\files=%
if x%testfile% NEQ x%destrelfile% goto copyfile 
set testfile=%destrelfile:jsoncpp\source\include\json=%
if x%testfile% NEQ x%destrelfile% goto copyfile 
set testfile=%destrelfile:libjpeg=%
if x%testfile% NEQ x%destrelfile% goto copyfile 
set testfile=%destrelfile:libsrtp=%
if x%testfile% NEQ x%destrelfile% goto copyfile 
set testfile=%destrelfile:libyuv=%
if x%testfile% NEQ x%destrelfile% goto copyfile 
set testfile=%destrelfile:libvpx=%
if x%testfile% NEQ x%destrelfile% goto copyfile 
set testfile=%destrelfile:opus=%
if x%testfile% NEQ x%destrelfile% goto copyfile 
set testfile=%destrelfile:protobuf=%
if x%testfile% NEQ x%destrelfile% goto copyfile 
set testfile=%destrelfile:usrsctp\usrsctplib=%
if x%testfile% NEQ x%destrelfile% goto copyfile 

goto exitscript

:copyfile
echo Copy %destfile%
xcopy "%destfile%" "%output%\%destsubfile%*" /Y /A >nul

:exitscript