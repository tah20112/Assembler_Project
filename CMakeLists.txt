cmake_minimum_required(VERSION 3.5)
project(Disassembler)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES main.c)
add_executable(Disassembler ${SOURCE_FILES} main.c)