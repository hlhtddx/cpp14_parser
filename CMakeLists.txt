cmake_minimum_required(VERSION 3.8)

find_package(Boost 1.36.0)
if(Boost_FOUND)
    include_directories(${Boost_INCLUDE_DIRS})
endif()

find_package(BISON)
find_package(FLEX)

BISON_TARGET(CppParser src/cpp14.y ${CMAKE_CURRENT_BINARY_DIR}/cpp14_parser.cpp COMPILE_FLAGS "-g -l -t --name-prefix=cpp14 -r state")
FLEX_TARGET(CppScanner src/cpp14.l ${CMAKE_CURRENT_BINARY_DIR}/cpp14_lexer.cpp COMPILE_FLAGS "--header-file=${CMAKE_CURRENT_BINARY_DIR}/cpp14_lexer.hpp -L --trace --debug --yylineno --prefix=cpp14")

ADD_FLEX_BISON_DEPENDENCY(CppScanner CppParser)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_executable(cpp14 ${BISON_CppParser_OUTPUTS} ${FLEX_CppScanner_OUTPUTS} src/main.cpp)