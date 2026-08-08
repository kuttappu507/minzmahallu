# =============================================================================
# Mahallu Management System (MMS) - CMake Build Configuration
# Target: Qt 6.8+, C++20, Windows (MSVC / Visual Studio 2022)
#
# This is a QML-only application. Legacy Qt Widgets code has been removed.
# The single production executable is mms_app.
# =============================================================================
cmake_minimum_required(VERSION 3.21)

project(MMS
    VERSION 1.0.0
    DESCRIPTION "Mahallu Management System - Mosque Community Administration"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

find_package(Qt6 6.5 COMPONENTS
    Core Gui Widgets Qml Quick QuickControls2 QuickLayouts
    Sql PrintSupport Svg Network
)
message(STATUS "Qt6 version: ${Qt6Core_VERSION}")

find_package(OpenSSL REQUIRED)
message(STATUS "OpenSSL version: ${OPENSSL_VERSION}")
find_package(ZLIB REQUIRED)

set(APP_NAME "MMS")
set(APP_VERSION "1.0.0")
set(APP_COMPANY "Mahallu Management System")

file(GLOB_RECURSE APP_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
list(FILTER APP_SOURCES EXCLUDE REGEX "app_main\\.cpp$")
file(GLOB_RECURSE APP_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h")

set(APP_RC_FILE "")
if(WIN32)
    set(APP_RC_FILE "${CMAKE_CURRENT_SOURCE_DIR}/app.rc")
endif()

if(Qt6Qml_FOUND AND Qt6Quick_FOUND AND Qt6QuickControls2_FOUND AND Qt6QuickLayouts_FOUND)
    message(STATUS "MMS App: building mms_app")

    add_executable(mms_app
        ${APP_SOURCES}
        ${APP_HEADERS}
        "${CMAKE_CURRENT_SOURCE_DIR}/src/app_main.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/app.qrc"
        ${APP_RC_FILE}
    )

    target_include_directories(mms_app PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/src"
        "${CMAKE_CURRENT_SOURCE_DIR}/src/core"
        "${CMAKE_CURRENT_SOURCE_DIR}/src/models"
        "${CMAKE_CURRENT_SOURCE_DIR}/src/repositories"
        "${CMAKE_CURRENT_SOURCE_DIR}/src/services"
        ${OPENSSL_INCLUDE_DIR}
    )

    target_link_libraries(mms_app PRIVATE
        Qt6::Core Qt6::Gui Qt6::Widgets Qt6::Qml Qt6::Quick Qt6::QuickControls2
        Qt6::QuickLayouts Qt6::Sql Qt6::PrintSupport Qt6::Svg Qt6::Network
        OpenSSL::Crypto OpenSSL::SSL ZLIB::ZLIB
    )

    target_compile_definitions(mms_app PRIVATE
        APP_NAME_STR="${APP_NAME}"
        APP_VERSION_STR="${APP_VERSION}"
        APP_COMPANY_STR="${APP_COMPANY}"
        QT_DEPRECATED_WARNINGS
        QT_DISABLE_DEPRECATED_BEFORE=0x060000
    )

    if(MSVC)
        target_compile_options(mms_app PRIVATE
            /W4 /permissive- /utf-8 /EHsc /Zc:__cplusplus
            $<$<CONFIG:Release>:/O2>
            $<$<CONFIG:Debug>:/Zi /Od>
        )
        set_target_properties(mms_app PROPERTIES
            WIN32_EXECUTABLE TRUE
            LINK_FLAGS "/ENTRY:mainCRTStartup"
        )
        # Let the linker embed the single authoritative Per-Monitor-V2
        # manifest. app.rc intentionally contains no RT_MANIFEST resource,
        # avoiding duplicate-manifest linker errors.
        target_link_options(mms_app PRIVATE
            "/MANIFEST:EMBED"
            "/MANIFESTINPUT:${CMAKE_CURRENT_SOURCE_DIR}/app.manifest"
        )
    else()
        target_compile_options(mms_app PRIVATE
            -Wall -Wextra -Wpedantic
            $<$<CONFIG:Release>:-O2>
            $<$<CONFIG:Debug>:-g -O0>
        )
    endif()

    add_custom_command(TARGET mms_app POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${CMAKE_CURRENT_SOURCE_DIR}/sql"
            "$<TARGET_FILE_DIR:mms_app>/sql"
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${CMAKE_CURRENT_SOURCE_DIR}/resources/templates"
            "$<TARGET_FILE_DIR:mms_app>/templates"
        COMMENT "Copying SQL scripts and templates to build directory"
    )

    install(TARGETS mms_app RUNTIME DESTINATION bin BUNDLE DESTINATION .)
    install(DIRECTORY sql/ DESTINATION sql)
    install(DIRECTORY resources/ DESTINATION resources)
    install(DIRECTORY docs/ DESTINATION docs)
else()
    message(FATAL_ERROR "Qt6 QML modules not found — cannot build mms_app")
endif()

option(BUILD_TESTS "Build unit tests" OFF)
if(BUILD_TESTS)
    enable_testing()
    find_package(Qt6 REQUIRED COMPONENTS Test)
    add_executable(mms_tests
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestMain.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestDatabase.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestAuth.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestFamily.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestMember.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestSubscription.cpp"
    )
    target_include_directories(mms_tests PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src" ${OPENSSL_INCLUDE_DIR})
    target_link_libraries(mms_tests PRIVATE Qt6::Core Qt6::Sql Qt6::Test OpenSSL::Crypto ZLIB::ZLIB)
    target_compile_definitions(mms_tests PRIVATE TEST_DATA_DIR="${CMAKE_CURRENT_SOURCE_DIR}/tests/data")
    add_test(NAME mms_tests COMMAND mms_tests)
endif()

set(CPACK_PACKAGE_NAME "Mahallu Management System")
set(CPACK_PACKAGE_VENDOR "MMS Project")
set(CPACK_PACKAGE_VERSION "${APP_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Mosque Community Administration System")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "MMS")
if(WIN32)
    set(CPACK_GENERATOR "NSIS;ZIP")
    set(CPACK_NSIS_DISPLAY_NAME "Mahallu Management System")
    set(CPACK_NSIS_INSTALL_ROOT "$LOCALAPPDATA")
endif()
include(CPack)
