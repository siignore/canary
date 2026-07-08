# Logging helper for CMake
# This module provides logging functions for CMake

include(MessageColors)

function(log_info MESSAGE)
	message(STATUS "${ColorBlue}ℹ${ColorReset} ${MESSAGE}")
endfunction()

function(log_success MESSAGE)
	message(STATUS "${ColorGreen}✓${ColorReset} ${MESSAGE}")
endfunction()

function(log_warning MESSAGE)
	message(WARNING "${ColorYellow}⚠${ColorReset} ${MESSAGE}")
endfunction()

function(log_error MESSAGE)
	message(FATAL_ERROR "${ColorRed}✗${ColorReset} ${MESSAGE}")
endfunction()

function(log_option_enabled OPTION_NAME)
	message(STATUS "${ColorGreen}✓${ColorReset} ${OPTION_NAME} enabled")
endfunction()

function(log_option_disabled OPTION_NAME)
	message(STATUS "${ColorYellow}✗${ColorReset} ${OPTION_NAME} disabled")
endfunction()
