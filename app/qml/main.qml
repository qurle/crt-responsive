/*******************************************************************************
* Copyright (c) 2013-2021 "Filippo Scognamiglio"
* https://github.com/Swordfish90/cool-retro-term
*
* This file is part of cool-retro-term.
*
* cool-retro-term is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************/
import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 2.3

import "menus"

ApplicationWindow {
    id: terminalWindow

    width: (appSettings.width > 0 ? appSettings.width : 1024)
    height: (appSettings.height > 0 ? appSettings.height : 768)

    property bool initialized: false

    // Save window properties automatically
   onXChanged: {
        if (initialized) {
            appSettings.x = x
        }
    }
    onYChanged: {
        if (initialized) {
            appSettings.y = y
        }
    }
    onWidthChanged: {
        if (initialized) {
            appSettings.width = width
        }
    }
    onHeightChanged: {
        if (initialized) {
            appSettings.height = height
        }
    }

    // Load saved window geometry and show the window
    Component.onCompleted: {
        x = appSettings.x
        y = appSettings.y
        width = appSettings.width
        height = appSettings.height

        visible = true
    }

    minimumWidth: 320
    minimumHeight: 240

    visible: false

    property bool fullscreen: appSettings.fullscreen
    onFullscreenChanged: visibility = (fullscreen ? Window.FullScreen : Window.Windowed)

    menuBar: qtquickMenuLoader.item

    Connections {
        target: appSettings

        function onInitializedSettings() {
            x = appSettings.x
            y = appSettings.y
            width = appSettings.width
            height = appSettings.height
            initialized = true
        }
    }

    Loader {
        id: qtquickMenuLoader
        active: !appSettings.isMacOS && appSettings.showMenubar
        sourceComponent: WindowMenu { }
    }

    Loader {
        id: globalMenuLoader
        active: appSettings.isMacOS
        sourceComponent: OSXMenu { }
    }

    property string wintitle: appSettings.wintitle

    color: "#00000000"

    title: terminalContainer.title || qsTr(appSettings.wintitle)

    Action {
        id: showMenubarAction
        text: qsTr("Show Menubar")
        enabled: !appSettings.isMacOS
        shortcut: "Ctrl+Shift+M"
        checkable: true
        checked: appSettings.showMenubar
        onTriggered: appSettings.showMenubar = !appSettings.showMenubar
    }
    Action {
        id: fullscreenAction
        text: qsTr("Fullscreen")
        enabled: !appSettings.isMacOS
        shortcut: "Alt+F11"
        onTriggered: appSettings.fullscreen = !appSettings.fullscreen
        checkable: true
        checked: appSettings.fullscreen
    }
    Action {
        id: quitAction
        text: qsTr("Quit")
        shortcut: "Ctrl+Shift+Q"
        // onTriggered: Qt.quit()
        onTriggered: terminalWindow.close()
    }
    Action {
        id: showsettingsAction
        text: qsTr("Settings")
        onTriggered: {
            settingswindow.show()
            settingswindow.requestActivate()
            settingswindow.raise()
        }
    }
    Action {
        id: copyAction
        text: qsTr("Copy")
        shortcut: "Ctrl+Shift+C"
    }
    Action {
        id: pasteAction
        text: qsTr("Paste")
        shortcut: "Ctrl+Shift+V"
    }
    Action {
        id: zoomIn
        text: qsTr("Zoom In")
        shortcut: "Ctrl++"
        onTriggered: appSettings.incrementScaling()
    }
    Action {
        id: zoomOut
        text: qsTr("Zoom Out")
        shortcut: "Ctrl+-"
        onTriggered: appSettings.decrementScaling()
    }
    Action {
        id: showAboutAction
        text: qsTr("About")
        onTriggered: {
            aboutDialog.show()
            aboutDialog.requestActivate()
            aboutDialog.raise()
        }
    }
    ApplicationSettings {
        id: appSettings
    }
    TerminalContainer {
        id: terminalContainer
        width: parent.width
        height: (parent.height + Math.abs(y))
    }
    SettingsWindow {
        id: settingswindow
        visible: false
    }
    AboutDialog {
        id: aboutDialog
        visible: false
    }
    Loader {
        anchors.centerIn: parent
        active: appSettings.showTerminalSize
        sourceComponent: SizeOverlay {
            z: 3
            terminalSize: terminalContainer.terminalSize
        }
    }
    onClosing: {
        // Save window geometry as per Qt recommendations
        appSettings.x = x
        appSettings.y = y
        appSettings.width = width
        appSettings.height = height

        // OSX Since we are currently supporting only one window
        // quit the application when it is closed.
        if (appSettings.isMacOS)
            Qt.quit()
    }
}
