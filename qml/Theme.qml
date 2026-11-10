pragma Singleton
import QtQuick
QtObject {
    property bool light: false
    readonly property color background: light ? "#EEF2F5" : "#0D131C"
    readonly property color sidebar: light ? "#FFFFFF" : "#101823"
    readonly property color surface: light ? "#FFFFFF" : "#161F2C"
    readonly property color raised: light ? "#F3F6F9" : "#1C2837"
    readonly property color border: light ? "#CDD6E0" : "#293748"
    readonly property color foreground: light ? "#172536" : "#EEF4FB"
    readonly property color muted: light ? "#526277" : "#A3B2C5"
    readonly property color primary: light ? "#17694D" : "#9BE5BC"
    readonly property color primaryText: light ? "#FFFFFF" : "#102B21"
    readonly property color selected: light ? "#E0F2E8" : "#213B34"
    readonly property color danger: light ? "#AD3540" : "#F398A0"
    readonly property color warning: light ? "#8B550E" : "#E9AF65"
    readonly property color info: light ? "#176CA9" : "#55B5F8"
    readonly property string family: "Microsoft YaHei UI"
}
