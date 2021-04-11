cmake_minimum_required(VERSION 3.14)

project(statusbar LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 CONFIG REQUIRED Widgets DBus X11Extras Concurrent Svg LinguistTools QuickControls2)
find_package(KF5WindowSystem REQUIRED)
find_package(dbusmenu-qt5 REQUIRED)
find_package(FishUI REQUIRED)

set(SRCS
    src/main.cpp
    src/statusbar.cpp
    src/controlcenterdialog.cpp
    src/brightness.cpp
    src/battery.cpp
    src/appearance.cpp
    src/volume.cpp
    src/processprovider.cpp
    src/activity.cpp
    src/capplications.cpp

    src/systemtray/statusnotifieritemsource.cpp
    src/systemtray/systemtraytypes.cpp
    src/systemtray/systemtraytypedefs.h
    src/systemtray/systemtraymodel.cpp
    src/systemtray/statusnotifierwatcher.cpp

    qml.qrc
)

set(statusnotifierwatcher_xml src/systemtray/org.kde.StatusNotifierWatcher.xml)
qt5_add_dbus_interface(SRCS ${statusnotifierwatcher_xml} statusnotifierwatcher_interface)
qt5_add_dbus_interface(SRCS src/systemtray/org.freedesktop.DBus.Properties.xml dbusproperties)

set(statusnotifieritem_xml src/systemtray/org.kde.StatusNotifierItem.xml)
set_source_files_properties(${statusnotifieritem_xml} PROPERTIES
   NO_NAMESPACE false
   INCLUDE "src/systemtray/systemtraytypes.h"
   CLASSNAME OrgKdeStatusNotifierItem
)
qt5_add_dbus_interface(SRCS ${statusnotifieritem_xml} statusnotifieritem_interface)

qt5_add_dbus_adaptor(SRCS src/systemtray/org.kde.StatusNotifierWatcher.xml
                     src/systemtray/statusnotifierwatcher.h StatusNotifierWatcher)

add_executable(cutefish-statusbar ${SRCS})

target_link_libraries(cutefish-statusbar
  PRIVATE
  Qt5::Core
  Qt5::Widgets
  Qt5::Quick
  Qt5::QuickControls2
  Qt5::X11Extras
  Qt5::Concurrent
  Qt5::DBus
  Qt5::Svg

  FishUI

  KF5::WindowSystem
  dbusmenu-qt5
)

file(GLOB TS_FILES translations/*.ts)
qt5_create_translation(QM_FILES ${TS_FILES})
add_custom_target(translations DEPENDS ${QM_FILES} SOURCES ${TS_FILES})
add_dependencies(cutefish-statusbar translations)

install(TARGETS cutefish-statusbar RUNTIME DESTINATION /usr/bin)
install(FILES ${QM_FILES} DESTINATION /usr/share/cutefish-statusbar/translations)
