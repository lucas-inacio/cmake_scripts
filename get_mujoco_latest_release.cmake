# ###########################################################
# Find the proper mujoco binary release for the host platform
# ###########################################################

function(get_mujoco_release_url)
    # Query github api for latest release and save the result on latest.json
    file(DOWNLOAD https://api.github.com/repos/deepmind/mujoco/releases/latest ${CMAKE_BINARY_DIR}/latest.json)
    file(READ ${CMAKE_BINARY_DIR}/latest.json RELEASE_INFO_JSON)

    # Get the assets list and it's length - 1
    string(JSON ASSETS_LIST GET ${RELEASE_INFO_JSON} assets)
    string(JSON ASSETS_LENGTH LENGTH ${ASSETS_LIST})
    math(EXPR ASSETS_LENGTH "${ASSETS_LENGTH} - 1")

    # The OS we're getting the release for
    string(TOLOWER ${CMAKE_HOST_SYSTEM_NAME} TARGET_OS_NAME)

    # To build the package name accordingly
    if (TARGET_OS_NAME STREQUAL "windows")
        set(TARGET_ARCH "x86_64")
    elseif(TARGET_OS_NAME STREQUAL "linux")
        set(TARGET_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR})
    elseif(TARGET_OS_NAME STREQUAL "macos")
        set(TARGET_ARCH "universal2")
    endif()


    # Iterate through the urls and find the proper release
    foreach(i RANGE ${ASSETS_LENGTH})
        string(JSON RELEASE_OBJ GET ${ASSETS_LIST} ${i})
        string(JSON RELEASE_URL_CANDIDATE GET ${RELEASE_OBJ} browser_download_url)
        string(REGEX MATCH ".*${TARGET_OS_NAME}-${TARGET_ARCH}(.tar.gz|.zip|.dmg)$" MUJOCO_RELEASE_URL ${RELEASE_URL_CANDIDATE})
        if (MUJOCO_RELEASE_URL)
            break()
        endif()
    endforeach()
    set(MUJOCO_RELEASE_URL ${MUJOCO_RELEASE_URL} PARENT_SCOPE)
endfunction()

function(get_mujoco_latest_release)
    get_mujoco_release_url()
    if(NOT MUJOCO_RELEASE_URL)
        message(FATAL_ERROR "Could not find a proper mujoco release for the current platform")
    endif()
    file(DOWNLOAD ${MUJOCO_RELEASE_URL} ${CMAKE_BINARY_DIR}/mujoco)
    # Extract to source directory
    file(ARCHIVE_EXTRACT INPUT ${CMAKE_BINARY_DIR}/mujoco DESTINATION ${CMAKE_SOURCE_DIR}/external/mujoco)
endfunction()