cmake_minimum_required(VERSION 3.10)

set(CMAKE_VERBOSE_MAKEFILE off)

project(top LANGUAGES NONE)

# For debug, use
# make VERBOSE=1 <target-name>
# message(${variable-name})

# Path variables
#   Project top
set(PROJECT_TOP_DIR ${CMAKE_CURRENT_LIST_DIR})
set(MODULES_DIR ${PROJECT_TOP_DIR}/modules)
set(PROJECT_DIR ${PROJECT_TOP_DIR}/prj)
set(SCRIPTS_DIR ${PROJECT_TOP_DIR}/scripts)

# Include Lint and Format handlers
include(${CMAKE_CURRENT_LIST_DIR}/scripts/version.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/scripts/svlint.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/scripts/lint.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/scripts/format.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/scripts/sim.cmake)

# Add a main target that depends on all module targets
add_custom_target(svlint)
add_custom_target(lint)
add_custom_target(format)
add_custom_target(sim)
add_custom_target(clean-sim)

# Initialize the global MODULES list
set(GLOBAL_MODULES "" CACHE INTERNAL "global project list of modules")

# Point to your custom modules (in this case, FindQuartus.cmake)
list(APPEND CMAKE_MODULE_PATH ${SCRIPTS_DIR})

# Include CMake files for the sources
include(${PROJECT_DIR}/sources.cmake)

# Iterate over the GLOBAL_MODULES list and add dependencies
foreach(MODULE ${GLOBAL_MODULES})
    message("Adding module ${MODULE}")
    add_dependencies(svlint svlint-${MODULE})
    add_dependencies(lint lint-${MODULE})
    add_dependencies(format format-${MODULE})
    add_dependencies(sim sim-${MODULE})
    add_dependencies(clean-sim clean-sim-${MODULE})
endforeach()
