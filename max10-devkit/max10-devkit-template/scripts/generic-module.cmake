# Generic CMake module
## intended to be included in other CMake files to define a module's targets and dependencies.
function(create_module_targets)

    # Define the arguments
    set(options)
    set(oneValueArgs MODULE_NAME MODULE_DIR)
    set(multiValueArgs SOURCES TESTCASES)

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Check for required arguments
    if(NOT ARG_MODULE_NAME)
        message(FATAL_ERROR "MODULE_NAME is required")
    endif()

    if(NOT ARG_MODULE_DIR)
        message(FATAL_ERROR "MODULE_DIR is required")
    endif()

    # Set local variables from arguments
    set(fMODULE_NAME ${ARG_MODULE_NAME})
    set(fMODULE_DIR ${ARG_MODULE_DIR})

    # Handle optional sources
    if(ARG_SOURCES)
        set(fSOURCES ${ARG_SOURCES})
        message(STATUS "Creating targets for module '${fMODULE_NAME}' with sources: ${fSOURCES}")
    else()
        set(fSOURCES "")
        message(STATUS "Creating targets for module '${fMODULE_NAME}' with no sources")
    endif()

    # Handle optional testcases
    if(ARG_TESTCASES)
        set(fMODULE_SIM_TESTCASES ${ARG_TESTCASES})
        message(STATUS "Creating targets for module '${fMODULE_NAME}' with testcases: ${fMODULE_SIM_TESTCASES}")
    else()
        set(fMODULE_SIM_TESTCASES "")
        message(STATUS "Creating targets for module '${fMODULE_NAME}' with no testcases")
    endif()

    # Usage: create_module_targets(MODULE_NAME "test" MODULE_DIR "/path/to/module" TESTCASES "basic" "advanced")

    # Add the module name to the global MODULES list
    list(APPEND GLOBAL_MODULES ${fMODULE_NAME})
    set(GLOBAL_MODULES ${GLOBAL_MODULES} PARENT_SCOPE)
    list(APPEND GLOBAL_SOURCES ${fSOURCES})
    set(GLOBAL_SOURCES ${GLOBAL_SOURCES} PARENT_SCOPE)

    list(APPEND MODULE_LINT_OPTIONS ${GLOBAL_LINT_OPTIONS})
    list(APPEND MODULE_SVLINT_OPTIONS ${GLOBAL_SVLINT_OPTIONS})
    list(APPEND MODULE_SIM_OPTIONS ${GLOBAL_SIM_OPTIONS} -do)
    list(APPEND MODULE_AUTO_SIM_OPTIONS ${GLOBAL_SIM_OPTIONS} -c -do)

    # Add a custom target for SV linting the library's sources
    add_custom_target(
        svlint-${fMODULE_NAME}
        COMMAND ${SV_CODE_LINTER} ${MODULE_SVLINT_OPTIONS} ${fSOURCES}
        WORKING_DIRECTORY ${fMODULE_DIR}
        COMMENT "Running SV linter on ${fMODULE_NAME} sources: ${fSOURCES}"
        VERBATIM
    )

    # Add a custom target for linting the library's sources
    add_custom_target(
        lint-${fMODULE_NAME}
        COMMAND ${VERILOG_CODE_LINTER} ${MODULE_LINT_OPTIONS} ${fSOURCES}
        WORKING_DIRECTORY ${fMODULE_DIR}
        COMMENT "Running linter on ${fMODULE_NAME} sources: ${fSOURCES}"
        VERBATIM
    )

    # Add a custom target for the main file formatting
    add_custom_target(
        format-${fMODULE_NAME}
        COMMAND ${VERILOG_CODE_FORMATTER} ${GLOBAL_FORMAT_OPTIONS} ${fSOURCES}
        WORKING_DIRECTORY ${fMODULE_DIR}
        COMMENT "Running code formatter on ${fMODULE_NAME} sources: ${fSOURCES}"
        VERBATIM
    )

    # Define simulation artifacts directory
    set(SIM_ARTIFACTS_DIR ${fMODULE_DIR}/sim/run/_sim-gen-files)

    # Add custom targets for simulation - one for each testcase
    foreach(TESTCASE ${fMODULE_SIM_TESTCASES})
        add_custom_target(
            sim-${fMODULE_NAME}-${TESTCASE}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${SIM_ARTIFACTS_DIR}
            COMMAND ${CMAKE_COMMAND} -E chdir ${SIM_ARTIFACTS_DIR} ${VERILOG_SIMULATOR} ${MODULE_SIM_OPTIONS} "do ../${fMODULE_NAME}.do ${TESTCASE}"
            WORKING_DIRECTORY ${fMODULE_DIR}/sim/run
            COMMENT "Running simulation on ${fMODULE_NAME} testcase: ${TESTCASE}"
            VERBATIM
        )
    endforeach()

    # Add automation custom targets for simulation - one for each testcase
    foreach(TESTCASE ${fMODULE_SIM_TESTCASES})
        add_custom_target(
            sim-${fMODULE_NAME}-${TESTCASE}-auto
            COMMAND ${CMAKE_COMMAND} -E make_directory ${SIM_ARTIFACTS_DIR}
            COMMAND ${CMAKE_COMMAND} -E chdir ${SIM_ARTIFACTS_DIR} ${VERILOG_SIMULATOR} ${MODULE_AUTO_SIM_OPTIONS} "do ../${fMODULE_NAME}.do ${TESTCASE}"
            WORKING_DIRECTORY ${fMODULE_DIR}/sim/run
            COMMENT "Running automation simulation on ${fMODULE_NAME} testcase: ${TESTCASE}"
            VERBATIM
        )
    endforeach()

    # Add a target to run all testcases
    add_custom_target(
        sim-${fMODULE_NAME}
        COMMENT "Running all simulation testcases for ${fMODULE_NAME}"
    )

    foreach(TESTCASE ${fMODULE_SIM_TESTCASES})
        add_dependencies(sim-${fMODULE_NAME} sim-${fMODULE_NAME}-${TESTCASE}-auto)
    endforeach()

    # Add a target to clean simulation data
    # Create the custom clean-sim target
    add_custom_target(
        clean-sim-${fMODULE_NAME}
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${SIM_ARTIFACTS_DIR}
        COMMENT "Cleaning simulation artifacts for ${fMODULE_NAME}"
        VERBATIM
    )

    # Add simulation artifacts directory to CMake's built-in clean target
    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
        ${SIM_ARTIFACTS_DIR}
    )
endfunction()
