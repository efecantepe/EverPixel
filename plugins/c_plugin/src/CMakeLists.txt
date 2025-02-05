# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(c_plugin_library VERSION 0.0.1 LANGUAGES C)

add_library(c_plugin SHARED
  "c_plugin.c"
)

set_target_properties(c_plugin PROPERTIES
  PUBLIC_HEADER c_plugin.h
  OUTPUT_NAME "c_plugin"
)

target_compile_definitions(c_plugin PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(c_plugin PRIVATE "-Wl,-z,max-page-size=16384")
endif()
