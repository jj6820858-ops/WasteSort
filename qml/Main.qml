import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
ApplicationWindow {
    id: window
    visible: true
    width: 1440; height: 920
    minimumWidth: 1120; minimumHeight: 760
    title: qsTr("归序 · 垃圾分类工作台")
    color: Theme.background
    property int page: initialPage
    property string toastText: ""
    property string now: ""
    function updateClock() { now = new Date().toLocaleString(Qt.locale("zh_CN"), "yyyy/MM/dd  ddd  HH:mm:ss") }
    Component.onCompleted: updateClock()
    Timer { interval: 1000; repeat: true; running: true; onTriggered: window.updateClock() }
    Connections {
        target: backend
        function onNotice(message) { window.toastText = message; toastTimer.restart() }
        function onAuthChanged() { if (!backend.authenticated) window.page = 0 }
    }
    Timer { id: toastTimer; interval: 6000; onTriggered: window.toastText = "" }
    Loader { anchors.fill: parent; sourceComponent: backend.authenticated ? shell : login }
    Component { id: login; LoginPage {} }
    Component {
        id: shell
        RowLayout {
            spacing: 0
            Rectangle {
                Layout.preferredWidth: 206; Layout.fillHeight: true; color: Theme.sidebar
                Rectangle { anchors.right: parent.right; height: parent.height; width: 1; color: Theme.border }
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 12
                    RowLayout {
                        Layout.topMargin: 12; Layout.bottomMargin: 30; spacing: 12
                        Image { source: "qrc:/assets/guixu.png"; sourceSize: Qt.size(76,76); Layout.preferredWidth: 38; Layout.preferredHeight: 38 }
                        Column { spacing: 1; UiText { text: "归序"; font.pointSize: 19; font.weight: Font.DemiBold } UiText { text: "SORTING STUDIO"; color: Theme.muted; font.pointSize: 8 } }
                    }
                    UiText { text: "工作空间"; color: Theme.muted; font.pointSize: 9; Layout.leftMargin: 12; Layout.bottomMargin: 4 }
                    Repeater {
                        model: [{name:"分类监控", icon:"grid"}, {name:"运行日志", icon:"log"}, {name:"工作台设置", icon:"settings"}]
                        delegate: Button {
                            required property int index
                            required property var modelData
                            Layout.fillWidth: true; implicitHeight: 50; hoverEnabled: true
                            Accessible.name: modelData.name
                            onClicked: window.page = index
                            background: Rectangle { radius: 8; color: window.page === index ? Theme.selected : parent.hovered ? Theme.raised : "transparent"; border.color: parent.activeFocus ? Theme.primary : "transparent" }
                            contentItem: RowLayout {
                                spacing: 13
                                LineIcon { Layout.leftMargin: 10; kind: modelData.icon; ink: window.page === index ? Theme.primary : Theme.muted }
                                UiText { text: modelData.name; color: window.page === index ? Theme.primary : Theme.muted; Layout.fillWidth: true }
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                    Panel {
                        Layout.fillWidth: true; implicitHeight: 126
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 14; spacing: 8
                            RowLayout { Rectangle { width: 7; height: 7; radius: 4; color: Theme.warning } UiText { text: "演示工作站"; font.pointSize: 10 } }
                            UiText { text: "设备未连接"; color: Theme.muted; font.pointSize: 10 }
                            UiText { text: "本机 / DEMO-01"; color: Theme.muted; font.pointSize: 8 }
                        }
                    }
                    RowLayout {
                        Layout.topMargin: 14
                        Rectangle { width: 32; height: 32; radius: 16; color: Theme.raised; UiText { anchors.centerIn: parent; text: backend.user.charAt(0).toUpperCase(); color: Theme.primary } }
                        UiText { text: backend.user; Layout.fillWidth: true; font.pointSize: 10 }
                        Button {
                            implicitWidth: 30; implicitHeight: 38; Accessible.name: "退出登录"
                            ToolTip.text: "退出登录"; ToolTip.visible: hovered
                            onClicked: backend.logout()
                            background: Rectangle { color: "transparent"; border.color: parent.activeFocus ? Theme.primary : "transparent"; radius: 5 }
                            contentItem: LineIcon { kind: "logout" }
                        }
                    }
                    UiText { text: "归序  v1.0  /  Qt 6"; color: Theme.muted; font.pointSize: 8; Layout.topMargin: 10 }
                }
            }
            ColumnLayout {
                Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0
                Rectangle {
                    Layout.fillWidth: true; implicitHeight: 69; color: Theme.sidebar
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 28; anchors.rightMargin: 28
                        UiText { text: "工作空间  /  " + ["分类监控", "运行日志", "工作台设置"][window.page]; color: Theme.muted; font.pointSize: 10 }
                        Item { Layout.fillWidth: true }
                        UiText { text: window.now; color: Theme.muted; font.pointSize: 9 }
                        Rectangle { Layout.leftMargin: 18; width: 78; height: 28; radius: 5; color: Theme.selected; UiText { anchors.centerIn: parent; text: "演示模式"; color: Theme.primary; font.pointSize: 9 } }
                    }
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }
                }
                StackLayout {
                    Layout.fillWidth: true; Layout.fillHeight: true; currentIndex: window.page
                    Dashboard { onOpenLogs: window.page = 1 }
                    LogPage {}
                    SettingsPage {}
                }
                RowLayout {
                    Layout.fillWidth: true; Layout.leftMargin: 28; Layout.rightMargin: 28; Layout.bottomMargin: 12; spacing: 8
                    Rectangle { width: 6; height: 6; radius: 3; color: Theme.primary }
                    UiText { text: backend.running ? "自动演示运行中" : "工作台就绪"; font.pointSize: 8; color: Theme.muted }
                    Item { Layout.fillWidth: true }
                    UiText { text: "模拟数据 · 未连接相机或下位机"; font.pointSize: 8; color: Theme.muted }
                }
            }
        }
    }
    Rectangle {
        z: 100; visible: window.toastText.length > 0
        anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottomMargin: 36
        width: Math.min(parent.width - 60, toastLabel.implicitWidth + 40); height: toastLabel.implicitHeight + 28
        radius: 8; color: Theme.raised; border.color: Theme.primary
        UiText { id: toastLabel; anchors.fill: parent; anchors.margins: 14; text: window.toastText; wrapMode: Text.Wrap; elide: Text.ElideNone; horizontalAlignment: Text.AlignHCenter }
    }
}
