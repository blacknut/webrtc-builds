@echo off
setlocal

set package_filename=%~1
set root_dir=%CD%

set out_dir=%root_dir%\out
set ext_dir=%out_dir%\external

if exist "%ext_dir%\" rd /S /Q %ext_dir%
mkdir %ext_dir%


if "x%package_filename%" EQU "x" goto call_vcvar

set include_path=%package_filename%\include
set librarie_path=%package_filename%\lib\x86_64-win-vc

goto skip_vcvar

:call_vcvar
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
set include_path=fake\include
set librarie_path=fake\lib\x86_64-win-vc
mkdir %librarie_path% %include_path% >nul 2>nul

:skip_vcvar
set GIT_PATH="C:\Program Files\Git\usr\bin\"

echo Building external projects
pushd %ext_dir%
    echo Building libwebsockets 2.4.2
    cmd.exe /c "git clone https://github.com/warmcat/libwebsockets.git --branch v2.4.2 --single-branch" 2>nul

    pushd libwebsockets
        mkdir build.win
        pushd build.win
            cmd.exe /C "cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX:PATH="%ext_dir%\delivery" -DCMAKE_CXX_COMPILER="C:/Program Files (x86)/Microsoft Visual Studio/2017/Community/VC/Tools/MSVC/14.16.27023/bin/HostX64/x64/cl.exe"  -DCMAKE_C_COMPILER="C:/Program Files (x86)/Microsoft Visual Studio/2017/Community/VC/Tools/MSVC/14.16.27023/bin/HostX64/x64/cl.exe" -DCMAKE_MAKE_PROGRAM="C:\PROGRAM FILES (X86)\MICROSOFT VISUAL STUDIO\2017\COMMUNITY\COMMON7\IDE\COMMONEXTENSIONS\MICROSOFT\CMAKE\Ninja\ninja.exe" -DCMAKE_BUILD_TYPE=Release -DLWS_WITH_SHARED=OFF -DLWS_WITH_ZLIB=OFF -DLWS_WITH_SSL=OFF -DLWS_WITHOUT_EXTENSIONS=ON -DLWS_STATIC_PIC=ON -DLWS_WITH_ZIP_FOPS=OFF -DLWS_WITHOUT_TESTAPPS=ON .." 2>nul >nul
            cmd.exe /C "ninja -C ." >nul
            cmd.exe /C "ninja install"
        popd
    popd

    echo Building jsoncpp 1.8.4
    cmd.exe /c "git clone https://github.com/open-source-parsers/jsoncpp.git --branch 1.8.4 --single-branch" 2>nul
    pushd jsoncpp
        mkdir build.win
        pushd build.win
            cmd.exe /C "cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX:PATH="%ext_dir%\delivery" -DCMAKE_CXX_COMPILER="C:/Program Files (x86)/Microsoft Visual Studio/2017/Community/VC/Tools/MSVC/14.16.27023/bin/HostX64/x64/cl.exe"  -DCMAKE_C_COMPILER="C:/Program Files (x86)/Microsoft Visual Studio/2017/Community/VC/Tools/MSVC/14.16.27023/bin/HostX64/x64/cl.exe" -DCMAKE_MAKE_PROGRAM="C:\PROGRAM FILES (X86)\MICROSOFT VISUAL STUDIO\2017\COMMUNITY\COMMON7\IDE\COMMONEXTENSIONS\MICROSOFT\CMAKE\Ninja\ninja.exe" -DCMAKE_BUILD_TYPE=Release -DJSONCPP_WITH_TESTS=OFF .." 2>nul >nul
            cmd.exe /C "ninja -C ." >nul
            cmd.exe /C "ninja install"
        popd
    popd
   
popd

echo Copying external projects
xcopy %ext_dir%\delivery\include\*.* %out_dir%\%include_path%\ /Y /A /S 2>nul >nul
xcopy %ext_dir%\delivery\lib\*.* %out_dir%\%librarie_path%\ /Y /A 2>nul >nul
echo Done with external projects