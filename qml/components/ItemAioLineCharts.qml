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
import QtCharts 2.2

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Item {
    id: itemAioLineCharts
    width: parent.width
    anchors.margins: 0

    function loadGraph() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("itemAioLineCharts // loadGraph() >> " + myDevice)

        tempData.visible = myDevice.hasTemperatureSensor()
        hygroData.visible = (myDevice.hasHumiditySensor() || myDevice.hasSoilMoistureSensor()) && myDevice.hasData("hygro")
        lumiData.visible = false
        conduData.visible = myDevice.hasConductivitySensor() && myDevice.hasData("conductivity")

        dateIndicator.visible = false
        dataIndicator.visible = false
        verticalIndicator.visible = false
    }

    function updateGraph() {
        if (typeof myDevice === "undefined" || !myDevice) return
        //console.log("itemAioLineCharts // updateGraph() >> " + myDevice)

        if (dateIndicator.visible)
            resetIndicator()

        if (myDevice.countData("temp", 14) > 1) {
            aioGraph.visible = true
            noDataIndicator.visible = false
        } else {
            aioGraph.visible = false
            noDataIndicator.visible = true
        }

        //// DATA
        hygroData.clear()
        tempData.clear()
        lumiData.clear()
        conduData.clear()

        myDevice.getAioData(axisTime, hygroData, tempData, lumiData, conduData);

        //// AXIS
        axisHygro.min = 0
        axisHygro.max = 100
        axisTemp.min = 0
        axisTemp.max = 60
        axisCondu.min = 0
        axisCondu.max = 1000
        axisLumi.min = 0
        axisLumi.max = 3000

        // Max axis for hygrometry
        if (myDevice.hygroMax*1.20 > 100.0)
            axisHygro.max = 100.0; // no need to go higher than 100% soil moisture
        else
            axisHygro.max = myDevice.hygroMax*1.20;

        // Max axis for temperature
        axisTemp.max = myDevice.tempMax*1.20;

        // Max axis for conductivity
        axisCondu.max = myDevice.conduMax*2.0;

        // Min axis computation, only for thermometers
        if (!myDevice.hasSoilMoistureSensor()) {
            axisHygro.min = myDevice.hygroMin*0.80;
            axisTemp.min = myDevice.tempMin*0.80;
        }

        //// ADJUSTMENTS
        hygroData.width = 2
        tempData.width = 2

        if (myDevice.deviceName === "ropot") {
            hygroData.width = 3 // Humidity is primary
        }

        if (!myDevice.hasSoilMoistureSensor()) {
            tempData.width = 3 // Temperature is primary
        }

        if (myDevice.deviceName === "Flower care") {
            // not planted? don't show hygro and condu
            hygroData.visible = (myDevice.hasHumiditySensor() || myDevice.hasSoilMoistureSensor()) && myDevice.hasData("hygro")
            conduData.visible = myDevice.hasConductivitySensor() && myDevice.hasData("conductivity")

            // Flower Care without hygro & conductivity data
            if (!hygroData.visible && !conduData.visible) {
                // Show luminosity and make temperature primary
                lumiData.visible = true
                tempData.width = 3

                // Luminosity can have min/max, cause values have a very wide range
                axisLumi.max = myDevice.lumiMax*1.20;
            } else {
                hygroData.width = 3 // Soil moisture is primary
            }
        }
    }

    function qpoint_lerp(p0, p1, x) { return (p0.y + (x - p0.x) * ((p1.y - p0.y) / (p1.x - p0.x))) }

    ////////////////////////////////////////////////////////////////////////////

    ChartView {
        id: aioGraph
        anchors.fill: parent
        anchors.margins: -20

        antialiasing: true
        legend.visible: false // works only with Qt 5.10+
        backgroundRoundness: 0
        backgroundColor: "transparent"
        //animationOptions: ChartView.SeriesAnimations

        ValueAxis { id: axisHygro; visible: false; gridVisible: true; }
        ValueAxis { id: axisTemp; visible: false; gridVisible: true; }
        ValueAxis { id: axisLumi; visible: false; gridVisible: true; }
        ValueAxis { id: axisCondu; visible: false; gridVisible: true; }
        DateTimeAxis { id: axisTime; visible: true;
                       labelsFont.pixelSize: 14; labelsColor: Theme.colorText;
                       gridLineColor: Theme.colorSeparator; }

        LineSeries {
            id: lumiData
            pointsVisible: settingsManager.graphShowDots;
            color: Theme.colorYellow; width: 2;
            axisY: axisLumi; axisX: axisTime;
        }
        LineSeries {
            id: conduData
            pointsVisible: settingsManager.graphShowDots;
            color: Theme.colorRed; width: 2;
            axisY: axisCondu; axisX: axisTime;
        }
        LineSeries {
            id: tempData
            pointsVisible: settingsManager.graphShowDots;
            color: Theme.colorGreen; width: 2;
            axisY: axisTemp; axisX: axisTime;
        }
        LineSeries {
            id: hygroData
            pointsVisible: settingsManager.graphShowDots;
            color: Theme.colorBlue; width: 2;
            axisY: axisHygro; axisX: axisTime;
        }

        MouseArea {
            id: clickableGraphArea
            anchors.fill: aioGraph
            //propagateComposedEvents: true
            //hoverEnabled: true

            onClicked: {
                var mmm = Qt.point(mouse.x, mouse.y)
                mouse.accepted = true

                // we adjust coordinates with graph area margins
                var ppp = Qt.point(mouse.x, mouse.y)
                ppp.x = ppp.x + aioGraph.anchors.rightMargin
                ppp.y = ppp.y - aioGraph.anchors.topMargin

                // map mouse position to graph value // mpmp.x is the timestamp
                var mpmp = aioGraph.mapToValue(mmm, tempData)

                //console.log("clicked " + mouse.x + " " + mouse.y)
                //console.log("clicked adjusted " + ppp.x + " " + ppp.y)
                //console.log("clicked mapped " + mpmp.x + " " + mpmp.y)

                // did we actually clicked inside the axis?
                if (mpmp.x >= tempData.at(0).x && mpmp.x <= tempData.at(tempData.count-1).x) {
                    // indicators visible
                    dateIndicator.visible = true
                    verticalIndicator.visible = true
                    verticalIndicator.x = ppp.x
                    // set date & time
                    var date = new Date(mpmp.x)
                    var date_string = date.toLocaleDateString()
                    //: "at" is used for DATE at HOUR
                    var time_string = qsTr("at") + " " + UtilsNumber.padNumber(date.getHours(), 2) + ":" + UtilsNumber.padNumber(date.getMinutes(), 2)
                    textTime.text = date_string + " " + time_string

                    // search index corresponding to the timestamp
                    var x1 = -1
                    var x2 = -1
                    for (var i = 0; i < tempData.count; i++) {
                        var graph_at_x = tempData.at(i).x
                        var dist = (graph_at_x - mpmp.x) / 1000000

                        if (Math.abs(dist) < 1) {
                            // nearest neighbor
                            if (appContent.state === "DeviceSensor") {
                                dataIndicators.updateDataBars(tempData.at(i).y, lumiData.at(i).y,
                                                              hygroData.at(i).y, conduData.at(i).y)
                            } else if (appContent.state === "DeviceThermo") {
                                dataIndicator.visible = true
                                dataIndicatorText.text = (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(tempData.at(i).y).toFixed(1) + "°F" : tempData.at(i).y.toFixed(1) + "°C"
                                dataIndicatorText.text += " " + hygroData.at(i).y.toFixed(0) + "%"
                            }
                            break;
                        } else {
                            if (dist < 0) {
                                if (x1 < i) x1 = i
                            } else {
                                x2 = i
                                break
                            }
                        }
                    }

                    if (x1 >= 0 && x2 > x1) {
                        // linear interpolation
                        if (appContent.state === "DeviceSensor") {
                            dataIndicators.updateDataBars(qpoint_lerp(tempData.at(x1), tempData.at(x2), mpmp.x),
                                                          qpoint_lerp(lumiData.at(x1), lumiData.at(x2), mpmp.x),
                                                          qpoint_lerp(hygroData.at(x1), hygroData.at(x2), mpmp.x),
                                                          qpoint_lerp(conduData.at(x1), conduData.at(x2), mpmp.x))
                        } else if (appContent.state === "DeviceThermo") {
                            dataIndicator.visible = true
                            var temmp = qpoint_lerp(tempData.at(x1), tempData.at(x2), mpmp.x)
                            dataIndicatorText.text = (settingsManager.tempUnit === "F") ? UtilsNumber.tempCelsiusToFahrenheit(temmp).toFixed(1) + "°F" : temmp.toFixed(1) + "°C"
                            dataIndicatorText.text += " " + qpoint_lerp(hygroData.at(x1), hygroData.at(x2), mpmp.x).toFixed(0) + "%"
                        }
                    }
                } else {
                    resetIndicator()
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    ItemNoData {
        id: noDataIndicator
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: verticalIndicator
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 28

        width: 1
        visible: false
        opacity: 0.9
        color: Theme.colorSubText
        Behavior on x { NumberAnimation { duration: 333 } }
    }

    Row {
        id: indicators
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        spacing: 12

        Rectangle {
            id: dateIndicator
            width: textTime.width + 16
            height: textTime.height + 12
            anchors.verticalCenter: parent.verticalCenter

            radius: 4
            visible: false
            color: Theme.colorForeground
            border.color: Theme.colorSeparator

            Text {
                id: textTime
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: (settingsManager.bigWidget && isMobile) ? 15 : 14
                font.bold: true
                color: Theme.colorSubText
            }
        }

        Rectangle {
            id: dataIndicator
            width: dataIndicatorText.width + 12
            height: dataIndicatorText.height + 12
            anchors.verticalCenter: parent.verticalCenter

            radius: 4
            visible: false
            color: Theme.colorForeground
            border.color: Theme.colorSeparator

            Text {
                id: dataIndicatorText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: (settingsManager.bigWidget && isMobile) ? 15 : 14
                font.bold: true
                color: Theme.colorSubText
            }
        }
    }

    MouseArea {
        anchors.fill: indicators
        onClicked: resetIndicator()
    }

    onWidthChanged: resetIndicator()

    function isIndicator() {
        return verticalIndicator.visible
    }
    function resetIndicator() {
        dateIndicator.visible = false
        dataIndicator.visible = false
        verticalIndicator.visible = false

        if (typeof deviceScreenData === "undefined" || !deviceScreenData) return
        if (appContent.state === "DeviceSensor") dataIndicators.resetDataBars()
    }
}
