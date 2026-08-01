# =============================================================================
# Mahallu Management System (MMS) - CMake Build Configuration
# Target: Qt 6.8+, C++20, Windows (MSVC / Visual Studio 2022)
# =============================================================================
cmake_minimum_required(VERSION 3.21)

project(MMS
    VERSION 1.0.0
    DESCRIPTION "Mahallu Management System - Mosque Community Administration"
    LANGUAGES CXX
)

# -----------------------------------------------------------------------------
# Global settings
# -----------------------------------------------------------------------------
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# -----------------------------------------------------------------------------
# Find Qt 6
# -----------------------------------------------------------------------------
find_package(Qt6 6.5 REQUIRED COMPONENTS
    Core
    Gui
    Widgets
    Sql
    Charts
    PrintSupport
    Svg
    Network
    Quick
    Qml
    QuickControls2
    QuickLayouts
)

if(Qt6_FOUND)
    message(STATUS "Qt6 version: ${Qt6Core_VERSION}")
endif()

# Find OpenSSL for password hashing
find_package(OpenSSL REQUIRED)
message(STATUS "OpenSSL version: ${OPENSSL_VERSION}")

# Find zlib for backup compression
find_package(ZLIB REQUIRED)

# -----------------------------------------------------------------------------
# Application metadata
# -----------------------------------------------------------------------------
set(APP_NAME "MMS")
set(APP_VERSION "1.0.0")
set(APP_COMPANY "Mahallu Management System")

# -----------------------------------------------------------------------------
# Sources
# -----------------------------------------------------------------------------
file(GLOB MMS_CORE_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/core/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
)
file(GLOB MMS_REPO_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/repositories/*.cpp"
)
file(GLOB MMS_SVC_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/services/*.cpp"
)
set(MMS_SOURCES ${MMS_CORE_SOURCES} ${MMS_REPO_SOURCES} ${MMS_SVC_SOURCES})
file(GLOB MMS_HEADERS
    "${CMAKE_CURRENT_SOURCE_DIR}/src/core/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/repositories/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/services/*.h"
)

# Resource file (Windows only)
set(APP_RC_FILE "")
if(WIN32)
    set(APP_ICON "${CMAKE_CURRENT_SOURCE_DIR}/resources/icons/mms.ico")
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/resources/mms.rc.in"
        "${CMAKE_CURRENT_BINARY_DIR}/mms.rc"
        @ONLY
    )
    set(APP_RC_FILE "${CMAKE_CURRENT_BINARY_DIR}/mms.rc")
endif()

# -----------------------------------------------------------------------------
# Define executable
# On Windows use WIN32 (GUI subsystem); on other platforms use a normal exe.
# -----------------------------------------------------------------------------
if(WIN32)
    add_executable(${APP_NAME} WIN32
        ${MMS_SOURCES}
        ${MMS_HEADERS}
        "${CMAKE_CURRENT_SOURCE_DIR}/resources/mms.qrc"
        ${APP_RC_FILE}
    )
else()
    add_executable(${APP_NAME}
        ${MMS_SOURCES}
        ${MMS_HEADERS}
        "${CMAKE_CURRENT_SOURCE_DIR}/resources/mms.qrc"
    )
endif()

# -----------------------------------------------------------------------------
# Include directories
# -----------------------------------------------------------------------------
target_include_directories(${APP_NAME} PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/src"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/core"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/repositories"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/services"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/viewmodels"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/views"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/utils"
    ${OPENSSL_INCLUDE_DIR}
)

# -----------------------------------------------------------------------------
# Link libraries
# -----------------------------------------------------------------------------
target_link_libraries(${APP_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Sql
    Qt6::Charts
    Qt6::PrintSupport
    Qt6::Svg
    Qt6::Network
    Qt6::Quick
    Qt6::Qml
    Qt6::QuickControls2
    Qt6::QuickLayouts
    OpenSSL::Crypto
    OpenSSL::SSL
    ZLIB::ZLIB
)

# -----------------------------------------------------------------------------
# Compiler flags
# -----------------------------------------------------------------------------
if(MSVC)
    target_compile_options(${APP_NAME} PRIVATE
        /W4
        /permissive-
        /utf-8
        /EHsc
        /Zc:__cplusplus
        $<$<CONFIG:Release>:/O2>
        $<$<CONFIG:Debug>:/Zi /Od>
    )
    # Windows subsystem for GUI app
    set_target_properties(${APP_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
        LINK_FLAGS "/ENTRY:mainCRTStartup"
    )
else()
    target_compile_options(${APP_NAME} PRIVATE
        -Wall -Wextra -Wpedantic
        $<$<CONFIG:Release>:-O2>
        $<$<CONFIG:Debug>:-g -O0>
    )
endif()

# -----------------------------------------------------------------------------
# Preprocessor defines
# -----------------------------------------------------------------------------
target_compile_definitions(${APP_NAME} PRIVATE
    APP_NAME_STR="${APP_NAME}"
    APP_VERSION_STR="${APP_VERSION}"
    APP_COMPANY_STR="${APP_COMPANY}"
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=0x060000
)

# QML import paths
set_target_properties(${APP_NAME} PROPERTIES
    QT_QML_SOURCE_TREE "${CMAKE_CURRENT_SOURCE_DIR}/qml"
)

# -----------------------------------------------------------------------------
# Copy SQL files & assets to build dir
# -----------------------------------------------------------------------------
add_custom_command(TARGET ${APP_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_CURRENT_SOURCE_DIR}/sql"
        "$<TARGET_FILE_DIR:${APP_NAME}>/sql"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_CURRENT_SOURCE_DIR}/resources/templates"
        "$<TARGET_FILE_DIR:${APP_NAME}>/templates"
    COMMENT "Copying SQL scripts and templates to build directory"
)

# -----------------------------------------------------------------------------
# Install rules (portable layout)
# -----------------------------------------------------------------------------
install(TARGETS ${APP_NAME}
    RUNTIME DESTINATION bin
    BUNDLE  DESTINATION .
)

install(DIRECTORY sql/         DESTINATION sql)
install(DIRECTORY resources/   DESTINATION resources)
install(DIRECTORY docs/        DESTINATION docs)

# =============================================================================
# Tests (enabled via -DBUILD_TESTS=ON)
# =============================================================================
option(BUILD_TESTS "Build unit tests" OFF)

if(BUILD_TESTS)
    enable_testing()
    find_package(Qt6 REQUIRED COMPONENTS Test)

    # Test executable
    add_executable(mms_tests
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestMain.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestDatabase.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestAuth.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestFamily.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestMember.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestSubscription.cpp"
    )
    target_include_directories(mms_tests PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/src"
        ${OPENSSL_INCLUDE_DIR}
    )
    target_link_libraries(mms_tests PRIVATE
        Qt6::Core
        Qt6::Sql
        Qt6::Test
        OpenSSL::Crypto
        ZLIB::ZLIB
    )
    target_compile_definitions(mms_tests PRIVATE TEST_DATA_DIR="${CMAKE_CURRENT_SOURCE_DIR}/tests/data")
    add_test(NAME mms_tests COMMAND mms_tests)
endif()

# =============================================================================
# CPack installer
# =============================================================================
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
    set(CPACK_NSIS_CREATE_ICONS_EXTRA
        "CreateShortCut '$SMPROGRAMS\\\\${CPACK_PACKAGE_NAME}\\\\MMS.lnk' '$INSTDIR\\\\bin\\\\MMS.exe'"
    )
    set(CPACK_NSIS_CREATE_UNINSTALLER "$INSTDIR\\\\Uninstall.exe")
endif()

include(CPack)

# End of CMakeLists.txt
