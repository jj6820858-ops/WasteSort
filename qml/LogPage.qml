import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
Item {
    id: root
    property string level: "ALL"
    property var rows: []
    function refresh() { rows = backend.filteredLogs(level, search.text) }
    Component.onCompleted: refresh()
    onLevelChanged: refresh()
    Connections { target: backend; function onLogsChanged() { root.refresh() } }
    FileDialog {
        id: exportDialog
        title: "导出当前筛选的日志"
        fileMode: FileDialog.SaveFile
        nameFilters: ["CSV 文件 (*.csv)"]
        defaultSuffix: "csv"
        onAccepted: backend.exportLogs(selectedFile, root.level, search.text)
    }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 26; spacing: 20
        RowLayout {
            ColumnLayout { spacing: 6; UiText { text: "运行日志"; font.pointSize: 22; font.weight: Font.DemiBold } UiText { text: "让每一次操作可回溯，每一个状态有记录。"; color: Theme.muted; font.pointSize: 10 } }
            Item { Layout.fillWidth: true }
            UiButton { text: "导出 CSV  ↓"; primary: true; onClicked: exportDialog.open() }
        }
        Panel {
            Layout.fillWidth: true; implicitHeight: 78
            RowLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 8
                Repeater {
                    model: [{name:"全部", key:"ALL"}, {name:"信息", key:"INFO"}, {name:"警告", key:"WARN"}, {name:"错误", key:"ERROR"}]
                    delegate: UiButton { required property var modelData; text: modelData.name; primary: root.level === modelData.key; implicitWidth: 74; onClicked: root.level = modelData.key }
                }
                Item { Layout.fillWidth: true }
                Field { id: search; Layout.preferredWidth: 280; placeholderText: "搜索内容、模块或日期"; onTextChanged: root.refresh() }
            }
        }
        Panel {
            Layout.fillWidth: true; Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 18; spacing: 0
                RowLayout { Layout.fillWidth: true; Layout.bottomMargin: 16; UiText { text: "事件记录"; font.pointSize: 13; font.weight: Font.DemiBold } Item { Layout.fillWidth: true } UiText { text: root.rows.length + " 条匹配记录"; font.pointSize: 9; color: Theme.muted } }
                Rectangle {
                    Layout.fillWidth: true; implicitHeight: 42; color: Theme.raised; radius: 6
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 16
                        UiText { text: "时间"; Layout.preferredWidth: 176; color: Theme.muted; font.pointSize: 9 }
                        UiText { text: "级别"; Layout.preferredWidth: 68; color: Theme.muted; font.pointSize: 9 }
                        UiText { text: "模块"; Layout.preferredWidth: 64; color: Theme.muted; font.pointSize: 9 }
                        UiText { text: "事件内容"; Layout.fillWidth: true; color: Theme.muted; font.pointSize: 9 }
                    }
                }
                ListView {
                    id: list
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: root.rows
                    ScrollBar.vertical: ScrollBar {}
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: list.width; height: Math.max(56, logMessage.implicitHeight + 26)
                        color: index % 2 ? Theme.raised : "transparent"
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 22; spacing: 16
                            UiText { text: modelData.time; Layout.preferredWidth: 176; color: Theme.muted; font.family: "Consolas"; font.pointSize: 10 }
                            UiText { text: modelData.level; Layout.preferredWidth: 68; color: modelData.level === "WARN" ? Theme.warning : modelData.level === "ERROR" ? Theme.danger : Theme.info; font.family: "Consolas"; font.pointSize: 10 }
                            UiText { text: modelData.module; Layout.preferredWidth: 64; color: Theme.muted; font.pointSize: 10 }
                            UiText { id: logMessage; text: modelData.message; Layout.fillWidth: true; wrapMode: Text.Wrap; elide: Text.ElideNone; font.pointSize: 10 }
                        }
                    }
                    ColumnLayout { visible: list.count === 0; anchors.centerIn: parent; spacing: 12; LineIcon { Layout.alignment: Qt.AlignHCenter; kind: "log"; width: 36; height: 36 } UiText { text: "没有匹配的日志"; Layout.alignment: Qt.AlignHCenter } UiText { text: "试试其他关键词或日志级别。"; color: Theme.muted; font.pointSize: 10 } }
                }
                UiText { Layout.topMargin: 14; text: "本机自动保存最近 2,000 条事件 · 导出遵循当前筛选条件"; color: Theme.muted; font.pointSize: 9 }
            }
        }
    }
}
