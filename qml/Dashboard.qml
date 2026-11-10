import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item {
    id: root
    signal openLogs()
    property var last: backend.latest
    ScrollView {
        id: scroll
        anchors.fill: parent; clip: true
        contentWidth: availableWidth
        contentHeight: dashboardColumn.height + 52
    ColumnLayout {
        id: dashboardColumn
        x: 26; y: 26; width: scroll.availableWidth - 52
        height: Math.max(root.height - 52, 730)
        spacing: 18
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout { spacing: 6; UiText { text: "分类监控"; font.pointSize: 22; font.weight: Font.DemiBold } UiText { text: "看见每一次投放，让分类井然有序。"; color: Theme.muted; font.pointSize: 10 } }
            Item { Layout.fillWidth: true }
            UiButton { text: "模拟投放"; onClicked: backend.sample() }
            UiButton { text: backend.running ? "Ⅱ  暂停演示" : "▷  启动演示"; primary: true; Layout.leftMargin: 4; onClicked: backend.toggleRunning() }
        }
        RowLayout {
            Layout.fillWidth: true; spacing: 14
            Repeater {
                model: backend.categories
                delegate: Panel {
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true; implicitHeight: 166
                    Rectangle { anchors.top: parent.top; anchors.topMargin: 1; anchors.horizontalCenter: parent.horizontalCenter; width: parent.width-24; height: 2; color: modelData.color; opacity: .8 }
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 18; spacing: 8
                        RowLayout { UiText { text: modelData.name; Layout.fillWidth: true; font.pointSize: 12; font.weight: Font.DemiBold } UiText { text: modelData.code; color: Theme.muted; font.pointSize: 9 } }
                        RowLayout {
                            ColumnLayout {
                                spacing: 2
                                RowLayout { spacing: 6; UiText { text: modelData.count.toString().padStart(2,"0"); font.family: "Bahnschrift"; font.pointSize: 28; color: Theme.foreground } UiText { text: "件"; color: Theme.muted; font.pointSize: 9; Layout.alignment: Qt.AlignBottom; Layout.bottomMargin: 6 } }
                                UiText { text: "本次运行累计"; color: Theme.muted; font.pointSize: 8 }
                            }
                            Item { Layout.fillWidth: true }
                            BinArt { Layout.preferredWidth: 48; Layout.preferredHeight: 58; ink: modelData.color; kind: index; fillLevel: modelData.fill / 100 }
                        }
                        RowLayout { Layout.fillWidth: true; UiText { text: modelData.fill >= 80 ? "余量不足" : "桶体余量"; color: modelData.fill >= 80 ? Theme.warning : Theme.muted; font.pointSize: 8 } Item { Layout.fillWidth: true } UiText { text: (100-modelData.fill)+"%"; color: Theme.muted; font.pointSize: 9 } }
                        Rectangle { Layout.fillWidth: true; height: 4; radius: 2; color: Theme.raised; Rectangle { width: parent.width*(100-modelData.fill)/100; height: 4; radius: 2; color: modelData.color } }
                    }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.minimumHeight: 270; spacing: 18
            Panel {
                Layout.fillWidth: true; Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 12
                    RowLayout { UiText { text: "分拣工作站"; font.pointSize: 13; font.weight: Font.DemiBold } Item { Layout.fillWidth: true } Rectangle { width: 7; height: 7; radius: 4; color: backend.running ? Theme.primary : Theme.warning } UiText { text: backend.running ? "自动演示中" : "待机"; color: Theme.muted; font.pointSize: 9 } }
                    Rectangle {
                        Layout.fillWidth: true; Layout.fillHeight: true; Layout.minimumHeight: 170; color: Theme.background; radius: 8; clip: true
                        Canvas {
                            anchors.fill: parent
                            property color gridColor: Theme.border
                            onGridColorChanged: requestPaint()
                            onWidthChanged: requestPaint()
                            onHeightChanged: requestPaint()
                            onPaint: { let c=getContext("2d");c.reset();c.fillStyle=gridColor;for(let x=16;x<width;x+=24)for(let y=16;y<height;y+=24)c.fillRect(x,y,1,1); }
                        }
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 18; spacing: 16
                            ColumnLayout {
                                Layout.preferredWidth: 110; spacing: 10
                                Rectangle { Layout.alignment: Qt.AlignHCenter; width: 64; height: 54; radius: 9; color: Theme.raised; border.color: Theme.border; LineIcon { anchors.centerIn: parent; kind: "link"; ink: Theme.info; width: 30; height: 30 } }
                                UiText { text: "识别入口"; Layout.alignment: Qt.AlignHCenter; font.pointSize: 10 }
                                UiText { text: "模拟视觉输入"; Layout.alignment: Qt.AlignHCenter; color: Theme.muted; font.pointSize: 8 }
                            }
                            ColumnLayout { Layout.fillWidth: true; spacing: 10
                                RowLayout { Layout.fillWidth: true; Rectangle { height: 1; Layout.fillWidth: true; color: Theme.border } UiText { text: "分类 → 投放"; color: Theme.muted; font.pointSize: 8 } Rectangle { height: 1; Layout.fillWidth: true; color: Theme.border } }
                                Row {
                                    Layout.fillWidth: true; Layout.preferredHeight: 132
                                    Repeater {
                                        model: backend.categories
                                        delegate: Column {
                                            required property var modelData
                                            required property int index
                                            width: parent.width/4; spacing: 6
                                            BinArt { anchors.horizontalCenter: parent.horizontalCenter; width: Math.min(72,parent.width-12); height: 92; ink: modelData.color; kind: index; fillLevel: modelData.fill/100 }
                                            UiText { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.name; font.pointSize: 9 }
                                            Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 26; height: 3; radius: 2; color: root.last.index === index ? modelData.color : Theme.border }
                                        }
                                    }
                                }
                            }
                        }
                        UiText { anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 10; text: "SCHEMATIC / 示意图"; color: Theme.muted; font.pointSize: 7 }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        UiText { text: "本次投放"; color: Theme.muted; font.pointSize: 9 }
                        UiText { text: backend.total+" 件"; font.pointSize: 12; Layout.leftMargin: 4 }
                        Item { Layout.fillWidth: true }
                        UiText { text: "演示周期  "+backend.interval+" s"; color: Theme.muted; font.pointSize: 9 }
                    }
                }
            }
            Panel {
                Layout.preferredWidth: 306; Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 9
                    RowLayout { UiText { text: "最近识别"; font.pointSize: 13; font.weight: Font.DemiBold } Item { Layout.fillWidth: true } UiText { text: "模拟"; color: Theme.warning; font.pointSize: 9 } }
                    Item { Layout.fillHeight: true; Layout.minimumHeight: 0 }
                    RowLayout {
                        spacing: 16
                        Rectangle { width: 60; height: 68; radius: 9; color: Theme.raised; BinArt { anchors.centerIn: parent; width: 40; height: 50; kind: root.last.index !== undefined ? root.last.index : 0; ink: root.last.color || Theme.muted; fillLevel: .5 } }
                        ColumnLayout {
                            spacing: 8
                            UiText { text: root.last.name || "等待首次投放"; font.pointSize: 15; font.weight: Font.DemiBold }
                            UiText { text: root.last.category || "点击「模拟投放」开始"; color: Theme.primary; font.pointSize: 10 }
                        }
                    }
                    Item { Layout.fillHeight: true; Layout.minimumHeight: 0 }
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                    RowLayout { UiText { text: "模拟置信度"; color: Theme.muted; font.pointSize: 9 } Item { Layout.fillWidth: true } UiText { text: root.last.confidence !== undefined ? root.last.confidence.toFixed(1)+"%" : "—"; font.pointSize: 12 } }
                    RowLayout { UiText { text: "识别时间"; color: Theme.muted; font.pointSize: 9 } Item { Layout.fillWidth: true } UiText { text: root.last.time || "—"; font.pointSize: 10 } }
                    Rectangle {
                        Layout.fillWidth: true; implicitHeight: 38; radius: 6; color: Theme.selected
                        UiText { anchors.centerIn: parent; text: root.last.name ? "✓  模拟投放完成" : "等待演示数据"; color: Theme.primary; font.pointSize: 10 }
                    }
                }
            }
        }
        Panel {
            Layout.fillWidth: true; Layout.preferredHeight: 173
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 18; spacing: 8
                RowLayout { UiText { text: "实时日志"; font.pointSize: 13; font.weight: Font.DemiBold } UiText { text: "最近 3 条"; color: Theme.muted; font.pointSize: 8; Layout.leftMargin: 8 } Item { Layout.fillWidth: true } UiButton { text: "查看全部  →"; quiet: true; implicitHeight: 30; onClicked: root.openLogs() } }
                Repeater {
                    model: backend.logs.slice(0,3)
                    delegate: RowLayout {
                        required property var modelData
                        Layout.fillWidth: true; spacing: 16
                        UiText { text: modelData.time.slice(11); color: Theme.muted; font.family: "Consolas"; font.pointSize: 10; Layout.preferredWidth: 76 }
                        UiText { text: modelData.level; color: modelData.level === "WARN" ? Theme.warning : Theme.info; font.family: "Consolas"; font.pointSize: 9; Layout.preferredWidth: 48 }
                        UiText { text: modelData.module; color: Theme.muted; font.pointSize: 10; Layout.preferredWidth: 50 }
                        UiText { text: modelData.message; Layout.fillWidth: true; font.pointSize: 10 }
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }
    }
    }
}
