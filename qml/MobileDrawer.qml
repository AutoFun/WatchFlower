import QtQuick 2.7
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

Rectangle {
    width: parent.width
    height: parent.height
    color: "#ffffff"

    function updateDrawerFocus() {
        rectangleHome.color = "#00000000"
        rectangleSettings.color = "#00000000"

        if (content.state === "DeviceList")
            rectangleHome.color = "#dddddd"
        else if (content.state === "Settings")
            rectangleSettings.color = "#dddddd"
    }

    Rectangle {
        id: rectangleHeader
        height: 128
        color: "#00000000"
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        Image {
            id: imageHeader
            width: 256
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.top: parent.top

            source: "qrc:/assets/desktop/watchflower.svg"
            sourceSize.width: width
            sourceSize.height: width
            fillMode: Image.PreserveAspectCrop
        }
    }

    Column {
        id: row
        anchors.top: rectangleHeader.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.topMargin: 0

        Rectangle {
            height: 8
            color: "#00000000"
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
        }

        Rectangle {
            id: rectangleHome
            height: 48
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    content.state = "DeviceList"
                    drawer.close()
                }
            }

            Image {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/desktop/watchflower_tray_dark.svg"
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: "grey"
                }
            }
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Device List")
                font.pixelSize: 14
            }
        }

        Rectangle {
            id: rectangleSettings
            height: 48
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    content.state = "Settings"
                    drawer.close()
                }
            }

            Image {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-tune-24px.svg"
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: "grey"
                }
            }
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Settings")
                font.pixelSize: 14
            }
        }

        Rectangle {
            height: 8
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"
        }
        Rectangle {
            height: 1
            anchors.right: parent.right
            anchors.left: parent.left
            color: "darkgrey"
        }
        Rectangle {
            height: 8
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"
        }

        Rectangle {
            id: rectangleRefresh
            height: 48
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    deviceManager.refreshDevices()
                    drawer.close()
                }
            }

            Image {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: "grey"
                }
            }
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Update sensors")
                font.pixelSize: 14
            }
        }

        Rectangle {
            id: rectangleScan
            height: 48
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    deviceManager.scanDevices()
                    drawer.close()
                }
            }

            Image {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-search-24px.svg"
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: "grey"
                }
            }
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Search for new devices")
                font.pixelSize: 14
            }
        }

        Rectangle {
            height: 8
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"
        }
        Rectangle {
            height: 1
            anchors.right: parent.right
            anchors.left: parent.left
            color: "darkgrey"
        }
        Rectangle {
            height: 8
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"
        }

        Rectangle {
            id: rectangleExit
            height: 48
            color: "#00000000"
            anchors.right: parent.right
            anchors.left: parent.left
            MouseArea {
                anchors.fill: parent
                onClicked: settingsManager.exit()
            }

            Image {
                width: 24
                height: 24
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/assets/icons_material/baseline-exit_to_app-24px.svg"
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: "grey"
                }
            }
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("Exit")
                font.pixelSize: 14
            }
        }

        Rectangle {
            height: 8
            anchors.right: parent.right
            anchors.left: parent.left
            color: "#00000000"
        }
    }
}