cmake_minimum_required(
    VERSION 3.22
    FATAL_ERROR
)

# Prepend custom module path to intercept find_package calls before vcpkg wrapper
list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

# *****************************************************************************
# CMake Features
# *****************************************************************************
set(CMAKE_CXX_STANDARD
    23
)
set(CMAKE_CXX_STANDARD_REQUIRED
    ON
)
set(CMAKE_POSITION_INDEPENDENT_CODE
    ON
)
set(CMAKE_DISABLE_SOURCE_CHANGES
    ON
)
set(CMAKE_DISABLE_IN_SOURCE_BUILD
    ON
)
set(Boost_NO_WARN_NEW_VERSIONS
    ON
)

# Make will print more details
set(CMAKE_VERBOSE_MAKEFILE
    OFF
)

# *****************************************************************************
# Direct CMake Config Loading - Bypasses vcpkg wrapper version checking entirely
# Instead of using find_package which invokes vcpkg wrapper, directly include configs
# *****************************************************************************
if(DEFINED VCPKG_INSTALLED_DIR)
    # Directly load CMake package configs from vcpkg, bypassing find_package wrapper
    set(_VCPKG_SHARE "${VCPKG_INSTALLED_DIR}/share")
    
    # Load Protobuf config directly
    if(EXISTS "${_VCPKG_SHARE}/protobuf/protobuf-config.cmake")
        include("${_VCPKG_SHARE}/protobuf/protobuf-config.cmake")
    endif()
    
    # Load Abseil config directly  
    if(EXISTS "${_VCPKG_SHARE}/absl/abslConfig.cmake")
        include("${_VCPKG_SHARE}/absl/abslConfig.cmake")
    endif()
    
    # Load other package configs
    if(EXISTS "${_VCPKG_SHARE}/eventpp/eventpp-config.cmake")
        include("${_VCPKG_SHARE}/eventpp/eventpp-config.cmake")
    endif()
    if(EXISTS "${_VCPKG_SHARE}/pugixml/pugixml-config.cmake")
        include("${_VCPKG_SHARE}/pugixml/pugixml-config.cmake")
    endif()
    if(EXISTS "${_VCPKG_SHARE}/spdlog/spdlog-config.cmake")
        include("${_VCPKG_SHARE}/spdlog/spdlog-config.cmake")
    endif()
    if(EXISTS "${_VCPKG_SHARE}/CURL/CURLConfig.cmake")
        include("${_VCPKG_SHARE}/CURL/CURLConfig.cmake")
    endif()
    if(EXISTS "${_VCPKG_SHARE}/mbedTLS/mbedTLSConfig.cmake")
        include("${_VCPKG_SHARE}/mbedTLS/mbedTLSConfig.cmake")
    endif()
    if(EXISTS "${_VCPKG_SHARE}/magic_enum/magic_enum-config.cmake")
        include("${_VCPKG_SHARE}/magic_enum/magic_enum-config.cmake")
    endif()
    if(EXISTS "${_VCPKG_SHARE}/asio/asio-config.cmake")
        include("${_VCPKG_SHARE}/asio/asio-config.cmake")
    endif()
endif()

# *****************************************************************************
# Find packages for non-problematic vcpkg packages
# *****************************************************************************
# Helper function to find vcpkg root
if(DEFINED VCPKG_INSTALLED_DIR)
    message(STATUS "VCPKG_INSTALLED_DIR: ${VCPKG_INSTALLED_DIR}")
    message(STATUS "VCPKG_TARGET_TRIPLET: ${VCPKG_TARGET_TRIPLET}")

    # Try to find actual vcpkg root - handle multiple possible nested structures
    set(_VCPKG_ROOT "")

    # Check if VCPKG_INSTALLED_DIR itself has the packages
    if(EXISTS "${VCPKG_INSTALLED_DIR}/include/luajit")
        set(_VCPKG_ROOT "${VCPKG_INSTALLED_DIR}")
    # Check if there's a triplet subdirectory
    elseif(EXISTS "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/luajit")
        set(_VCPKG_ROOT "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
    # Check for x64-windows fallback
    elseif(EXISTS "${VCPKG_INSTALLED_DIR}/x64-windows/include/luajit")
        set(_VCPKG_ROOT "${VCPKG_INSTALLED_DIR}/x64-windows")
    # Check parent directory
    elseif(EXISTS "${VCPKG_INSTALLED_DIR}/../x64-windows/include/luajit")
        set(_VCPKG_ROOT "${VCPKG_INSTALLED_DIR}/../x64-windows")
    # Last resort - check for any x64-windows in vcpkg_installed
    elseif(EXISTS "vcpkg_installed/x64-windows/x64-windows/x64-windows/include/luajit")
        set(_VCPKG_ROOT "vcpkg_installed/x64-windows/x64-windows/x64-windows")
    else()
        message(FATAL_ERROR "Could not find vcpkg packages (LuaJIT) in any expected location")
    endif()

    message(STATUS "_VCPKG_ROOT: ${_VCPKG_ROOT}")

    # LuaJIT - manually configure since vcpkg doesn't provide config files
    set(LuaJIT_INCLUDE_DIR "${_VCPKG_ROOT}/include/luajit")
    set(LuaJIT_LIBRARY "${_VCPKG_ROOT}/lib/lua51.lib")

    if(EXISTS "${LuaJIT_INCLUDE_DIR}/lua.h" AND EXISTS "${LuaJIT_LIBRARY}")
        add_library(LuaJIT::LuaJIT UNKNOWN IMPORTED)
        set_target_properties(LuaJIT::LuaJIT PROPERTIES
            IMPORTED_LOCATION "${LuaJIT_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${LuaJIT_INCLUDE_DIR}"
        )
        set(LuaJIT_FOUND TRUE)
        message(STATUS "LuaJIT found at ${_VCPKG_ROOT}")
    else()
        message(FATAL_ERROR "LuaJIT not found at ${LuaJIT_INCLUDE_DIR}")
    endif()

    # MySQL/MariaDB - manually configure
    set(MySQL_INCLUDE_DIR "${_VCPKG_ROOT}/include/mysql")
    set(MySQL_LIBRARY "${_VCPKG_ROOT}/lib/libmariadb.lib")

    if((EXISTS "${MySQL_INCLUDE_DIR}") AND (EXISTS "${MySQL_LIBRARY}"))
        add_library(MySQL::MySQL UNKNOWN IMPORTED)
        set_target_properties(MySQL::MySQL PROPERTIES
            IMPORTED_LOCATION "${MySQL_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${MySQL_INCLUDE_DIR}"
        )
        set(MySQL_FOUND TRUE)
        message(STATUS "MySQL found at ${_VCPKG_ROOT}")
    else()
        message(FATAL_ERROR "MySQL not found at ${MySQL_INCLUDE_DIR} or ${MySQL_LIBRARY}")
    endif()
else()
    message(FATAL_ERROR "VCPKG_INSTALLED_DIR not set")
endif()

find_package(Threads REQUIRED)
find_package(ZLIB REQUIRED)

find_path(BOOST_DI_INCLUDE_DIRS "boost/di.hpp")

# *****************************************************************************
# === GCC Minimum Version ===
if(CMAKE_COMPILER_IS_GNUCXX)
    message("-- Compiler: GCC - Version: ${CMAKE_CXX_COMPILER_VERSION}")
    if(CMAKE_CXX_COMPILER_VERSION
       VERSION_LESS
       11
    )
        message(FATAL_ERROR "GCC version must be at least 11!")
    endif()
endif()

# === Minimum required version for visual studio ===
if(CMAKE_CXX_COMPILER_ID
   STREQUAL
   "MSVC"
)
    message(
        "-- Compiler: Visual Studio - Version: ${CMAKE_CXX_COMPILER_VERSION}"
    )
    if(CMAKE_CXX_COMPILER_VERSION
       VERSION_LESS
       "19.32"
    )
        message(FATAL_ERROR "Visual Studio version must be at least 19.32")
    endif()
endif()

# *****************************************************************************
# Options
# *****************************************************************************
option(
    TOGGLE_BIN_FOLDER
    "Use build/bin folder for generate compilation files"
    OFF
)
option(
    OPTIONS_ENABLE_OPENMP
    "Enable Open Multi-Processing support."
    ON
)
option(
    DEBUG_LOG
    "Enable Debug Log"
    OFF
)
option(
    ASAN_ENABLED
    "Build this target with AddressSanitizer"
    OFF
)
option(
    BUILD_STATIC_LIBRARY
    "Build using static libraries"
    OFF
)
option(
    SPEED_UP_BUILD_UNITY
    "Compile using build unity for speed up build"
    ON
)
option(
    USE_PRECOMPILED_HEADER
    "Compile using precompiled header"
    ON
)

# === TOGGLE_BIN_FOLDER ===
if(TOGGLE_BIN_FOLDER)
    log_option_enabled("TOGGLE_BIN_FOLDER")
else()
    log_option_disabled("TOGGLE_BIN_FOLDER")
endif()

# === OPTIONS_ENABLE_OPENMP ===
if(OPTIONS_ENABLE_OPENMP)
    log_option_enabled("OPTIONS_ENABLE_OPENMP")
else()
    log_option_disabled("OPTIONS_ENABLE_OPENMP")
endif()

# === DEBUG LOG ===
# cmake -DDEBUG_LOG=ON ..
if(DEBUG_LOG)
    add_definitions(-DDEBUG_LOG=ON)
    add_definitions(-DSPDLOG_ACTIVE_LEVEL=SPDLOG_LEVEL_TRACE)
    log_option_enabled("DEBUG LOG")
else()
    log_option_disabled("DEBUG LOG")
endif()

# === ASAN ===
if(ASAN_ENABLED)
    log_option_enabled("asan")
    if(MSVC)
        add_compile_options(/fsanitize=address)
    else()
        add_compile_options(-fsanitize=address)
        link_libraries(-fsanitize=address)
    endif()
else()
    log_option_disabled("asan")
endif()

# === BUILD_STATIC_LIBRARY ===
if(BUILD_STATIC_LIBRARY)
    log_option_enabled("STATIC_LIBRARY")
    if(MSVC)
        set(CMAKE_FIND_LIBRARY_SUFFIXES
            ".lib"
        )
    elseif(
        UNIX
        AND NOT APPLE
    )
        set(CMAKE_FIND_LIBRARY_SUFFIXES
            ".a"
        )
    elseif(APPLE)
        set(CMAKE_FIND_LIBRARY_SUFFIXES
            ".a" ".dylib"
        )
    endif()
else()
    log_option_disabled("STATIC_LIBRARY")
endif()

# === SPEED_UP_BUILD_UNITY ===
if(SPEED_UP_BUILD_UNITY)
    log_option_enabled("SPEED_UP_BUILD_UNITY")
else()
    log_option_disabled("SPEED_UP_BUILD_UNITY")
endif()

# === USE_PRECOMPILED_HEADER ===
if(USE_PRECOMPILED_HEADER)
    log_option_enabled("USE_PRECOMPILED_HEADER")
else()
    log_option_disabled("USE_PRECOMPILED_HEADER")
endif()

# === IPO Configuration ===
function(configure_linking target_name)
    if(OPTIONS_ENABLE_IPO)
        # Check if IPO/LTO is supported
        include(CheckIPOSupported)
        check_ipo_supported(
            RESULT ipo_supported
            OUTPUT ipo_output
            LANGUAGES CXX
        )

        # Get the GCC compiler version, if applicable
        if(CMAKE_CXX_COMPILER_ID
           STREQUAL
           "GNU"
        )
            execute_process(
                COMMAND ${CMAKE_CXX_COMPILER} -dumpversion
                OUTPUT_VARIABLE GCC_VERSION
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
        endif()

        if(ipo_supported)
            set_property(
                TARGET ${target_name}
                PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE
            )
            log_option_enabled("IPO/LTO enabled for target ${target_name}.")

            if(MSVC)
                target_compile_options(
                    ${target_name}
                    PRIVATE /GL
                )
                target_link_options(
                    ${target_name}
                    PRIVATE
                    /LTCG
                )
            elseif(
                CMAKE_CXX_COMPILER_ID
                MATCHES
                "GNU|Clang"
            )
                # Check if it's running on Linux, using GCC 14, and in Debug
                # mode
                if(CMAKE_SYSTEM_NAME
                   STREQUAL
                   "Linux"
                   AND CMAKE_CXX_COMPILER_ID
                       STREQUAL
                       "GNU"
                   AND GCC_VERSION
                       VERSION_EQUAL
                       "14"
                   AND CMAKE_BUILD_TYPE
                       STREQUAL
                       "Debug"
                )
                    log_option_disabled(
                        "LTO disabled for GCC 14 in Debug mode on Linux for target ${target_name}."
                    )
                    # Disable LTO for Debug builds with GCC 14
                    target_compile_options(
                        ${target_name}
                        PRIVATE -fno-lto
                    )
                    target_link_options(
                        ${target_name}
                        PRIVATE
                        -fno-lto
                    )
                else()
                    target_compile_options(
                        ${target_name}
                        PRIVATE -flto=auto
                    )
                    target_link_options(
                        ${target_name}
                        PRIVATE
                        -flto=auto
                    )
                endif()
            endif()
        else()
            log_option_disabled(
                "IPO/LTO is not supported for target ${target_name}: ${ipo_output}"
            )
        endif()
    endif()
endfunction()

# *****************************************************************************
# Compiler Options
# *****************************************************************************
if(MSVC)
    foreach(
        type
        RELEASE
        DEBUG
        MINSIZEREL
    )
        string(
            REPLACE "/Zi"
                    "/Z7"
                    CMAKE_CXX_FLAGS_${type}
                    "${CMAKE_CXX_FLAGS_${type}}"
        )
        string(
            REPLACE "/Zi"
                    "/Z7"
                    CMAKE_C_FLAGS_${type}
                    "${CMAKE_C_FLAGS_${type}}"
        )
    endforeach(type)
    add_compile_options(
        /MP
        /FS
        /Zf
        /EHsc
    )
else()
    add_compile_options(
        -Wno-unused-parameter
        -Wno-sign-compare
        -Wno-switch
        -Wno-implicit-fallthrough
        -Wno-extra
    )
endif()

# === Compiler Features ===
add_library(project_options INTERFACE)
target_compile_features(
    project_options
    INTERFACE cxx_std_23
)

# *****************************************************************************
# Output Directory Function
# *****************************************************************************
function(set_output_directory target_name)
    if(TOGGLE_BIN_FOLDER)
        set_target_properties(
            ${target_name}
            PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
        )
    else()
        set_target_properties(
            ${target_name}
            PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/"
        )
    endif()
endfunction()

# *****************************************************************************
# Setup Target Function
# *****************************************************************************
function(setup_target TARGET_NAME)
    if(MSVC
       AND BUILD_STATIC_LIBRARY
    )
        set_property(
            TARGET ${TARGET_NAME}
            PROPERTY MSVC_RUNTIME_LIBRARY
                     "MultiThreaded$<$<CONFIG:Debug>:Debug>"
        )
    endif()

    if(MSVC)
        target_compile_options(
            ${TARGET_NAME}
            PRIVATE $<$<CONFIG:RelWithDebInfo>:/Zi>
        )

        get_target_property(
            target_type
            ${TARGET_NAME}
            TYPE
        )
        if(target_type
           STREQUAL
           "EXECUTABLE"
           OR target_type
              STREQUAL
              "SHARED_LIBRARY"
           OR target_type
              STREQUAL
              "MODULE_LIBRARY"
        )
            target_link_options(
                ${TARGET_NAME}
                PRIVATE
                $<$<CONFIG:RelWithDebInfo>:/DEBUG:FULL>
                $<$<OR:$<CONFIG:Release>,$<CONFIG:RelWithDebInfo>>:/OPT:REF>
                $<$<OR:$<CONFIG:Release>,$<CONFIG:RelWithDebInfo>>:/OPT:ICF>
            )
        endif()
    endif()

    target_link_libraries(
        ${TARGET_NAME}
        PUBLIC project_options
    )
endfunction()
