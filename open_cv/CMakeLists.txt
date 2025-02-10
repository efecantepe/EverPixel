cmake_minimum_required(VERSION 3.10)

# Project name
project(ImageProcessingLibrary)

# Specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Find OpenCV package
find_package(OpenCV REQUIRED)

# Add the source file
add_library(ImageProcessing STATIC opencv.cpp)

# Include directories for OpenCV
target_include_directories(ImageProcessing PRIVATE ${OpenCV_INCLUDE_DIRS})

# Link libraries for OpenCV
target_link_libraries(ImageProcessing PRIVATE ${OpenCV_LIBS})

