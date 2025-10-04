if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
set(_conf_cmd ./configure)
set(_make_cmd make -j${NPROC})
set(_install_cmd make -j${NPROC} install)
ExternalProject_Add(dep_FFmpeg
    #EXCLUDE_FROM_ALL ON
    URL "https://ffmpeg.org/releases/ffmpeg-4.2.tar.bz2"
    URL_HASH SHA256=306bde5f411e9ee04352d1d3de41bd3de986e42e2af2a4c44052dce1ada26fb8
    DOWNLOAD_DIR ${DEP_DOWNLOAD_DIR}/FFmpeg
	CONFIGURE_COMMAND ${_conf_cmd}
        "--prefix=${DESTDIR}"
        "--enable-gpl"
        "--enable-libx264"
        "--enable-static"
        "--disable-x86asm"
	"--disable-doc"
        "--disable-inline-asm"
        "--disable-vaapi"
        "--disable-vdpau"
        "--disable-libdrm"
    BUILD_IN_SOURCE ON
    BUILD_COMMAND ${_make_cmd}
    INSTALL_COMMAND ${_install_cmd}
)
endif()
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    ExternalProject_Add(dep_x264
        URL "https://code.videolan.org/videolan/x264/-/archive/master/x264-master.tar.bz2"
        DOWNLOAD_DIR ${DEP_DOWNLOAD_DIR}/x264
        CONFIGURE_COMMAND ./configure --prefix=${DESTDIR} --enable-static --disable-opencl
        BUILD_COMMAND make -j${NPROC}
        INSTALL_COMMAND make install
        BUILD_IN_SOURCE ON
    )
    set(_conf_cmd ./configure)
    set(_make_cmd make -j${NPROC})
    set(_install_cmd make -j${NPROC} install)
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|amd64")
        set(TARGET_ARCH "x86_64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm|aarch64")
        set(TARGET_ARCH "arm64")
    endif()
    list(APPEND _ffmpeg_flags
        "--prefix=${DESTDIR}"
        "--libdir=${DESTDIR}/lib"
        "--enable-gpl"
        "--enable-libx264"
        "--enable-static"
        "--disable-doc"
        "--extra-cflags=-I${DESTDIR}/include"
        "--extra-ldflags=-L${DESTDIR}/lib"
        "--extra-libs=-lx264"
        "--pkg-config-flags=--static"
        
    )
    if(TARGET_ARCH STREQUAL "x86_64")
        list(APPEND _ffmpeg_flags "--enable-x86asm")  # 启用x86汇编
    elseif(TARGET_ARCH STREQUAL "arm64")
        list(APPEND _ffmpeg_flags "--enable-neon")    # 启用ARM NEON优化
    endif()
    ExternalProject_Add(dep_FFmpeg
        URL "https://ffmpeg.org/releases/ffmpeg-4.2.tar.bz2"
        URL_HASH SHA256=306bde5f411e9ee04352d1d3de41bd3de986e42e2af2a4c44052dce1ada26fb8
        DOWNLOAD_DIR ${DEP_DOWNLOAD_DIR}/FFmpeg
        CONFIGURE_COMMAND ${_conf_cmd}
            ${_ffmpeg_flags}
        BUILD_IN_SOURCE ON
        BUILD_COMMAND ${_make_cmd}
        INSTALL_COMMAND ${_install_cmd}
        DEPENDS dep_x264
    )
endif()
if(WIN32)
set(DOWNLOAD_URL "https://github.com/mcmtroffaes/ffmpeg-msvc-build/releases/download/20211207.0.0/ffmpeg-2021-12-07-0-lgpl21-x64-windows.7z")
ExternalProject_Add(
    dep_FFmpeg
    URL ${DOWNLOAD_URL}
    URL_HASH SHA256=acc0abeee5e8fa6f214fdba0f47987784a19a68fee018386abcb6f9be5138cc7
    DOWNLOAD_DIR ${DEP_DOWNLOAD_DIR}/FFmpeg
    DOWNLOAD_NO_EXTRACT 0 # 自动解压文件
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)
ExternalProject_Get_Property(dep_FFmpeg SOURCE_DIR)
add_custom_command(TARGET dep_FFmpeg POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR}/installed/x64-windows/include/libavdevice ${DESTDIR}/include/libavdevice
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR}/installed/x64-windows/include/libavfilter ${DESTDIR}/include/libavfilter
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR}/installed/x64-windows/include/libavformat ${DESTDIR}/include/libavformat
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR}/installed/x64-windows/include/libavutil ${DESTDIR}/include/libavutil
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR}/installed/x64-windows/include/libswresample ${DESTDIR}/include/libswresample
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR}/installed/x64-windows/include/libswscale ${DESTDIR}/include/libswscale
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR}/installed/x64-windows/include/libavcodec ${DESTDIR}/include/libavcodec
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR}/installed/x64-windows/lib ${DESTDIR}/lib
    COMMAND ${CMAKE_COMMAND} -E remove ${DESTDIR}/lib/libpng16.lib
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR}/installed/x64-windows/bin ${DESTDIR}/bin/ffmpeg
)
endif()
