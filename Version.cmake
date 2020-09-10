# Ignix-CMake-Submodules
# Version.cmake
# Author: Alexey "LexPest" Mihailov

function (generateVersionVarsFromGit, par_PROJECT_REPO_DIR, par_VERSION_CPP_PATH){
    execute_process(COMMAND git log --pretty=format:'%h' -n 1
                    OUTPUT_VARIABLE GIT_REV
                    WORKING_DIRECTORY ${par_PROJECT_REPO_DIR}
                    ERROR_QUIET)

    # In case Git log is unavailable, don't touch anything
    if ("${GIT_REV}" STREQUAL "")
        set(GIT_REV "" PARENT_SCOPE)
        set(GIT_DIFF "" PARENT_SCOPE)
        set(GIT_TAG "" PARENT_SCOPE)
        set(GIT_BRANCH "" PARENT_SCOPE)
    else()
        execute_process(
            COMMAND bash -c "${par_PROJECT_REPO_DIR}git diff --quiet --exit-code || echo +"
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
        string(SUBSTRING "${GIT_REV}" 1 12 GIT_REV)
        string(STRIP "${GIT_DIFF}" GIT_DIFF)
        string(STRIP "${GIT_TAG}" GIT_TAG)
        string(STRIP "${GIT_BRANCH}" GIT_BRANCH)
    endif()

    set(VERSION "const char* GIT_REV=\"${GIT_REV}${GIT_DIFF}\";
    const char* GIT_TAG=\"${GIT_TAG}\";
    const char* GIT_BRANCH=\"${GIT_BRANCH}\";" PARENT_DIRECTORY)

    if NOT ("${par_VERSION_CPP_PATH}" STREQUAL "")

        if(EXISTS ${par_VERSION_CPP_PATH})
            file(READ ${par_VERSION_CPP_PATH} VERSION_)
        else()
            set(VERSION_ "")
        endif()

        if (NOT "${VERSION}" STREQUAL "${VERSION_}")
            file(WRITE ${par_VERSION_CPP_PATH}"${VERSION}")
        endif()

    endif()
}