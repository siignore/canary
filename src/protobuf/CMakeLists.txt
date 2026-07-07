# *****************************************************************************
# Project protobuf
# *****************************************************************************
project(protobuf)

# Protobuf already configured in BaseConfig.cmake
# Note: protobuf_generate_cpp macro not available from protobuf-config.cmake
# Proto files (appearances.proto, kv.proto) can be compiled manually if needed

find_package(Threads)

# Create a simple protobuf library target that links to protobuf::libprotobuf-lite
# Proto code generation can be handled separately or by the build system
if(MSVC AND BUILD_STATIC_LIBRARY)
    add_library(${PROJECT_NAME} STATIC IMPORTED)
else()
    add_library(${PROJECT_NAME} SHARED IMPORTED)
endif()

target_link_libraries(
    ${PROJECT_NAME}
    INTERFACE protobuf::libprotobuf-lite
)

message(STATUS "Protobuf library target created (code generation deferred)")
