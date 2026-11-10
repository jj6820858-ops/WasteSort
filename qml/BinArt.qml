import QtQuick
Canvas {
    id: art
    property color ink: "#55B5F8"
    property int kind: 0
    property real fillLevel: 0.3
    implicitWidth: 76; implicitHeight: 88
    onInkChanged: requestPaint()
    onFillLevelChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
        let c = getContext("2d");c.reset();c.scale(width/80,height/94);
        c.strokeStyle = ink;c.lineWidth=1.7;c.lineJoin="round";
        c.fillStyle=Qt.rgba(ink.r,ink.g,ink.b,0.10);
        c.beginPath();c.moveTo(16,23);c.lineTo(64,23);c.lineTo(59,84);c.lineTo(21,84);c.closePath();c.fill();c.stroke();
        c.save();c.clip();c.fillStyle=Qt.rgba(ink.r,ink.g,ink.b,0.22);c.fillRect(15,84-58*fillLevel,50,60*fillLevel);c.restore();
        c.fillStyle=Qt.rgba(ink.r,ink.g,ink.b,0.24);c.fillRect(12,16,56,7);c.strokeRect(12,16,56,7);
        c.strokeRect(29,10,22,6);
        c.beginPath();c.moveTo(27,88);c.lineTo(29,88);c.moveTo(51,88);c.lineTo(53,88);c.stroke();
        c.save();c.translate(40,51);
        if(kind===0){
            for(let a=0;a<3;a++){c.save();c.rotate(a*2*Math.PI/3);c.beginPath();c.moveTo(-9,-7);c.lineTo(4,-7);c.lineTo(8,0);c.moveTo(8,0);c.lineTo(8,-5);c.moveTo(8,0);c.lineTo(3,-1);c.stroke();c.restore();}
        } else if(kind===1){
            c.strokeRect(-8,-8,16,16);c.beginPath();c.moveTo(-4,-4);c.lineTo(4,4);c.moveTo(4,-4);c.lineTo(-4,4);c.stroke();
        } else if(kind===2){
            c.beginPath();c.moveTo(-9,9);c.bezierCurveTo(-14,-9,1,-11,11,-11);c.bezierCurveTo(12,6,3,14,-9,9);c.moveTo(-9,9);c.lineTo(6,-5);c.stroke();
        } else {
            c.beginPath();c.moveTo(0,-13);c.bezierCurveTo(-21,10,-4,16,4,10);c.bezierCurveTo(14,4,5,-6,0,-13);c.stroke();
        }
        c.restore();
    }
}
