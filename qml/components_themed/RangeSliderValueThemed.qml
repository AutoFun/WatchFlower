import QtQuick 2.9
import QtQuick.Controls 2.2

import com.watchflower.theme 1.0

RangeSlider {
    id: control
    first.value: 0.25
    second.value: 0.75
    snapMode: RangeSlider.SnapAlways

    property string unit: ""

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        implicitWidth: 200
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: Theme.colorYellow
        opacity: 0.8

        Rectangle {
            x: (control.first.visualPosition * parent.width)
            width: (control.second.visualPosition * parent.width) - x
            height: parent.height
            color: Theme.colorGreen
            radius: 2
        }
    }

    first.handle: Rectangle {
        x: control.leftPadding + first.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        implicitWidth: 22
        implicitHeight: 22
        width: t1.width * 1.4
        radius: 6
        color: Theme.colorGreen
        border.color: Theme.colorGreen
        opacity: first.pressed ? 0.8 : 1

        Text {
            id: t1
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            anchors.horizontalCenter: parent.horizontalCenter
            text: ((first.value > 999) ? first.value.toFixed(0) / 1000 : first.value.toFixed(0)) + unit
            font.pixelSize: 14
            color: "white"
        }
    }

    second.handle: Rectangle {
        x: control.leftPadding + second.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight / 2) - (height / 2)
        implicitWidth: 22
        implicitHeight: 22
        width: t2.width * 1.4
        radius: 6
        color: Theme.colorGreen
        border.color: Theme.colorGreen
        opacity: second.pressed ? 0.8 : 1

        Text {
            id: t2
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            anchors.horizontalCenter: parent.horizontalCenter
            text: ((second.value > 999) ? second.value.toFixed(0) / 1000 : second.value.toFixed(0)) + unit
            font.pixelSize: 14
            color: "white"
        }
    }
}