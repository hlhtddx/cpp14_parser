cmake_minimum_required(VERSION 3.8)

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(BISON_EXECUTABLE /usr/local/opt/bison/bin/bison)
    set(FLEX_EXECUTABLE /usr/local/opt/flex/bin/flex)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(BISON_EXECUTABLE ${MINGW_ROOT}\\msys\\1.0\\bin\\bison.exe)
    set(FLEX_EXECUTABLE ${MINGW_ROOT}\\msys\\1.0\\bin\\flex.exe)
endif()

find_package(Boost 1.32.0 REQUIRED)
if(Boost_FOUND)
    include_directories(${Boost_INCLUDE_DIRS})
endif()

find_package(BISON 2.4 REQUIRED)
find_package(FLEX 2.5 REQUIRED)

BISON_TARGET(
        CppParser
        src/cpp14.y
        ${CMAKE_CURRENT_BINARY_DIR}/cpp14_parser.cpp
        DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/cpp14_parser.hpp
        COMPILE_FLAGS "-x -l -t --name-prefix=cpp14 -r state"
)

FLEX_TARGET(
        CppScanner
        src/cpp14.l
        ${CMAKE_CURRENT_BINARY_DIR}/cpp14_lexer.cpp
        DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/cpp14_lexer.hpp
        COMPILE_FLAGS "-L --debug --yylineno --prefix=cpp14"
)

ADD_FLEX_BISON_DEPENDENCY(CppScanner CppParser)

include_directories(${CMAKE_CURRENT_BINARY_DIR})
add_definitions(-std=c++14)
add_subdirectory(test)

add_executable(cpp14 ${BISON_CppParser_OUTPUTS} ${FLEX_CppScanner_OUTPUTS} src/main.cpp)
