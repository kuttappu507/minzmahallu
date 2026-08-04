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
# Find Qt 6 — widgets components
# Skipped entirely when MMS_QML_ONLY=ON (for QML-only dev builds)
# -----------------------------------------------------------------------------
option(MMS_QML_ONLY "Build ONLY the QML smoke test (skip widgets MMS target)" OFF)

set(MMS_WIDGETS_READY OFF)
if(NOT MMS_QML_ONLY)
    find_package(Qt6 6.5 COMPONENTS
        Core
        Gui
        Widgets
        Sql
        Charts
        PrintSupport
        Svg
        Network
    )

    if(Qt6_FOUND)
        message(STATUS "Qt6 version: ${Qt6Core_VERSION}")
    endif()

    if(Qt6Core_FOUND AND Qt6Gui_FOUND AND Qt6Widgets_FOUND AND Qt6Sql_FOUND
       AND Qt6Charts_FOUND AND Qt6PrintSupport_FOUND AND Qt6Svg_FOUND
       AND Qt6Network_FOUND)
        set(MMS_WIDGETS_READY ON)
        message(STATUS "Widgets MMS target: all Qt6 modules found — will build")
    else()
        foreach(_mod Core Gui Widgets Sql Charts PrintSupport Svg Network)
            if(NOT Qt6${_mod}_FOUND)
                message(STATUS "  Qt6${_mod}: NOT FOUND")
            endif()
        endforeach()
        message(STATUS "Widgets MMS target: skipping (some Qt6 modules absent)")
    endif()
else()
    message(STATUS "MMS_QML_ONLY=ON — skipping widgets find_package entirely")
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
file(GLOB_RECURSE MMS_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
)
# Exclude the QML smoke test launcher — it's a separate executable
list(FILTER MMS_SOURCES EXCLUDE REGEX "qml_smoke_main\.cpp$")
list(FILTER MMS_SOURCES EXCLUDE REGEX "design_preview_main\.cpp$")
list(FILTER MMS_SOURCES EXCLUDE REGEX "dashboard_v2_main\.cpp$")
list(FILTER MMS_SOURCES EXCLUDE REGEX "dashboard_v3_main\.cpp$")
file(GLOB_RECURSE MMS_HEADERS
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h"
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
# Define executable (guarded — only when all widgets deps are available)
# -----------------------------------------------------------------------------
if(MMS_WIDGETS_READY)
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

endif() # MMS_WIDGETS_READY

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
# QML Smoke Test (Phase 2 — minimal Qt Quick verification)
#
# This is a SEPARATE executable that only verifies Qt Quick/QML loads.
# It does NOT replace the widgets MMS application.
# It does NOT link any backend code.
# It does NOT affect the MMS (widgets) target in any way.
#
# The existing MMS widgets target above is UNCHANGED.
# =============================================================================
option(MMS_BUILD_QML_SMOKE "Build the Phase 2 QML smoke test executable" ON)

if(MMS_BUILD_QML_SMOKE)
    find_package(Qt6 6.5 COMPONENTS Qml Quick QuickControls2 QuickLayouts)

    if(Qt6Qml_FOUND AND Qt6Quick_FOUND AND Qt6QuickControls2_FOUND AND Qt6QuickLayouts_FOUND)
        message(STATUS "QML smoke test: Qt6 Qml/Quick/QuickControls2/QuickLayouts found — building mms_qml_smoke")

        add_executable(mms_qml_smoke
            "${CMAKE_CURRENT_SOURCE_DIR}/src/qml_smoke_main.cpp"
            "${CMAKE_CURRENT_SOURCE_DIR}/qml_smoke.qrc"
        )

        target_link_libraries(mms_qml_smoke PRIVATE
            Qt6::Core
            Qt6::Gui
            Qt6::Qml
            Qt6::Quick
            Qt6::QuickControls2
            Qt6::QuickLayouts
        )

        if(WIN32)
            set_target_properties(mms_qml_smoke PROPERTIES
                WIN32_EXECUTABLE TRUE
                LINK_FLAGS "/ENTRY:mainCRTStartup"
            )
        endif()
    else()
        message(STATUS "QML smoke test: Qt6 Qml/Quick modules not found — skipping mms_qml_smoke")
    endif()
endif()

# =============================================================================
# Design Preview (Phase 3 — visual design system evaluation)
#
# Separate executable that loads DesignPreview.qml showing all design system
# components (Theme, AppButton, IconButton, AppTextField, AppComboBox).
# No backend integration — purely visual.
# Does NOT affect the MMS widgets application.
# =============================================================================
option(MMS_BUILD_DESIGN_PREVIEW "Build the Phase 3 design preview executable" ON)

if(MMS_BUILD_DESIGN_PREVIEW)
    find_package(Qt6 6.5 COMPONENTS Qml Quick QuickControls2 QuickLayouts)

    if(Qt6Qml_FOUND AND Qt6Quick_FOUND AND Qt6QuickControls2_FOUND AND Qt6QuickLayouts_FOUND)
        message(STATUS "Design preview: Qt6 Qml/Quick found — building mms_design_preview")

        add_executable(mms_design_preview
            "${CMAKE_CURRENT_SOURCE_DIR}/src/design_preview_main.cpp"
            "${CMAKE_CURRENT_SOURCE_DIR}/design_preview.qrc"
        )

        target_link_libraries(mms_design_preview PRIVATE
            Qt6::Core
            Qt6::Gui
            Qt6::Qml
            Qt6::Quick
            Qt6::QuickControls2
            Qt6::QuickLayouts
        )

        if(WIN32)
            set_target_properties(mms_design_preview PROPERTIES
                WIN32_EXECUTABLE TRUE
                LINK_FLAGS "/ENTRY:mainCRTStartup"
            )
        endif()
    else()
        message(STATUS "Design preview: Qt6 Qml/Quick modules not found — skipping mms_design_preview")
    endif()
endif()

# =============================================================================
# DashboardV2 Preview (Phase 3.3 — production dashboard screen evaluation)
#
# Separate executable that opens directly to DashboardV2.qml.
# Only the sidebar + topbar + KPI grid + activities + events.
# No backend, no other screens, no component showcase.
# =============================================================================
option(MMS_BUILD_DASHBOARD_V2 "Build the DashboardV2 preview executable" ON)

if(MMS_BUILD_DASHBOARD_V2)
    find_package(Qt6 6.5 COMPONENTS Qml Quick QuickControls2 QuickLayouts)

    if(Qt6Qml_FOUND AND Qt6Quick_FOUND AND Qt6QuickControls2_FOUND AND Qt6QuickLayouts_FOUND)
        message(STATUS "DashboardV2: Qt6 Qml/Quick found — building mms_dashboard_v2")

        add_executable(mms_dashboard_v2
            "${CMAKE_CURRENT_SOURCE_DIR}/src/dashboard_v2_main.cpp"
            "${CMAKE_CURRENT_SOURCE_DIR}/dashboard_v2.qrc"
        )

        target_link_libraries(mms_dashboard_v2 PRIVATE
            Qt6::Core
            Qt6::Gui
            Qt6::Qml
            Qt6::Quick
            Qt6::QuickControls2
            Qt6::QuickLayouts
        )

        if(WIN32)
            set_target_properties(mms_dashboard_v2 PROPERTIES
                WIN32_EXECUTABLE TRUE
                LINK_FLAGS "/ENTRY:mainCRTStartup"
            )
        endif()
    else()
        message(STATUS "DashboardV2: Qt6 Qml/Quick modules not found — skipping mms_dashboard_v2")
    endif()
endif()


# =============================================================================
# DashboardV3 Preview (faithful HTML→QML visual port)
# =============================================================================
option(MMS_BUILD_DASHBOARD_V3 "Build the DashboardV3 preview executable" ON)

if(MMS_BUILD_DASHBOARD_V3)
    find_package(Qt6 6.5 COMPONENTS Qml Quick QuickControls2 QuickLayouts)

    if(Qt6Qml_FOUND AND Qt6Quick_FOUND AND Qt6QuickControls2_FOUND AND Qt6QuickLayouts_FOUND)
        message(STATUS "DashboardV3: building mms_dashboard_v3")

        add_executable(mms_dashboard_v3
            "${CMAKE_CURRENT_SOURCE_DIR}/src/dashboard_v3_main.cpp"
            "${CMAKE_CURRENT_SOURCE_DIR}/dashboard_v3.qrc"
        )

        target_link_libraries(mms_dashboard_v3 PRIVATE
            Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::QuickLayouts
        )

        if(WIN32)
            set_target_properties(mms_dashboard_v3 PROPERTIES
                WIN32_EXECUTABLE TRUE
                LINK_FLAGS "/ENTRY:mainCRTStartup"
            )
        endif()
    else()
        message(STATUS "DashboardV3: Qt6 Qml/Quick modules not found - skipping")
    endif()
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
