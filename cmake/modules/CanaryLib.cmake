# CanaryLib - Populates sources and settings for the core target
# This module adds all source subdirectories to the CORE_TARGET_NAME target

# Add include directories for all sources
target_include_directories(
    ${CORE_TARGET_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
)

# Add boost/di include directory if found
if(BOOST_DI_INCLUDE_DIRS)
    target_include_directories(
        ${CORE_TARGET_NAME}
        PRIVATE ${BOOST_DI_INCLUDE_DIRS}
    )
endif()

# Add source directories
add_subdirectory(account)
add_subdirectory(config)
add_subdirectory(creatures)
add_subdirectory(database)
add_subdirectory(game)
add_subdirectory(io)
add_subdirectory(items)
add_subdirectory(kv)
add_subdirectory(lib)
add_subdirectory(lua)
add_subdirectory(map)
add_subdirectory(security)
add_subdirectory(server)
add_subdirectory(utils)
