cmake_minimum_required(VERSION 3.16)
project(xpm LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(xpm xpm.cpp)


# libdnf5
# -----------------------------------------------------------------------------
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBDNF5 REQUIRED IMPORTED_TARGET libdnf5)

if (LIBDNF5_FOUND)
    message(STATUS "libdnf5 found at ${LIBDNF5_LIBRARIES}")
    include_directories(${LIBDNF5_INCLUDE_DIRS})
    target_link_libraries(xpm PRIVATE PkgConfig::LIBDNF5)
else()
    message(FATAL_ERROR "libdnf5 not found. Please install libdnf5-devel.")
endif()
