cmake_minimum_required(VERSION 3.8)

find_package(Boost 1.36.0)
if(Boost_FOUND)
    include_directories(${Boost_INCLUDE_DIRS})
endif()

message("" ${PLATFORM})

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(BISON_EXECUTABLE /opt/local/bin/bison)
    set(FLEX_EXECUTABLE /opt/local/bin/flex)
endif()

find_package(BISON 3.0)
find_package(FLEX 2.6)


BISON_TARGET(CppParser src/cpp14.y ${CMAKE_CURRENT_BINARY_DIR}/cpp14_parser.cpp DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/cpp14_parser.hpp COMPILE_FLAGS "-x -l -t --name-prefix=cpp14 -r all")
FLEX_TARGET(CppScanner src/cpp14.l ${CMAKE_CURRENT_BINARY_DIR}/cpp14_lexer.cpp DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/cpp14_lexer.hpp COMPILE_FLAGS "-L --trace --debug --yylineno --prefix=cpp14")

ADD_FLEX_BISON_DEPENDENCY(CppScanner CppParser)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_executable(cpp14 ${BISON_CppParser_OUTPUTS} ${FLEX_CppScanner_OUTPUTS} src/main.cpp)