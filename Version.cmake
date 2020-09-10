# Ignix-CMake-Submodules
# Version.cmake
# Author: Alexey "LexPest" Mihailov

# Execute function AFTER the project version parameters is set
function (generateVersionVarsFromGit par_PROJECT_REPO_DIR par_VERSION_CPP_IN_PATH par_VERSION_CPP_OUT_PATH)
    execute_process(COMMAND git log --pretty=format:'%H' -n 1
                    OUTPUT_VARIABLE GIT_REV
                    WORKING_DIRECTORY ${par_PROJECT_REPO_DIR}
                    ERROR_QUIET)

    # In case Git log is unavailable, don't touch anything
    if ("${GIT_REV}" STREQUAL "")
        message("[Version] Git log is unavailable, ${par_VERSION_CPP_OUT_PATH} won't be generated")
        return()
    else()
        execute_process(
            COMMAND bash -c "git diff --quiet --exit-code || echo +"
            WORKING_DIRECTORY ${par_PROJECT_REPO_DIR}
            OUTPUT_VARIABLE GIT_DIFF)
        execute_process(
            COMMAND git describe --exact-match --tags
            WORKING_DIRECTORY ${par_PROJECT_REPO_DIR}
            OUTPUT_VARIABLE GIT_TAG ERROR_QUIET)
        execute_process(
            COMMAND git rev-parse --abbrev-ref HEAD
            WORKING_DIRECTORY ${par_PROJECT_REPO_DIR}
            OUTPUT_VARIABLE GIT_BRANCH)

        string(STRIP "${GIT_REV}" GIT_REV)
        string(SUBSTRING "${GIT_REV}" 1 40 GIT_REV)
        string(STRIP "${GIT_DIFF}" GIT_DIFF)
        string(STRIP "${GIT_TAG}" GIT_TAG)
        string(STRIP "${GIT_BRANCH}" GIT_BRANCH)

        if (${GIT_DIFF} STREQUAL "+")
            set(GIT_DIF_BOOL "true")
        else()
            set(GIT_DIF_BOOL "false")
        endif()
    endif()

    if (NOT "${par_VERSION_CPP_IN_PATH}" STREQUAL "" AND
        NOT "${par_VERSION_CPP_OUT_PATH}" STREQUAL "")

        configure_file(${par_VERSION_CPP_IN_PATH}
                ${par_VERSION_CPP_OUT_PATH} @ONLY)

        message("[Version] Git version - generated successfully")
    endif()

endfunction()
