import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item {
    id: root
    RowLayout {
        anchors.fill: parent; spacing: 0
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.preferredWidth: 770
            color: "#12231F"
            Canvas {
                anchors.fill: parent
                onPaint: {
                    let c=getContext("2d");c.reset();c.strokeStyle="#1E3730";c.lineWidth=1;
                    for(let x=0;x<width;x+=48){c.beginPath();c.moveTo(x,0);c.lineTo(x,height);c.stroke();}
                    for(let y=0;y<height;y+=48){c.beginPath();c.moveTo(0,y);c.lineTo(width,y);c.stroke();}
                    c.strokeStyle="#325547";
                    for(let r=130;r<400;r+=65){c.beginPath();c.arc(width*.54,height*.58,r,0,Math.PI*2);c.stroke();}
                }
            }
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 54; spacing: 16
                RowLayout {
                    Image { source: "qrc:/assets/guixu.png"; sourceSize: Qt.size(84,84); Layout.preferredWidth: 42; Layout.preferredHeight: 42 }
                    UiText { text: "归序"; color: "#EEF4FB"; font.pointSize: 22; font.weight: Font.DemiBold; Layout.leftMargin: 8 }
                    UiText { text: "SORTING STUDIO"; color: "#B4C9BD"; font.pointSize: 9; Layout.leftMargin: 8 }
                }
                Item { Layout.fillHeight: true; Layout.minimumHeight: 22 }
                UiText { text: "让每一份资源，"; color: "#EEF4FB"; font.pointSize: 30; font.weight: Font.DemiBold; Layout.fillWidth: true }
                UiText { text: "回到正确的位置。"; color: "#9BE5BC"; font.pointSize: 30; font.weight: Font.DemiBold; Layout.fillWidth: true }
                UiText { text: "从识别到分拣，一处掌握整个分类过程。"; color: "#B4C9BD"; Layout.topMargin: 6 }
                RowLayout {
                    Layout.fillWidth: true; Layout.topMargin: 50; Layout.bottomMargin: 24; spacing: 12
                    Repeater {
                        model: backend.categories
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true; implicitHeight: 180; radius: 12; color: "#182E27"; border.color: "#335246"
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 15; spacing: 12
                                BinArt { Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 68; Layout.preferredHeight: 84; ink: modelData.color; kind: index; fillLevel: .30 + index*.12 }
                                UiText { Layout.alignment: Qt.AlignHCenter; text: modelData.name; color: "#EEF4FB"; font.pointSize: 10 }
                                UiText { Layout.alignment: Qt.AlignHCenter; text: "0" + (index+1); color: "#B4C9BD"; font.pointSize: 8 }
                            }
                        }
                    }
                }
                RowLayout { LineIcon { kind: "check"; ink: "#9BE5BC"; width: 18; height: 18 } UiText { text: "四类监控"; color: "#B4C9BD"; font.pointSize: 10 } Item { width: 16 } LineIcon { kind: "check"; ink: "#9BE5BC"; width: 18; height: 18 } UiText { text: "全程日志"; color: "#B4C9BD"; font.pointSize: 10 } }
                Item { Layout.fillHeight: true; Layout.minimumHeight: 22 }
                UiText { text: "G U I X U  /  智能垃圾分类上位机"; color: "#B4C9BD"; font.pointSize: 9 }
            }
        }
        Rectangle {
            Layout.preferredWidth: root.width * .42; Layout.fillHeight: true; color: Theme.background
            ColumnLayout {
                anchors.centerIn: parent; width: Math.min(380, parent.width - 80); spacing: 14
                UiText { text: "欢迎使用归序"; font.pointSize: 24; font.weight: Font.DemiBold; Layout.bottomMargin: 2 }
                UiText { text: backend.firstRun ? "创建本机账号，开始你的分类工作。" : "登录工作台，继续你的分类工作。"; color: Theme.muted; Layout.bottomMargin: 24 }
                UiText { text: "用户名"; font.pointSize: 10 }
                Field { id: username; Layout.fillWidth: true; placeholderText: "请输入用户名"; maximumLength: 24; onAccepted: password.forceActiveFocus() }
                UiText { text: "密码"; font.pointSize: 10; Layout.topMargin: 4 }
                Field { id: password; Layout.fillWidth: true; placeholderText: backend.firstRun ? "设置密码，至少 8 位" : "请输入密码"; echoMode: showPassword.checked ? TextInput.Normal : TextInput.Password; onAccepted: submit.clicked() }
                CheckBox {
                    id: showPassword; text: "显示密码"; font.family: Theme.family; font.pointSize: 10
                    palette.windowText: Theme.muted; palette.text: Theme.muted
                    indicator: Rectangle {
                        x: showPassword.leftPadding; y: (showPassword.height-height)/2
                        width: 18; height: 18; radius: 4
                        color: showPassword.checked ? Theme.primary : Theme.surface
                        border.color: showPassword.activeFocus ? Theme.primary : Theme.border
                        border.width: showPassword.activeFocus ? 2 : 1
                        UiText { anchors.centerIn: parent; visible: showPassword.checked; text: "✓"; color: Theme.primaryText; font.pointSize: 10 }
                    }
                }
                UiText { text: backend.error; visible: text.length > 0; color: Theme.danger; Layout.fillWidth: true; wrapMode: Text.Wrap; elide: Text.ElideNone; font.pointSize: 10 }
                UiButton {
                    id: submit; Layout.fillWidth: true; primary: true; implicitHeight: 48
                    text: backend.firstRun ? "创建账号并进入  →" : "登录工作台  →"
                    onClicked: {
                        if (backend.firstRun) backend.createAccount(username.text, password.text)
                        else backend.login(username.text, password.text)
                    }
                }
                UiText { text: backend.firstRun ? "用户名：3–24 位字母、数字、下划线或短横线" : "账号仅用于这台电脑的本地工作台。"; color: Theme.muted; font.pointSize: 9; wrapMode: Text.Wrap; elide: Text.ElideNone; Layout.fillWidth: true }
                RowLayout { Layout.fillWidth: true; Layout.topMargin: 18; Layout.bottomMargin: 8; Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border } UiText { text: "先看看界面"; color: Theme.muted; font.pointSize: 9; Layout.leftMargin: 10; Layout.rightMargin: 10 } Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border } }
                UiButton { text: "进入演示工作台"; Layout.fillWidth: true; onClicked: backend.enterDemo() }
                UiText { text: "无需账号 · 使用模拟数据 · 不连接真实设备"; color: Theme.muted; font.pointSize: 9; Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 5 }
            }
            UiText { anchors.bottom: parent.bottom; anchors.bottomMargin: 36; anchors.horizontalCenter: parent.horizontalCenter; text: "桌面客户端  /  v1.0"; color: Theme.muted; font.pointSize: 9 }
        }
    }
}
