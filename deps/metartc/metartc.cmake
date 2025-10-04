if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
orcaslicer_add_cmake_project(metartc
  # GIT_REPOSITORY https://github.com/aliyun/aliyun-oss-cpp-sdk.git
  # GIT_TAG v1.9.2
  URL https://github.com/CrealityOfficial/metartc/archive/refs/tags/v1.0.0.tar.gz
  URL_HASH SHA256=696780282b3a9324e87d451ee2c8889e3ebc93c45d06db46571208477bc93d9a
  #PATCH_COMMAND ${patch_command}
  CMAKE_ARGS
      -DCMAKE_C_FLAGS=-Wno-error=incompatible-pointer-types
)

add_dependencies(dep_metartc dep_FFmpeg)

if (MSVC)
    add_debug_dep(dep_FFmpeg)
endif ()
endif()
