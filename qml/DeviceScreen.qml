/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2020 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
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
 *
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

import QtQuick 2.9
import QtQuick.Controls 2.2

import ThemeEngine 1.0

Item {
    id: deviceScreenSensor
    width: 450
    height: 700

    property var myDevice: currentDevice

    Connections {
        target: myDevice
        function onStatusUpdated() {
            rectangleDeviceData.updateHeader()
        }
        function onSensorUpdated() {
            rectangleDeviceData.updateHeader()
            rectangleDeviceLimits.updateHeader()
        }
        function onDataUpdated() {
            rectangleDeviceData.updateData()
            rectangleDeviceHistory.updateData()
        }
        function onLimitsUpdated() {
            rectangleDeviceData.updateData()
        }
    }

    Connections {
        target: Theme
        function onCurrentThemeChanged() {
            rectangleDeviceData.updateHeader()
            rectangleDeviceHistory.updateHeader()
            rectangleDeviceHistory.updateColors()
            rectangleDeviceLimits.updateHeader()
        }
    }

    Connections {
        target: appHeader
        // desktop only
        function onDeviceDataButtonClicked() {
            appHeader.setActiveDeviceData()
            sensorPages.currentIndex = 0
        }
        function onDeviceHistoryButtonClicked() {
            appHeader.setActiveDeviceHistory()
            sensorPages.currentIndex = 1
        }
        function onDeviceSettingsButtonClicked() {
            appHeader.setActiveDeviceSettings()
            sensorPages.currentIndex = 2
        }
    }
    Connections {
        target: tabletMenuDevice
        // mobile only
        function onDeviceDataButtonClicked() {
            tabletMenuDevice.setActiveDeviceData()
            sensorPages.currentIndex = 0
        }
        function onDeviceHistoryButtonClicked() {
            tabletMenuDevice.setActiveDeviceHistory()
            sensorPages.currentIndex = 1
        }
        function onDeviceSettingsButtonClicked() {
            tabletMenuDevice.setActiveDeviceSettings()
            sensorPages.currentIndex = 2
        }
    }

    function loadDevice() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("DeviceScreen // loadDevice() >> " + myDevice)

        sensorPages.currentIndex = 0

        rectangleDeviceData.loadData()
        rectangleDeviceHistory.updateHeader()
        rectangleDeviceHistory.loadData()
        rectangleDeviceLimits.updateHeader()
        rectangleDeviceLimits.updateLimits()
        rectangleDeviceLimits.updateLimitsVisibility()

        if (isMobile) tabletMenuDevice.setActiveDeviceData()
        if (isDesktop) appHeader.setActiveDeviceData()
    }

    function isHistoryMode() {
        return rectangleDeviceData.isHistoryMode()
    }
    function resetHistoryMode() {
        rectangleDeviceData.resetHistoryMode()
    }

    ////////////////////////////////////////////////////////////////////////////

    Item {
        anchors.fill: parent

        SwipeView {
            id: sensorPages
            anchors.fill: parent

            //anchors.bottomMargin: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? 48 : 0
            interactive: isPhone

            currentIndex: 0
            onCurrentIndexChanged: {
                if (isDesktop) {
                    if (sensorPages.currentIndex === 0)
                        appHeader.setActiveDeviceData()
                    else if (sensorPages.currentIndex === 1)
                        appHeader.setActiveDeviceHistory()
                    else if (sensorPages.currentIndex === 2)
                        appHeader.setActiveDeviceSettings()
                } else {
                    if (sensorPages.currentIndex === 0)
                        tabletMenuDevice.setActiveDeviceData()
                    else if (sensorPages.currentIndex === 1)
                        tabletMenuDevice.setActiveDeviceHistory()
                    else if (sensorPages.currentIndex === 2)
                        tabletMenuDevice.setActiveDeviceSettings()
                }
            }

            DeviceScreenData {
                clip: true
                id: rectangleDeviceData
            }
            DeviceScreenHistory {
                clip: true
                id: rectangleDeviceHistory
            }
            DeviceScreenLimits {
                clip: true
                id: rectangleDeviceLimits
            }
        }
    }
}
