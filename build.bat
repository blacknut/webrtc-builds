@echo off
setlocal

set root_dir=%CD%
cmd.exe /C "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x86_amd64

set GIT_PATH="C:\Program Files\Git\usr\bin\"
set DEPOT_TOOLS_WIN_TOOLCHAIN=0
set depot_tools_url="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
set depot_tools_dir="%CD%\depot_tools"

if not exist %GIT_PATH% goto error

echo Checking out depot_tools
if exist "%depot_tools_dir%\" goto depot_exist
git clone -q %depot_tools_url% %depot_tools_dir%
pushd %depot_tools_dir%
rem    cmd.exe /C "gclient.bat"
popd

goto after_depot
:depot_exist
pushd %depot_tools_dir%
    cmd.exe /C "git reset --hard -q"
popd


:after_depot
set PATH=%depot_tools_dir%;%PATH%
set out_dir=%root_dir%\out

if exist "%out_dir%\" goto out_exist
mkdir %out_dir%

:out_exist
set revision_number=0
set /p revision=<webrtc.revision

echo Checking out to revision %revision%

pushd %out_dir%

    if exist %out_dir%\src\ goto fetched
    cmd.exe /C "fetch --nohooks webrtc"

    :fetched
    echo Cleaning WebRTC source
    pushd src
        cmd.exe /C "git clean -f"
    popd
    echo Syncing WebRTC source
    cmd.exe /C "gclient sync --force --revision %revision%"
popd

echo Env Lib path
echo %LIB%

echo Patching WebRTC source
pushd %out_dir%\src
    cmd.exe /C "git apply ../../patches/webrtc-src.webrtc_gni.component_build.patch"
    cmd.exe /C "git apply ../../patches/webrtc-src.audio_encoder_opus.enable_stereo.patch"
popd

echo Compiling WebRTC source
set common_args=rtc_include_tests=false treat_warnings_as_errors=false rtc_use_h264=true
set target_args=target_os=\"win\" target_cpu=\"x64\"

rem [ $ENABLE_RTTI = 1 ] && common_args+=" use_rtti=true"
set common_args=%common_args% use_rtti=true

rem [ $ENABLE_STATIC_LIBS = 1 ] && common_args+=" is_component_build=true"
set common_args=%common_args% is_component_build=true

rem [ "$cfg" = 'Release' ] && common_args+=' is_debug=false strip_debug_info=true symbol_level=0'
set common_args=%common_args% is_debug=false strip_debug_info=true symbol_level=0

set outputdir=out\x64\Release

pushd %out_dir%\src
    echo Generating project files with: %target_args% %common_args%
    cmd.exe /C "gn gen %outputdir% --args="%target_args% %common_args%" "
    pushd %outputdir%
        rem cmd.exe /C "ninja -v -C  ."
        cmd.exe /C "ninja -C  ."
    popd

popd

set package_filename=lakitu-%revision%-win-x64

echo Packaging WebRTC : %package_filename%

set include_path=%package_filename%\include\webrtc
set librarie_path=%package_filename%\lib\x86_64-win-vc
set binarie_path=%package_filename%\bin
pushd %out_dir%
    if not exist %include_path%\ mkdir %include_path% packages %librarie_path%
    
    pushd src
        set header_source_dir=.
        
        for /R . %%i in (%header_source_dir%\*.h) do (
            cmd.exe /C "%root_dir%\copyfile.bat "%%i" "%out_dir%\src\" "%out_dir%\%include_path%\""
        )
        xcopy %out_dir%\src\%outputdir%\boringssl.dll.lib %out_dir%\%librarie_path%\ /Y /A >nul
        xcopy %out_dir%\src\%outputdir%\protobuf_lite.dll.lib %out_dir%\%librarie_path%\ /Y /A >nul
        xcopy %out_dir%\src\%outputdir%\ffmpeg.dll.lib %out_dir%\%librarie_path%\ /Y /A >nul
        xcopy %out_dir%\src\%outputdir%\obj\webrtc.lib %out_dir%\%librarie_path%\ /Y /A >nul
        xcopy %out_dir%\src\%outputdir%\boringssl.dll %out_dir%\%binarie_path%\ /Y /A >nul
        xcopy %out_dir%\src\%outputdir%\protobuf_lite.dll %out_dir%\%binarie_path%\ /Y /A >nul
        xcopy %out_dir%\src\%outputdir%\ffmpeg.dll %out_dir%\%binarie_path%\ /Y /A >nul
    popd

    set outfile=%package_filename%.7z
    del /Q /F %outfile% >nul
    
    pushd %package_filename%
        %root_dir%\tools\win\7z\7z.exe a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -ir!lib\x86_64-win-vc -ir!bin -ir!include -r ..\packages\%outfile% >nul
    popd
popd


:error
echo Done
