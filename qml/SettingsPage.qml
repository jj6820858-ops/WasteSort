import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item {
    ScrollView {
        anchors.fill: parent; anchors.margins: 26; clip: true
        contentWidth: availableWidth
        ColumnLayout {
            width: parent.width; spacing: 20
            UiText { text: "工作台设置"; font.pointSize: 22; font.weight: Font.DemiBold }
            UiText { text: "调整演示节奏，管理桶体状态与显示偏好。"; color: Theme.muted; font.pointSize: 10 }
            Panel {
                Layout.fillWidth: true; implicitHeight: 156
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 22; spacing: 16
                    UiText { text: "运行与外观"; font.pointSize: 13; font.weight: Font.DemiBold }
                    RowLayout {
                        UiText { text: "演示间隔"; Layout.preferredWidth: 100 }
                        Repeater { model: [1,3,5,10]; delegate: UiButton { required property int modelData; text: modelData+" 秒"; implicitWidth: 76; primary: backend.interval === modelData; onClicked: backend.interval = modelData } }
                        Item { Layout.fillWidth: true }
                        UiButton { text: Theme.light ? "切换深色" : "切换浅色"; onClicked: Theme.light = !Theme.light }
                    }
                    UiText { text: "所有投放、置信度与桶体余量均为演示数据。"; color: Theme.muted; font.pointSize: 10 }
                }
            }
            Panel {
                Layout.fillWidth: true; implicitHeight: 236
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 22; spacing: 16
                    UiText { text: "桶体管理"; font.pointSize: 13; font.weight: Font.DemiBold }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 14
                        Repeater {
                            model: backend.categories
                            delegate: ColumnLayout {
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true; spacing: 12
                                UiText { text: modelData.name; Layout.alignment: Qt.AlignHCenter }
                                UiText { text: "已用 " + modelData.fill + "%"; color: Theme.muted; Layout.alignment: Qt.AlignHCenter; font.pointSize: 10 }
                                UiButton { Layout.fillWidth: true; text: "模拟清空"; onClicked: backend.emptyBin(index) }
                            }
                        }
                    }
                    UiText { text: "模拟清空仅重置桶体余量，累计分类数量保持不变。"; color: Theme.muted; font.pointSize: 10 }
                }
            }
            Panel {
                Layout.fillWidth: true; implicitHeight: 200
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 22; spacing: 12
                    RowLayout { UiText { text: "设备与数据"; font.pointSize: 13; font.weight: Font.DemiBold } Item { Layout.fillWidth: true } UiText { text: "设备未连接"; color: Theme.warning; font.pointSize: 10 } }
                    UiText { text: "当前版本使用内置模拟器，相机识别和下位机通信尚未接入。"; color: Theme.muted; font.pointSize: 10; Layout.fillWidth: true; wrapMode: Text.Wrap }
                    UiText { text: "分类名称按项目要求保留；厨余与湿垃圾的区分规则待设备协议确定。"; color: Theme.muted; font.pointSize: 10; Layout.fillWidth: true; wrapMode: Text.Wrap }
                    UiText { text: "账号与日志保存位置"; font.pointSize: 10 }
                    TextEdit { text: backend.dataPath; color: Theme.muted; font.family: Theme.family; font.pointSize: 9; readOnly: true; selectByMouse: true; wrapMode: TextEdit.Wrap; Layout.fillWidth: true; Accessible.name: "本机数据目录" }
                }
            }
        }
    }
}
