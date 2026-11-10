import QtQuick
import QtQuick.Controls
Button {
    id: control
    property bool primary: false
    property bool quiet: false
    implicitHeight: 44
    implicitWidth: Math.max(100, contentItem.implicitWidth + 32)
    padding: 12
    hoverEnabled: true
    font.family: Theme.family
    font.pointSize: 11
    Accessible.name: text
    background: Rectangle {
        radius: 7
        color: !control.enabled ? Theme.raised : control.primary ? (control.down ? Qt.darker(Theme.primary, 1.12) : Theme.primary) : control.hovered ? Theme.raised : control.quiet ? "transparent" : Theme.surface
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? Theme.primary : control.primary || control.quiet ? "transparent" : Theme.border
    }
    contentItem: UiText {
        text: control.text
        font: control.font
        color: !control.enabled ? Theme.muted : control.primary ? Theme.primaryText : Theme.foreground
        horizontalAlignment: Text.AlignHCenter
    }
}
