# Find LuaJIT
# This module defines:
#  LuaJIT_FOUND - whether LuaJIT was found
#  LuaJIT_INCLUDE_DIRS - the include directories for LuaJIT
#  LuaJIT_LIBRARIES - the libraries to link against

# First, try to find using VCPKG_INSTALLED_DIR if it's set
if(DEFINED VCPKG_INSTALLED_DIR)
	find_path(LuaJIT_INCLUDE_DIR
		NAMES lua.h luajit.h
		PATHS ${VCPKG_INSTALLED_DIR}
		PATH_SUFFIXES include/luajit
		NO_DEFAULT_PATH
	)

	find_library(LuaJIT_LIBRARY
		NAMES lua51 luajit luajit51
		PATHS ${VCPKG_INSTALLED_DIR}
		PATH_SUFFIXES lib
		NO_DEFAULT_PATH
	)
else()
	# Fallback to standard search paths
	find_path(LuaJIT_INCLUDE_DIR
		NAMES lua.h luajit.h
		PATH_SUFFIXES include/luajit include
	)

	find_library(LuaJIT_LIBRARY
		NAMES lua51 luajit luajit51
		PATH_SUFFIXES lib
	)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LuaJIT
	REQUIRED_VARS LuaJIT_LIBRARY LuaJIT_INCLUDE_DIR
)

if(LuaJIT_FOUND)
	set(LuaJIT_INCLUDE_DIRS ${LuaJIT_INCLUDE_DIR})
	set(LuaJIT_LIBRARIES ${LuaJIT_LIBRARY})

	if(NOT TARGET LuaJIT::LuaJIT)
		add_library(LuaJIT::LuaJIT UNKNOWN IMPORTED)
		set_target_properties(LuaJIT::LuaJIT PROPERTIES
			IMPORTED_LOCATION "${LuaJIT_LIBRARY}"
			INTERFACE_INCLUDE_DIRECTORIES "${LuaJIT_INCLUDE_DIRS}"
		)
	endif()
endif()

mark_as_advanced(LuaJIT_INCLUDE_DIR LuaJIT_LIBRARY)
