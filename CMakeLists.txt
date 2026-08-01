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

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# Qt 6 — Core, Gui, Widgets (for QPrinter), Qml, Quick, QuickControls2, Sql, Charts, PrintSupport, Svg, Network
find_package(Qt6 6.5 REQUIRED COMPONENTS
    Core Gui Widgets Qml Quick QuickControls2 QuickLayouts
    Sql Charts PrintSupport Svg Network
)

find_package(OpenSSL REQUIRED)
find_package(ZLIB REQUIRED)

set(APP_NAME "MMS")
set(APP_VERSION "1.0.0")
set(APP_COMPANY "Mahallu Management System")

# Backend C++ sources (core + repositories + services + main)
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

# Resource file (Windows icon)
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

# Define the executable
if(WIN32)
    add_executable(${APP_NAME} WIN32
        ${MMS_SOURCES}
        ${MMS_HEADERS}
        ${APP_RC_FILE}
    )
else()
    add_executable(${APP_NAME}
        ${MMS_SOURCES}
        ${MMS_HEADERS}
    )
endif()

# =============================================================================
# Resources: icons, fonts, templates (via qt_add_resources, NOT manual .qrc)
# =============================================================================
qt_add_resources(${APP_NAME} "mms_resources"
    PREFIX "/"
    FILES
        resources/icons/mms.svg
        resources/icons/mms.png
        resources/icons/mms_white.png
        resources/icons/mms_icon.png
        resources/icons/mms.ico
)

qt_add_resources(${APP_NAME} "fonts_resources"
    PREFIX "/fonts"
    FILES
        resources/fonts/NotoSans-Regular.ttf
        resources/fonts/NotoSans-Bold.ttf
        resources/fonts/AnekMalayalam-Regular.ttf
        resources/fonts/AnekMalayalam-Medium.ttf
        resources/fonts/AnekMalayalam-SemiBold.ttf
        resources/fonts/AnekMalayalam-Bold.ttf
        resources/fonts/Poppins-Regular.ttf
        resources/fonts/Poppins-Medium.ttf
        resources/fonts/Poppins-SemiBold.ttf
        resources/fonts/Poppins-Bold.ttf
        resources/fonts/Gayathri-Regular.ttf
        resources/fonts/Gayathri-Bold.ttf
)

qt_add_resources(${APP_NAME} "icons_resources"
    PREFIX "/icons"
    FILES
        resources/icons/svg/dashboard.svg
        resources/icons/svg/families.svg
        resources/icons/svg/members.svg
        resources/icons/svg/subscriptions.svg
        resources/icons/svg/donations.svg
        resources/icons/svg/accounting.svg
        resources/icons/svg/marriage.svg
        resources/icons/svg/death.svg
        resources/icons/svg/welfare.svg
        resources/icons/svg/certificates.svg
        resources/icons/svg/reports.svg
        resources/icons/svg/settings.svg
        resources/icons/svg/users.svg
        resources/icons/svg/audit.svg
        resources/icons/svg/backup.svg
        resources/icons/svg/search.svg
        resources/icons/svg/bell.svg
        resources/icons/svg/moon.svg
        resources/icons/svg/sun.svg
        resources/icons/svg/refresh.svg
        resources/icons/svg/chevron-down.svg
        resources/icons/svg/chevron-left.svg
        resources/icons/svg/chevron-right.svg
        resources/icons/svg/plus.svg
        resources/icons/svg/edit.svg
        resources/icons/svg/trash.svg
        resources/icons/svg/print.svg
        resources/icons/svg/download.svg
        resources/icons/svg/archive.svg
        resources/icons/svg/check.svg
        resources/icons/svg/alert.svg
        resources/icons/svg/dollar.svg
        resources/icons/svg/trending-up.svg
        resources/icons/svg/trending-down.svg
        resources/icons/svg/menu.svg
        resources/icons/svg/user.svg
        resources/icons/svg/log-out.svg
        resources/icons/svg/key.svg
)

qt_add_resources(${APP_NAME} "templates_resources"
    PREFIX "/templates"
    FILES
        resources/templates/membership_cert.html
        resources/templates/residence_cert.html
        resources/templates/marriage_cert.html
        resources/templates/death_cert.html
)

# =============================================================================
# THE KEY FIX: Use qt_add_qml_module (Qt 6 proper way to register QML files)
# This compiles QML files into the binary and registers them at the correct
# qrc: path. No manual .qrc entries needed for QML.
# =============================================================================
qt_add_qml_module(${APP_NAME}
    URI "qml"
    VERSION 1.0
    RESOURCE_PREFIX "/"
    QML_FILES
        "qml/main.qml"
        "qml/components/SquircleButton.qml"
        "qml/components/StatCard.qml"
        "qml/components/Pill.qml"
        "qml/views/DashboardView.qml"
)

target_include_directories(${APP_NAME} PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/src"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/core"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/repositories"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/services"
    ${OPENSSL_INCLUDE_DIR}
)

target_link_libraries(${APP_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::QuickLayouts
    Qt6::Sql
    Qt6::Charts
    Qt6::PrintSupport
    Qt6::Svg
    Qt6::Network
    OpenSSL::Crypto
    OpenSSL::SSL
    ZLIB::ZLIB
)

if(MSVC)
    target_compile_options(${APP_NAME} PRIVATE
        /W4 /permissive- /utf-8 /EHsc /Zc:__cplusplus
        $<$<CONFIG:Release>:/O2>
    )
    set_target_properties(${APP_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
        LINK_FLAGS "/ENTRY:mainCRTStartup"
    )
else()
    target_compile_options(${APP_NAME} PRIVATE
        -Wall -Wextra -Wpedantic
        $<$<CONFIG:Release>:-O2>
    )
endif()

target_compile_definitions(${APP_NAME} PRIVATE
    APP_NAME_STR="${APP_NAME}"
    APP_VERSION_STR="${APP_VERSION}"
    APP_COMPANY_STR="${APP_COMPANY}"
    QT_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=0x060000
)

# Copy SQL + templates to build dir
add_custom_command(TARGET ${APP_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_CURRENT_SOURCE_DIR}/sql"
        "$<TARGET_FILE_DIR:${APP_NAME}>/sql"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_CURRENT_SOURCE_DIR}/resources/templates"
        "$<TARGET_FILE_DIR:${APP_NAME}>/templates"
    COMMENT "Copying SQL scripts and templates to build directory"
)
