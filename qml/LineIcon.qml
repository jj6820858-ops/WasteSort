import QtQuick
Canvas {
    id: root
    property string kind: "grid"
    property color ink: Theme.muted
    implicitWidth: 24; implicitHeight: 24
    onInkChanged: requestPaint()
    onKindChanged: requestPaint()
    onPaint: {
        let c = getContext("2d"); c.reset();
        c.scale(width / 24, height / 24); c.strokeStyle = ink; c.lineWidth = 1.6; c.lineCap = "round"; c.lineJoin = "round";
        function line(x,y,xx,yy) { c.beginPath(); c.moveTo(x,y); c.lineTo(xx,yy); c.stroke(); }
        if (kind === "grid") {
            for(let x = 4; x < 20; x += 10) for(let y = 4; y < 20; y += 10) c.strokeRect(x,y,6,6);
        } else if (kind === "log") {
            c.strokeRect(5,3,14,18); line(9,8,15,8); line(9,12,15,12); line(9,16,13,16);
        } else if (kind === "settings") {
            line(4,6,20,6); line(4,12,20,12); line(4,18,20,18);
            c.fillStyle = Theme.surface;
            [[9,6],[16,12],[8,18]].forEach(function(p){c.beginPath();c.arc(p[0],p[1],2.4,0,Math.PI*2);c.fill();c.stroke();});
        } else if (kind === "logout") {
            line(10,4,5,4); line(5,4,5,20); line(5,20,10,20); line(11,12,21,12); line(17,8,21,12); line(17,16,21,12);
        } else if (kind === "leaf") {
            c.beginPath();c.moveTo(5,19);c.bezierCurveTo(-2,7,12,3,21,3);c.bezierCurveTo(21,18,13,23,5,19);c.stroke();line(5,19,15,9);
        } else if (kind === "link") {
            c.strokeRect(5,5,14,11);line(12,16,12,21);line(8,21,16,21);
        } else if (kind === "check") {
            line(4,12,10,18);line(10,18,21,5);
        }
    }
}
