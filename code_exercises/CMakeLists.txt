cmake_minimum_required(VERSION 3.15...3.30)

project(
  PlusMinus
  VERSION 1.0
  LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)

file(GLOB V_GLOB LIST_DIRECTORIES true "src/*")
foreach(item ${V_GLOB})
	if(IS_DIRECTORY ${item})
		add_subdirectory(${item})
	endif()
endforeach()