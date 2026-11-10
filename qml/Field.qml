import QtQuick
import QtQuick.Controls
TextField {
    id: control
    implicitHeight: 46
    leftPadding: 14
    rightPadding: 14
    color: Theme.foreground
    placeholderTextColor: Theme.muted
    selectionColor: Theme.primary
    selectedTextColor: Theme.primaryText
    font.family: Theme.family
    font.pointSize: 11
    maximumLength: 128
    Accessible.name: placeholderText
    background: Rectangle {
        color: Theme.background
        radius: 7
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? Theme.primary : Theme.border
    }
}
