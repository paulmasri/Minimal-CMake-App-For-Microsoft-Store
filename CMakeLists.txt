cmake_minimum_required(VERSION 3.24)

set(APP_TARGET CMakeAppForMSStore)
set(APP_NAME "Minimal CMake App for Microsoft Store")

project(${APP_TARGET} VERSION 1.0.0 LANGUAGES CXX)

add_executable(${APP_TARGET}
    main.cpp
)

set_target_properties(${APP_TARGET} PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

install(TARGETS ${APP_TARGET}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

include(InstallRequiredSystemLibraries)

set(APPX_PUBLISHER_ID "CMake.Experiment.Certificate")
set(APPX_PACKAGE_PRODUCT_NAME "CMakeExperiment.${APP_TARGET}")
set(APPX_PACKAGE_PRODUCT_DISPLAY_NAME "${APP_NAME}")
set(APPX_PACKAGE_PRODUCT_DESCRIPTION "Minimal test app for building projects for the Microsoft Store in CMake")
set(APPX_PACKAGE_PRODUCT_VERSION "${PROJECT_VERSION}.0")
set(APPX_PACKAGE_PRODUCT_BACKGROUND_COLOR "transparent")
set(APPX_PACKAGE_PUBLISHER_ID "CN=${APPX_PUBLISHER_ID}")
set(APPX_PACKAGE_PUBLISHER_DISPLAY_NAME "Publisher")
set(APPX_PACKAGE_MIN_VERSION "10.0.19041.0")
set(APPX_PACKAGE_MAX_VERSION_TESTED "10.0.19041.0")
set(APPX_PACKAGE_EXECUTABLE "${CMAKE_INSTALL_BINDIR}/${APP_TARGET}.exe")
set(APPX_PACKAGES_PREFIX "packages")
set(APPX_PACKAGE_NAME_X64 "${APP_TARGET}_x64.appx")
set(APPX_BUNDLE_NAME "${APP_TARGET}.appxbundle")

configure_file(AppxManifest.xml.in "${CMAKE_CURRENT_BINARY_DIR}/AppxManifest.xml")
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/AppxManifest.xml"
    DESTINATION "${CMAKE_INSTALL_PREFIX}"
)
install(
    DIRECTORY Assets
    DESTINATION "${CMAKE_INSTALL_PREFIX}"
)

option(APP_PACKAGE_SIGN "Enable packaging and signing of the app" OFF)
option(APP_BUNDLE "Enable bundling .appx package as .appxbundle (bundle gets signed instead of package)" OFF)

if(APP_PACKAGE_SIGN)
    if(APP_BUNDLE)
        set(package_bundle_message "packaging, bundling, and signing (the bundle)")
    else()
        set(package_bundle_message "packaging and signing (the package)")
    endif()
    message(STATUS "Starting ${package_bundle_message}...")


    if(NOT DEFINED PFX_SIGNATURE_KEY)
        message(FATAL_ERROR "PFX_SIGNATURE_KEY is not defined. Make sure to set it to the path of your PFX file.")
    endif()

    if(NOT DEFINED PFX_PASSWORD)
        message(FATAL_ERROR "PFX_PASSWORD is not defined. Make sure to set it to the password of your PFX file.")
    endif()

    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/${PFX_SIGNATURE_KEY}")
        message(FATAL_ERROR
            "Make sure to point to the right certificate PFX file for signing.")
    endif()

    set(makeappx_pack_x64_command "makeappx pack /d \"${CMAKE_INSTALL_PREFIX}\" /p \"${CMAKE_BINARY_DIR}/${APPX_PACKAGES_PREFIX}/${APPX_PACKAGE_NAME_X64}\"")
    set(makeappx_pack_x64_execute_process "execute_process(COMMAND ${makeappx_pack_x64_command})")

    if(APP_BUNDLE)
        set(makeappx_bundle_command "makeappx bundle /d \"${CMAKE_BINARY_DIR}/${APPX_PACKAGES_PREFIX}\" /p \"${CMAKE_BINARY_DIR}/${APPX_BUNDLE_NAME}\"")
        set(makeappx_bundle_execute_process "execute_process(COMMAND ${makeappx_bundle_command})")

        set(signtool_command "signtool sign /n \"${APPX_PUBLISHER_ID}\" /v /fd SHA256 /f \"${CMAKE_SOURCE_DIR}/${PFX_SIGNATURE_KEY}\" /p \"${PFX_PASSWORD}\" \"${CMAKE_BINARY_DIR}/${APPX_BUNDLE_NAME}\"")
        set(signtool_execute_process "execute_process(COMMAND ${signtool_command})")
    else()
        set(makeappx_bundle_execute_process "")

        set(signtool_command "signtool sign /n \"${APPX_PUBLISHER_ID}\" /v /fd SHA256 /f \"${CMAKE_SOURCE_DIR}/${PFX_SIGNATURE_KEY}\" /p \"${PFX_PASSWORD}\" \"${CMAKE_BINARY_DIR}/${APPX_PACKAGES_PREFIX}/${APPX_PACKAGE_NAME_X64}\"")
        set(signtool_execute_process "execute_process(COMMAND ${signtool_command})")
    endif()

    install(CODE "
        file(REMOVE_RECURSE \"${CMAKE_BINARY_DIR}/${APPX_PACKAGES_PREFIX}\")
        file(REMOVE \"${CMAKE_BINARY_DIR}/${APPX_BUNDLE_NAME}\")
        ${makeappx_pack_x64_execute_process}
        ${makeappx_bundle_execute_process}
        ${signtool_execute_process}
        ")

    message(STATUS "Done ${package_bundle_message}")
endif()
